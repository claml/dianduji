# Vendored SQLite amalgamation

This directory contains `sqlite3.c` from the official SQLite 3.53.3
amalgamation. The `package:sqlite3` 3.5.0 build hook compiles this source for
the target platform and architecture, so Android builds do not depend on an
OS-provided `libsqlite3.so` or a build-time GitHub download.

- Source: https://www.sqlite.org/2026/sqlite-amalgamation-3530300.zip
- Archive SHA-256: `646421e12aac110282ef8cc68f1a62d4bb15fc7b8f09da0b53e29ee690500431`
- Archive SHA3-256 published by SQLite: `d45c688a8cb23f68611a894a756a12d7eb6ab6e9e2468ca70adbeab3808b5ab9`
- Vendored `sqlite3.c` SHA-256: `7a0678e1de8fedda0c1f2c78c022f9b49381c167369856a27d1f77693419bc4e`
- License: public domain; see https://www.sqlite.org/copyright.html

Only `sqlite3.c` is vendored because the sqlite3 hook accepts the amalgamation
source file directly and supplies its own compile configuration. The vendored
copy removes four trailing spaces from upstream line 23 so that the repository's
whitespace check remains clean; this does not change C tokens or behavior.
