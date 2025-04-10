# Updates

Learn how to build queries that update data in a database.

## Overview

### Updating rows

You can create an ``Update`` statement by invoking ``Table/update(or:set:)`` with a closure that is
given a table definition that you are allowed to make a certain set of simple mutations to, which
are translated to the equivalent SQL code. For example, you can assign values to certain columns:

```swift
Reminder.update {
  $0.isCompleted = false
}
// UPDATE "reminders" SET
//   "isCompleted" = 0
```

And you can invoke some familiar mutating methods and expressions that translate to the
corresponding SQL:

```swift
Reminder.update {
  $0.isFlagged.toggle()
  $0.title += " (Updated)"
  $0.priority = #sql("min(\($0.priority + 1), 3)")
}
// UPDATE "reminders" SET
//   "isFlagged" = (NOT "reminders"."isFlagged"),
//   "title" = ("title" || ' (Updated)'),
//   "priority" = min("reminders.priority" + 1, 3)
```

> Important: Updating a table in an unconstrained fashion like this is probably not what you want,
> 99.99% of the time, as it will update _every single row_ with the given changes. Instead, you
> should filter the update to a specific row or set of rows that match a certain condition. See
> <doc:#Filtering-updates>, below.

### Filtering updates

You can filter an ``Update`` statement by providing predicates _via_ the ``Update/where(_:)``
method.

```swift
Reminder.update { 
  $0.isCompleted = true
}
.where {
  $0.id == 42
}
// UPDATE "reminders" SET
//   "isCompleted" = 1
// WHERE
//   ("reminders"."id" = 42)
```

> Tip: You can also create a ``Where`` clause and chain into its ``Where/update(or:set:)`` method to
> provide the filter up front.
>
> ```swift
> Reminder
>   .where { $0.id == 42 }
>   .update { $0.isCompleted = true }
> ```
>
> See <doc:WhereClauses> for more information.

### Updating records

When it comes to tables with primary keys, you can create an ``Update`` statement from a table value
that updates every single column with the value's properties:

```swift
var reminder = … // Fetch reminder from database
reminder.isCompleted = true
Reminder.update(reminder)
// UPDATE "reminders" SET
//   "title" = 'Get groceries',
//   "isCompleted" = 1,
//   "priority" = 3
// WHERE
//   ("reminders"."id" = 42)
```

> Important: This function is convenient for certain flows, but is less precise than
> ``Table/update(or:set:)``, which specifies each column update explicitly. If a record is loaded
> from the database, mutated, and written back to the database at a later time, any writes that
> happened to that record in the meantime will be reverted.

### Returning

By default, ``Update`` statements are fire-and-forget and do not return any results from the
database. To return the data updated by the database, you can use ``Update/returning(_:)``, which
adds a `RETURNING` clause to the statement.

```swift
Reminder.update {
  $0.isCompleted = true
}
.where {
  $0.id == 42
}
.returning(\.self)
// UPDATE "reminders" SET
//   "isCompleted" = 1
// WHERE
//   ("id" = 42)
// RETURNING "id", "isCompleted", "title", "priority"
// => Reminder
```

> Tip: The ``Insert`` and ``Delete`` statements support `RETURNING` clauses, as well.

### Conflict resolution

Updates include an optional `or` parameter, which can be used to specify the `OR` clause for
conflict resolution:

```swift
Tag.update(or: .ignore) {
  $0.name = "home"
}
.where {
  $0.id == 42
}
// UPDATE OR IGNORE "tags"
//   "name" = 'home'
// WHERE
//   ("id" = 42)
```

## Topics

### Updating values

- ``Table/update(or:set:)``
- ``PrimaryKeyedTable/update(or:_:)``

### Updating drafts

- ``PrimaryKeyedTable/upsert(_:)``

### Statement types

- ``Update``
