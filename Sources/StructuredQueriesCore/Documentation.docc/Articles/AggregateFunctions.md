# Aggregate functions

Aggregate data in your queries using SQL functions.

## Overview

Structured Queries surfaces a number of aggregate functions as type-safe methods in its query
builder,
discoverable _via_ autocomplete.

```swift
Reminder.select { $0.priority.avg() }
// SELECT avg("reminders"."priority") FROM "reminders"

Reminder.select { $0.id.count(filter: $0.isCompleted) }
// SELECT
//   count("reminders"."id")
//     FILTER (WHERE "reminders"."isCompleted")
// FROM "reminders"

Reminder.select {
  $0.title.groupConcat(", ", order: $0.title)
}
// SELECT
//   group_concat(
//     "reminders"."title", ', ' ORDER BY "reminders"."title"
//   )
// FROM "reminders"
```

## Topics

### Aggregating values

- ``QueryExpression/avg(distinct:filter:)``
- ``AggregateFunction/count(filter:)``
- ``QueryExpression/count(distinct:filter:)``
- ``QueryExpression/groupConcat(distinct:order:filter:)``
- ``QueryExpression/max(filter:)``
- ``QueryExpression/min(filter:)``
- ``QueryExpression/sum(distinct:filter:)``
- ``QueryExpression/total(distinct:filter:)``
