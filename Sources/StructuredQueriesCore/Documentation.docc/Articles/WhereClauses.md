# "Where" clauses

Learn how to share filtering logic across `SELECT`, `UPDATE`, and `DELETE` statements.

## Overview

Structured Queries models `WHERE` clauses as a distinct type, ``Where``, that can be used to
produce ``Select``, ``Update``, or ``Delete`` statements accordingly.

Values of this type are returned from ``Table/where(_:)``, and only become another statement type
when chaining into other builder methods, like ``Where/select(_:)``, ``Where/update(or:set:)``, and
``Where/delete()``.

By default, a ``Where`` statement is executed as a `SELECT`:

```swift
let completed = Reminder.where(\.isCompleted)  // Where<Reminder>
// SELECT … FROM "reminders"
// WHERE "reminders"."isCompleted"
```

But chaining into the `update` function will return an `UPDATE` statement filtered by the `WHERE`
clause:

```swift
completed.update {
  $0.isCompleted = false
}
// UPDATE "reminders" SET
//   "isCompleted" = 0
// WHERE "reminders"."isCompleted"
```

Likewise chaining into `delete` will return a filtered `DELETE` statement:

```swift
completed.delete()
// DELETE FROM "reminders"
// WHERE "reminders"."isCompleted"
```

## Topics

### Statements

- ``Where``
