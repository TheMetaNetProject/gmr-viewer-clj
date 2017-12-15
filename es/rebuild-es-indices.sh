#!/usr/bin/env bash

BASE=$(dirname $(readlink -f $0))

#$BASE/dbs.py | xargs -L 1 $BASE/mkriver2.sh

$BASE/dbs.py | while read -r db; do
	$BASE/mkriver2.sh $db
	sleep 60
done
