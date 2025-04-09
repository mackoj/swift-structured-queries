# Defining your schema

Learn how to replicate your database's schema in first class Swift types 
using the `@Table` and `@Column` macros.

## Overview

@Comment {
  Describe table/column macro, column argumnets, bind strategies, primary key tables, etc...
  }

The library provides tools to model Swift data types that replicate your database's schema so that
you can use the static description of its propertly to build type-safe queries. Typically the 
schema of your app is defined first and foremost in your database, and then you define Swift types
that represent those database definitions.

### Defining a table

Suppose your database has a table defined with the following create statement:

```sql
CREATE TABLE "reminders" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT",
  "title" TEXT NOT NULL,
  "isCompleted" INTEGER DEFAULT 0
)
```

Then to define a Swift data type that represents this table, one can use the `@Table` macro:

```swift
@Table struct Reminder {
  let id: Int 
  var title = ""
  var isCompleted = false
}
```

> Note: that the struct's field names match the column tables of the table exactly. In order to
support property names that differ from the columns names, you can use the `@Column` macro. See the
section below, <doc:DefiningYourSchema#Customizing-a-table>,  for more information on how to
customize your data type.

With this table defined you immediately get access to the suite of tools of the library to build
queries:

```swift
Reminder
  .where { !$0.isCompleted }
// SELECT *
// FROM "reminders"
// WHERE NOT "isCompleted"
```

### Customizing a table

Often times we want our Swift data types to use a different naming convention than the tables and
columns in our database. It is common for tables and columns to use snakecase naming, whereas 
Swift almost always written in camelcase. The library provides tools for you to define your Swift
data types exactly as you want, while still being adaptible to the schema of your database.

#### Table names

By default the `@Table` macro assumes that the name of your database table is the "pluralized" 
version of your data type's name. In order to pluralize the type name the library has some light
inflection logic to come up with mostly reasonable results:

```swift
@Table struct Reminder {}
@Table struct Category {}
@Table struct Status {}
@Table struct ReminderList {}

Reminder.tableName  // "reminders"
Category.tableName  // "categories"
Status.tableName    // "statuses"
Status.tableName    // "reminderLists"
```

However, many people prefer for their table names to be the _singular_ form of the noun, or they
prefer to use snakecase instead of camelcase. In such cases you can provide the ``Table/tableName``
requirement manually for each of your table types:

```swift
@Table struct Reminder {
  static let tableName = "reminder"
}
@Table struct Category {
  static let tableName = "category"
}
@Table struct Status {
  static let tableName = "status"
}
@Table struct ReminderList {
  static let tableName = "reminder_list"
}

Reminder.tableName  // "reminder"
Category.tableName  // "category"
Status.tableName    // "status"
Status.tableName    // "reminder_list"
```

#### Column names

Properties of Swift types often differ in formatting from the columns they represent in the 
database. Most often this is a different of snakecase versus camelcase. In such situations you can
use the `@Column` macro to describe the name of the column as it exists in the database in order
to have your Swift data type represent the most prestine version of itself:

```swift
@Table struct Reminder {
  let id: Int 
  var title = ""
  @Column("is_completed")
  var isCompleted = false
}

Reminder.where { !$0.isCompleted }
// SELECT *
// FROM "reminders"
// WHERE NOT "is_completed"
```

Here we get to continue using camelcase `isCompleted` in Swift, as is customary, but the SQL 
generated when writing queries will correctly use `"is_completed"`.

### Custom data types

There are many data types that do not have native support in SQLite, such as `Date`. There are 3 
ways to represent dates in SQLite:

* Text column interpreted as ISO-8601 formatted string.
* Int column interpreted as number of seconds since Unix epoch.
* Double column interpreted as a julian date (number of seconds since Nov 24, 4713 B.C.).

Because of this ambiguity, the `@Table` macro does not know what you intend when you define a 
data type like this:

```swift
@Table struct Reminder {
  let id: Int 
  var date: Date
}
```

In order to make it explicit how you expect to turn a `Date` into a type that SQLite understands
(i.e. text, integer or double) you can use the `@Column` macro with the `as:` argument. The 
library comes with 3 strategies out the box to help, ``Foundation/Date/ISO8601Representation``
for storing the date as a string, ``Foundation/Date/UnixTimeRepresentation`` for storing the 
date as an integer, and ``Foundation/Date/JulianDayRepresentation`` for storing the date as a 
float.

Any of these representations can be used like so:

```swift
@Table struct Reminder {
  let id: Int
  @Column(as: Date.ISO8601Representation.self)
  var date: Date
}
```

One can also define their own custom representations for any data type by conforming to the 
``QueryRepresentable`` protocol. 

<!-- TODO: See <doc:ABC> for more information on custom data types. -->

#### Primary key

It is possible to tell let the `@Table` macro know which property of your data type is the primary
key for the table in the database, and doing so unlocks new APIs for inserting, updating and 
deleting records. By default the `@Table` macro will assume any property named `id` is the 
primary key, or you can explictly specify it with the `primaryKey:` argument of the `@Column`
macro:

```swift
struct Book {
  @Column(primaryKey: true)
  let isbn: String 
  var title = ""
}
```

See <doc:PrimaryKeyedTable> for more information on tables with primary keys.

<!---->
<!--#### Ephemeral columns-->
<!---->
<!--It is possible to store properties in a Swift data type that has no corresponding column in your SQL-->
<!--database. Such properties must have a default value, and can be specified using the `@Ephemeral`-->
<!--macro:-->
<!---->
<!--```swift-->
<!--struct Book {-->
<!--  @Column(primaryKey: true)-->
<!--  let isbn: String -->
<!--  var title = ""-->
<!--}-->
<!--```-->



## Topics

### Schema

- ``Table``
- ``PrimaryKeyedTable``

### Bindings

- ``QueryBindable``
- ``QueryBinding``
- ``QueryBindingError``

### Decoding

- ``QueryRepresentable``
- ``QueryDecodable``
- ``QueryDecoder``
- ``QueryDecodingError``
