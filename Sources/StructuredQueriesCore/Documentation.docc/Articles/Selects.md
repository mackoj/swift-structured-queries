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
let query = Reminder.select { ($0.id, $0.title, $0.isCompleted) }

for (id, title, isCompleted) in /* execute query */ {
  _: Int = id
  _: String = title
  _: Bool = isCompleted
}
```

Selection is incremental, so multiple chained calls to `select` will result in a statement that
returns a tuple of the combined columns:

```swift
let query = Reminder
  .select(\.id)
  .select(\.title)
  .select(\.isCompleted)

_: some Statement<(Int, String, Bool)> = query
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

_: some Statement<ReminderResult> = query
```

To bundle up incrementally-selected columns, you can use the ``Select/map(_:)`` operator, which is
handed the currently-selected columns:

```swift
let query = Reminder
  .select(\.id)
  .select(\.title)
  .select(\.isCompleted)

_: some Statement<ReminderResult> = query.map { _, title, isCompleted in
  ReminderResult.Columns(
    title: $0.title,
    isCompleted: $0.isCompleted
  )
}
// SELECT "reminders"."title", "reminders"."isCompleted"
// FROM "reminders"
```

### Joining tables

The `join`, `leftJoin`, `rightJoin`, and `fullJoin` functions are used to specify the various
flavors of joins in a query. Each take a query on the join table, as well as trailing closure that
is given the columns of each table so that it can describe the join constraint:

```swift
RemindersList.join(Reminder.all) { $0.id == $1.remindersListID }
// SELECT "remindersLists".…, "reminders".… FROM "remindersLists"
// JOIN "reminders" ON "remindersLists"."id" = "reminders"."remindersListID"
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


<!--
compound selects: union, intersection, etc...
-->
