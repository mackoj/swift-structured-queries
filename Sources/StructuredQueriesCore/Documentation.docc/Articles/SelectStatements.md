# Selects

Learn how to build queries that read data from a database.

## Overview

### Selecting columns

The `select` function is used to specify the result columns of a query. It uses a given closure to
specify any number of result columns as a variadic tuple from the table columns passed to the
closure:

```swift
@Table
struct Reminder {
  let id: Int
  var title = ""
  var isCompleted = false
}

Reminder.select(\.id)
// SELECT "reminders"."id"
// FROM "reminders"

Reminder.select { ($0.id, $0.title) }
// SELECT "reminders"."id", "reminders"."title"
// FROM "reminders"

Reminder.select { ($0.id, $0.title, $0.isCompleted) }
// SELECT "reminders"."id", "reminders"."title", "reminders"."isCompleted"
// FROM "reminders"
```

These selected columns become the row data type that will be decoded from a database.

```swift
Reminder.select { ($0.id, $0.title, $0.isCompleted) }
// Statement<(Int, String, Bool)>
```

Selection is incremental, so multiple chained calls to `select` will result in a statement that
returns a tuple of the combined columns:

```swift
let q1 = Reminder.select(\.id)     // => Int
let q2 = q1.select(\.title)        // => (Int, String)
let q3 = q2.select(\.isCompleted)  // => (Int, String, Bool)
```

To bundle selected columns up into a custom data type, you can annotate a struct of decoded results
with the `@Selection` macro:

```swift
@Selection
struct ReminderResult {
  let title: String
  let isCompleted: Bool
}

let query = Reminder.select {
  ReminderResult.Columns(
    title: $0.title,
    isCompleted: $0.isCompleted
  )
}
// => ReminderResult
```

To bundle up incrementally-selected columns, you can use the ``Select/map(_:)`` operator, which is
handed the currently-selected columns:

```swift
let query = Reminder
  .select(\.id)
  .select(\.title)
  .select(\.isCompleted)

query.map { _, title, isCompleted in
  ReminderResult.Columns(
    title: $0.title,
    isCompleted: $0.isCompleted
  )
}
// SELECT "reminders"."title", "reminders"."isCompleted"
// FROM "reminders"
// => ReminderResult
```

### Joining tables

The `join`, `leftJoin`, `rightJoin`, and `fullJoin` functions are used to specify the various
flavors of joins in a query. Each take a query on the join table, as well as trailing closure that
is given the columns of each table so that it can describe the join constraint:

```swift
RemindersList.join(Reminder.all) { $0.id == $1.remindersListID }
// SELECT "remindersLists".…, "reminders".… FROM "remindersLists"
// JOIN "reminders" ON "remindersLists"."id" = "reminders"."remindersListID"
// => (RemindersList, Reminder)
```

Joins combine each query together by concatenating their existing clauses together, including
selected columns, joins, filters, and more.

```swift
RemindersList
  .select(\.title)
  .join(Reminder.select(\.title) { /* ... */ }
// SELECT "remindersLists"."title", "reminders"."title" FROM "remindersLists"
// JOIN "reminders" ON "remindersLists"."id" = "reminders"."remindersListID"
// => (String, String)

RemindersList
  .where { $0.id == 1 }
  .join(Reminder.where(\.isFlagged) { /* ... */ }
// SELECT "remindersLists".…, "reminders".… FROM "remindersLists"
// JOIN "reminders" ON "remindersLists"."id" = "reminders"."remindersListID"
// WHERE ("remindersLists"."id" = 1) AND "reminders"."isFlagged"
// => (RemindersList, Reminder)
```

Outer joins---left, right, and full---optionalize the data of the outer side(s) of the joins.

```swift
RemindersList.join(Reminder.all) { /* ... */ }
// => (RemindersList, Reminder)

RemindersList.leftJoin(Reminder.all) { /* ... */ }
// => (RemindersList, Reminder?)

RemindersList.rightJoin(Reminder.all) { /* ... */ }
// => (RemindersList?, Reminder)

RemindersList.fullJoin(Reminder.all) { /* ... */ }
// => (RemindersList?, Reminder?)
```

Tables that join themselves must be aliased to disambiguate the resulting SQL. This can be done by
introducing an ``AliasName`` conformance and passing it to ``Table/as(_:)``:

```swift
@Table
struct User {
  let id: Int
  var name = ""
  var referrerID: Int?
}

enum Referrer: AliasName {}

let usersWithReferrers = User
  .leftJoin(User.as(Referrer.self).all) { $0.referrerID == $1.id }
  .select { ($0.name, $1.name) }
// SELECT "users"."name", "referrers.name"
// FROM "users"
// JOIN "users" AS "referrers"
// ON "users"."referrerID" = "referrers"."id"
// => (String, String?)
```

#### Self-joins

<!-- TODO: Table aliases -->

### Filtering results

<!-- TODO: WHERE -->

### Grouping results

<!-- TODO: GROUP BY -->

### Filtering by aggregates

<!-- TODO: HAVING -->

### Sorting results

<!-- TODO: ORDER BY -->

### Paginating results

<!-- TODO: LIMIT OFFSET  -->

## Topics

### Statement types

- ``Select``
- ``SelectStatement``

### Convenience type aliases

- ``SelectStatementOf``

### Supporting types

- ``NullOrdering``

### Self-joins

- ``TableAlias``
- ``AliasName``

<!--
compound selects: union, intersection, etc...
-->
