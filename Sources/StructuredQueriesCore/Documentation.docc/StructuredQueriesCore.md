# ``StructuredQueriesCore``

A library for building SQL in a type-safe, expressive, and composable manner. This module is
automatically imported when you `import StructuredQueries`.

## Overview

This library provides a suite of tools that allow you to write type-safe, expressive and composable
SQL statements using Swift. It can help you catch simple mistakes when writing your queries, such as
typos in your columns names, or comparing two different data types. Learn the basics of writing your
first `SELECT`, `INSERT`, `UPDATE`, and `DELETE` queries, as well as writing safe SQL strings
directly.

> Important: This library does not come with any database drivers for making actual database
> requests, _e.g._ to, SQLite, Postgres, MySQL. This library focuses only on building SQL statements
> and providing the tools that would allow you to integrate with another library that makes the
> actual database requests. See <doc:Integration> for information on how to integrate this library
> with a database library.

## Topics

### Essentials

- <doc:GettingStarted>
- ``Table``
- <doc:PrimaryKeyedTables>
<!-- rename: query cookbook -->
- <doc:AdvancedQueries>
- <doc:BindingAndDecoding>
- <doc:CompilerPerformance>

### Statements

- <doc:SelectStatements>
- <doc:InsertStatements>
- <doc:UpdateStatements>
- <doc:DeleteStatements>
- <doc:WhereClauses>
- <doc:CommonTableExpressions>
- <doc:StatementTypes>

### Expressions

- ``QueryFragment``
- <doc:AggregateFunctions>
- <doc:Operators>
- <doc:ScalarFunctions>
- <doc:ExpressionTypes>

### Advanced 

- <doc:Integration>
