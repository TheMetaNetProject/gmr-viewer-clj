#!/usr/bin/env bash

if [ `uname` == "Linux" ]; then
    BASE=$(dirname $(readlink -f $0))
else
    BASE=$(cd $(dirname $0); pwd -P)
fi

if [ $# != 1 ]; then
    echo "Usage: $(basename $0) <DB_NAME>"
    exit -1
fi

# Do not touch these
INDEX_TYPE="lms3"
ES_HOST="localhost:9202"
CONF_D="$BASE/conf.d"

DB_NAME=$1
INDEX_NAME=${DB_NAME/test_docs_/lms-}

FT2=$BASE/../resources/indices/ft2_es.py
SCRIPT=$(python -c 'import json, sys; s = sys.stdin.read(); sys.stdout.write(json.dumps(s))' < $FT2) 
curl -X PUT "$ES_HOST/$INDEX_NAME" -d@- <<End-of-data
{
  "settings": {
    "analysis": {
      "analyzer": {
        "custom_analyzer": {
          "type": "custom",
          "tokenizer": "keyword",
          "filter": [
            "lowercase"
          ]
        }
      }
    }
  },
  "mappings": {
    "${INDEX_TYPE}": {
      "properties": {
        "cms": {
          "type": "string",
          "analyzer": "custom_analyzer"
        },
        "id": {
          "type": "string",
          "index": "not_analyzed"
        },
        "perspective": {
          "type": "string",
          "analyzer": "custom_analyzer"
        },
        "score": {
          "type": "double"
        },
        "cxn": {
          "type": "string",
          "analyzer": "custom_analyzer"
        },
        "source-concepts": {
          "type": "string",
          "analyzer": "custom_analyzer"
        },
        "source-coreness": {
          "type": "double"
        },
        "source-form": {
          "type": "string",
          "analyzer": "custom_analyzer"
        },
        "source-lemma": {
          "type": "string",
          "analyzer": "custom_analyzer"
        },
        "source-framefamilies": {
          "type": "string",
          "analyzer": "custom_analyzer"
        },
        "source-framenames": {
          "type": "string",
          "analyzer": "custom_analyzer"
        },
        "target-concept": {
          "type": "string",
          "analyzer": "custom_analyzer"
        },
        "target-congroup": {
          "type": "string",
          "analyzer": "custom_analyzer"
        },
        "target-form": {
          "type": "string",
          "analyzer": "custom_analyzer"
        },
        "target-lemma": {
          "type": "string",
          "analyzer": "custom_analyzer"
        },
        "target-framenames": {
          "type": "string",
          "analyzer": "custom_analyzer"
        },
        "target-framefamily": {
          "type": "string",
          "analyzer": "custom_analyzer"
        },
        "text": {
          "type": "string"
        }
      }
    }
  }
}
End-of-data


cat > $CONF_D/$DB_NAME.conf <<End-of-conf
input { 
  couchdb_changes {
    sequence_path => "${BASE}/seq.d/${DB_NAME}.seq"
    db            => "${DB_NAME}"
    host          => "localhost"
  }
}

output { 
#  stdout { codec => rubydebug } 

  elasticsearch { 
    hosts           => ["${ES_HOST}"] 
    index           => "${INDEX_NAME}" 
    document_type   => "${INDEX_TYPE}" 
    document_id     => "%{[@metadata][_id]}"
    script          => ${SCRIPT}
    scripted_upsert => true
    script_lang     => "python"
    script_type     => ["inline"]
  } 
}
End-of-conf

# To delete index:
#curl -X DELETE "$ES_HOST/$INDEX_NAME"
