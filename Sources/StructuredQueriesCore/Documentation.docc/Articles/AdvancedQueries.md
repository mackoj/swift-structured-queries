# Advanced queries

Learn advanced techniques in writing queries with this library, including reusing queries, default
scopes and decoding into custom data types.

## Overview

The library comes with a variety of tools that allow you to define helpers for composing together
large and complex queries.

### Reusable queries

One can define query helpers as statics on their tables in order to facilitate using those
queries in a variety of situations. For example, suppose that the `Reminder` and `RemindersList`
tables had a `deletedAt` column that represents when the record was deleted so that the record
could be restored for a certain amount of time. These tables can be represented like so:

```swift
@Table
struct RemindersList: Identifiable {
  let id: Int 
  var title = ""
  @Column(as: Date.ISO8601Representation.self)
  var deletedAt: Date?
}
@Table
struct Reminder: Identifiable {
  let id: Int 
  var title = ""
  var isCompleted = false
  @Column(as: Date.ISO8601Representation.self)
  var dueAt: Date?
  @Column(as: Date.ISO8601Representation.self)
  var deletedAt: Date?
  var remindersListID: RemindersList.ID
}
```

It is then possible to define a `notDeleted` helper that automatically applies a `where` clause
to filter out deleted lists and reminders:

```swift
extension RemindersList {
  static let notDeleted = Self.where { $0.deletedAt.isNot(nil) }
}
extension Reminder {
  static let notDeleted = Self.where { $0.deletedAt.isNot(nil) }
}
```

Then these helpers can be used when composing together a larger, more complex query. For example, 
we can select all lists with the count of reminders in each list like so:

```swift
RemindersList
  .notDeleted
  .group(by: \.id)
  .leftJoin(Reminder.notDeleted) { $0.id.eq($1.remindersListID) }
  .select { ($0.title, $1.id.count() }
// SELECT "remindersLists"."title", count("reminders"."id")
// FROM "remindersLists"
// LEFT JOIN "reminders" ON "remindersLists"."id" = "reminders"."remindersListID"
// WHERE "remindersLists"."deletedAt" IS NOT NULL
//   AND "reminders"."deletedAt" IS NOT NULL
```

Further, if your are compiling with Swift 6.1 or higher, then you can chain these static helpers
anywhere in the query builder, not just directly on the type of the table. For example, we can
specify `notDeleted` after the `group(by:)` clause:

```swift
RemindersList
  .group(by: \.id)
  .notDeleted
  .leftJoin(Reminder.notDeleted) { $0.id.eq($1.remindersListID) }
  .select { ($0.title, $1.id.count() }
```

This produces the same query even though the `notDeleted` static helper is chained after the
`group(by:)` clause.

It is also possible to define helpers on the ``Table/TableColumns`` type inside each table that
make it easier to share column logic amongst many queries. For example,

<!-- TODO: Finish -->

```swift
extension Reminder.TableColumns {
  var isPastDue: some QueryExpression<Bool> {
    !isCompleted && #sql("date(\(dueAt)) < date('now')")
  }
  var isToday: some QueryExpression<Bool> {
    !isCompleted && #sql("date(\(dueAt)) = date('now')")
  }
  var isScheduled: some QueryExpression<Bool> {
    !isCompleted && #sql("date(\(dueAt)) > date('now')")
  }
}
```

<!--
* extensions on Table.Columns

-->

### Default scopes

### Custom selections
