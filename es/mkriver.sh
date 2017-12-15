#!/usr/bin/env bash

# Do not touch this
INDEX_TYPE="lms3"

#DB_NAME="test_docs_en"
#INDEX_NAME="lms-en"

#DB_NAME="test_docs_poverty_en"
#INDEX_NAME="lms-poverty_en"

#DB_NAME="test_docs_poverty_engw5e_en"
#INDEX_NAME="lms-poverty_engw5e_en"

DB_NAME=test_docs_${1:-"pov3_engw5e_0727"}
INDEX_NAME=lms-${1:-"pov3_engw5e_0727"}

#DB_NAME="test_docs_test_case"
#INDEX_NAME="lms-test3"
#INDEX_NAME="lms-test_case"

if [ `uname` == "Linux" ]; then
    BASE=$(dirname $(readlink -f $0))
else
    BASE=$(cd $(dirname $0); pwd -P)
fi
FT2=$BASE/../resources/indices/ft2_es.py
SCRIPT=$(python -c 'import json, sys; s = sys.stdin.read(); sys.stdout.write(json.dumps(s))' < $FT2) 
curl -X PUT "localhost:9200/$INDEX_NAME" -d@- <<End-of-data
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

curl -X PUT "localhost:9200/_river/$DB_NAME/_meta" -d@- <<End-of-data
{
  "type" : "couchdb",
  "couchdb" : {
    "host" : "localhost",
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
#curl -X DELETE "localhost:9200/_river/$DB_NAME/_meta"

# To delete index:
#curl -X DELETE "localhost:9200/$INDEX_NAME"
