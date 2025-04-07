# ``StructuredQueriesCore``

A library for building SQL in a type-safe, expressive, and composable manner.

## Overview

This library provides a suite of tools that allow you to write type-safe, expressive and composable
SQL statements using Swift. It can help you catch simple mistakes when writing your queries, 
such as typos in your columns names, or comparing two different data types. Learn the basics of writing
you first "SELECT", "INSERT", "UPDATE" and "DELETE" queries, as well as writing safe SQL strings directly.

> Important: This library does not come with any database drivers for making actual requests and decoding
data, such as for SQLite, Postgres, MySQL, etc. This library focuses only on building SQL statements and 
providing the tools that would allow you to integrate with another library that makes the actual database
requests. See <doc:Integration> for information on how to integrate this library with a database library.




## Topics

### Essentials

- <doc:GettingStarted>
- <doc:AdvancedQueries>
- <doc:Integration>
- <doc:CompilerPerformance>

### Query building

- <doc:Statements>
- <doc:CommonTableExpressions>

### Schema definition

- ``Table``
