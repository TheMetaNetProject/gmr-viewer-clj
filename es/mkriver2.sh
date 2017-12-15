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

# Do not touch this
INDEX_TYPE="lms3"

DB_NAME=$1
INDEX_NAME=${DB_NAME/test_docs_/lms-}
HOST="ambrosia2"

FT2=$BASE/../resources/indices/ft2_es.py
SCRIPT=$(python -c 'import json, sys; s = sys.stdin.read(); sys.stdout.write(json.dumps(s))' < $FT2) 
curl -X PUT "${HOST}:9200/$INDEX_NAME" -d@- <<End-of-data
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

curl -X PUT "${HOST}:9200/_river/$DB_NAME/_meta" -d@- <<End-of-data
{
  "type" : "couchdb",
  "couchdb" : {
    "host" : "${HOST}",
    "port" : 5984,
    "db" : "$DB_NAME",
    "filter" : null,
    "script" : $SCRIPT,
    "script_type" : "python"
  },
  "index" : {
    "index" : "$INDEX_NAME",
    "type" : "$INDEX_TYPE",
    "bulk_size" : "10000",
    "bulk_timeout" : "10000ms"
  }
}
End-of-data


# To delete river:
#curl -X DELETE "${HOST}:9200/_river/$DB_NAME/_meta"

# To delete index:
#curl -X DELETE "${HOST}:9200/$INDEX_NAME"
