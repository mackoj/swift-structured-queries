# Integrating with database libraries

Learn how to integrate this library into existing database libraries so that you can build queries
in a  type-safe manner.

## Overview

Since this library focuses only on the building of type-safe queries, it does not come with a way to
actually execute the query in a particular database. The library is built with the goal of being
able to support any database (SQLite, MySQL, Postgres, _etc._), but currently is primarily tuned to
work with SQLite. And further, it only comes with one official driver for SQLite, which is the
[SharingGRDB][sharing-grdb-gh] library that uses the popular [GRDB][grdb-gh] library under the hood
for interacting with SQLite.

If you are interested in building an integration of StructureQueries with another database library
out there, please feel free to [open a discussion][sq-discussions] on the repository.

[sharing-grdb-gh]: http://github.com/pointfreeco/sharing-grdb 
[grdb-gh]: http://github.com/groue/grdb.swift
[sq-discussions]: http://github.com/pointfreeco/swift-structured-queries/discussions

@Comment {
  TODO: Rewrite as a case study of SQLite and GRDB that simply links to the directories on the repo
}

### Case Study: SQLite

One can integrate Structured Queries with the SQLite C library by taking a few small steps. One
first needs to define a conformance to the ``QueryDecoder`` protocol, which describes how to 
decode certain database types into Swift types. And then one must define a few helper methods
that can execute and decode SQL statements. This is done by defining a variety of methods that 
execute ``SelectStatement``s and ``Statement``s.

For a full implementation see the [StructuredQueriesSQLite][sq-sqlite] module in the library.
You should be able to adapt this sample code to execute Structured Queries with a SQLite connection,
or even integrate Structured Queries into a 3rd party SQLite library.

[sq-sqlite]: https://github.com/pointfreeco/swift-structured-queries/tree/main/Sources/StructuredQueriesSQLite

### Case Study: GRDB



https://github.com/pointfreeco/sharing-grdb/tree/main/Sources/StructuredQueriesGRDBCore

<!--@START_MENU_TOKEN@-->Text<!--@END_MENU_TOKEN@-->

<!--

TODO:

StructuredQueries built to support any DB, but currently SharingGRDB is the only 
available adapter. If you run into limitations using this library with your own
database open a discussion.

-->

[sharing-grdb-gh]: http://github.com/pointfreeco/sharing-grdb
[grdb-gh]: http://github.com/groue/grdb.swift
