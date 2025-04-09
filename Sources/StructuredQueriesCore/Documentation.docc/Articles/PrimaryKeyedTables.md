# Primary keyed tables

Learn how tables with a primary key get extra tools when it comes to inserting, updating, and
deleting records.

## Overview

A primary keyed table is one that has a column whose value is unique for the entire table. The most
common example is an "id" column that holds an integer, UUID, or some other kind of identifier.
Typically such columns are also initialized by the database so that when inserting rows into the
table you do not need to specify the primary key. The library provides extra tools that make it
easier to insert, update, and delete records that have a primary key.

### Specifying a primary key

When declaring your Swift type that represents a SQL table, you can use the `@Column` macro to
specify which field is the primary key of your table:

```swift
@Table
struct Book {
  @Column(primaryKey: true)
  let isbn: String
  var title: String
}
```

> Note: Using `primaryKey: true` does not create any kind of constraints on your table
> automatically. It is up to you to actually create this table and designate the column as the
> primary key.

The `@Table` macro will also automatically infer a field named `id` as a primary key, and so it is
not necessary to use the `@Column` macro in that case:

```swift
@Table
struct Reminder {
  // Automatically inferred '@Column(primaryKey: true)'
  let id: Int
  var title: String
}
```

> Note: At most one column can be designated as a primary key.

### Drafts

Once a primary key has been specified for a type, the `@Table` macro generates a special `Draft`
type nested inside your type. This type has all of the same fields as your type, except its primary
key field is made optional:

```swift
let draft = Reminder.Draft(title: "Get groceries")
```

The `id` is not necessary to provide because it is optional. This allows you to insert rows into
your database without specifying the id. The library comes with many APIs that specifically work
with drafts from primary keyed tables:

```swift
Reminder.insert(Reminder.Draft(title: "Get groceries"))
// INSERT INTO "reminders"
//   ("title")
// VALUES
//   ('Get groceries')
```

Since the "id" column is not specified in this query it allows the database to initialize it for us.
This `Draft` type is appropriate to use in any features that needs to build up a value without
specifying an ID.

### Updates and deletions

Primary keyed tables 

## Topics

### Primary keys

- ``PrimaryKeyedTable``
- ``PrimaryKeyedTableDefinition``
