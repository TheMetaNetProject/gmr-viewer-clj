#!/bin/bash

if [ $# != 1 ]; then
    echo "Usage: $(basename $0) <DB_NAME>"
    exit -1
fi

echo $1, ${1/test_docs_/lms-}
