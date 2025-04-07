# Integrating with database libraries

Learn how to integrate this library into existing database libraries so that you can build queries in a 
type-safe manner.

## Overview

Since this library focuses only on the building of type-safe queries, it does not come with a way to actually
execute the query in a particular database. The library is built with the goal of being able to support
any database (SQLite, MySQL, Postgres, etc.), but currently is primarily tuned to work with only SQLite. And
further, it only comes with one official driver for SQLite, which is the [SharingGRDB][sharing-grdb-gh]
library that uses the popular [GRDB][grdb-gh] library under the hood for interacting with SQLite.

If you are interested in building an integration of StructureQueries with another database library out
there, please feel free to [open a discussion][sq-discussions] on the repository.

[sq-discussions]: http://github.com/pointfreeco/swift-structured-queries/discussions

### Case Study: SQLite

Let's provide a rough outline of how one could integrate StructuredQueries with any SQLite library out there,
including GRDB, SQLite.swift, and more. It begins with defining a type that conforms to the ``QueryDecoder`` 
protocol, which describes how to decode certain database types into Swift types:

```swift
struct SQLiteQueryDecoder: QueryDecoder {
}
```

There are many methods that this type will need to provide, but first we will add some internal state
that it will need to do its job, such as the SQLite statement being decoded, as well as the current index
of the column we are decoding:

```swift
struct SQLiteQueryDecoder: QueryDecoder {
  let statement: OpaquePointer
  var currentIndex: Int32 = 0
  init(statement: OpaquePointer) {
    self.statement = statement
  }
}
```

Next we must implement 6 `decode` methods as a part of the requirement of the ``QueryDecoder`` protocol: 

```swift
mutating func decode(_ columnType: [UInt8].Type) throws -> [UInt8]? {
  <#code#>
}
mutating func decode(_ columnType: Double.Type) throws -> Double? {
  <#code#>
}
mutating func decode(_ columnType: Int64.Type) throws -> Int64? {
  <#code#>
}
mutating func decode(_ columnType: String.Type) throws -> String? {
  <#code#>
}
mutating func decode(_ columnType: Bool.Type) throws -> Bool? {
  <#code#>
}
mutating func decode(_ columnType: Int.Type) throws -> Int? {
  <#code#>
}
```

These methods correspond to the fundamental types that SQLite understands. In each of these methods we 
will attempt to extract out the corresponding type from the SQLite statement. For example, the method
for `Double` is implemented by using `sqlite3_column_type` to first check that the value is not NULL in
SQLite, and if it isn't we use `sqlite3_column_double` to decode the double value:

```swift
mutating func decode(_ columnType: Double.Type) throws -> Double? {
  defer { currentIndex += 1 }
  guard sqlite3_column_type(statement, currentIndex) != SQLITE_NULL else { return nil }
  return sqlite3_column_double(statement, currentIndex)
}
```

We can do the same for `Int64` and `String`:

```swift 
mutating func decode(_ columnType: Int64.Type) throws -> Int64? {
  defer { currentIndex += 1 }
  guard sqlite3_column_type(statement, currentIndex) != SQLITE_NULL else { return nil }
  return sqlite3_column_int64(statement, currentIndex)
}
mutating func decode(_ columnType: String.Type) throws -> String? {
  defer { currentIndex += 1 }
  guard sqlite3_column_type(statement, currentIndex) != SQLITE_NULL else { return nil }
  return String(cString: sqlite3_column_text(statement, currentIndex))
}
```

The `[Unt8]` method requires a bit more work to decode the C bytes into an array of `UInt8`'s:

```swift
mutating func decode(_ columnType: [UInt8].Type) throws -> [UInt8]? {
  defer { currentIndex += 1 }
  guard sqlite3_column_type(statement, currentIndex) != SQLITE_NULL else { return nil }
  return [UInt8](
    UnsafeRawBufferPointer(
      start: sqlite3_column_blob(statement, currentIndex),
      count: Int(sqlite3_column_bytes(statement, currentIndex))
    )
  )
}
```

And finally the `decode` methods for `Bool` and `Int` can be defined in terms of the above methods: 

```swift
mutating func decode(_ columnType: Bool.Type) throws -> Bool? {
  try decode(Int64.self).map { $0 != 0 }
}
mutating func decode(_ columnType: Int.Type) throws -> Int? {
  try decode(Int64.self).map(Int.init)
}
```

<!--
TODO: implement `execute`
-->

### Case Study: GRDB

<!--@START_MENU_TOKEN@-->Text<!--@END_MENU_TOKEN@-->

<!--

TODO:

StructuredQueries built to support any DB, but currently SharingGRDB is the only 
available adapter. If you run into limitations using this library with your own
database open a discussion.

-->

[sharing-grdb-gh]: http://github.com/pointfreeco/sharing-grdb
[grdb-gh]: http://github.com/groue/grdb.swift
