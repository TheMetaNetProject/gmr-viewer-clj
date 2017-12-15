#!/usr/bin/env python2 

from couchdbkit import Server

s = Server()
print '\n'.join(db for db in s.all_dbs() if db.startswith('test_docs'))

