# Safe SQL strings

Learn how to write hand-crafted SQL strings in a safe manner by leveraging the `#sql` macro.

## Overview

While it is possible to write many queries with Structured Queries' type-safe query building APIs,
the library also provides the `#sql` macro, which invites you to write SQL directly as a string, but
in a manner that is still safe from table and column name typos, SQL injection, and other syntax
errors.

### SQL fragments

The `#sql` macro can be used to introduce SQL strings into a query at the granularity of your
choosing.

For example, you can introduce a string for invoking the SQL `date()` function, but write the rest
of the query using the builder APIs:

```swift
Reminder.where { $0.dueDate < #sql("date()") }
// SELECT
//   "reminders"."id",
//   "reminders"."title",
//   "reminders"."dueDate",
//   "reminders"."isCompleted"
// FROM "reminders"
// WHERE "reminders"."dueDate" < date()
```

The macro returns a query expression (``SQLQueryExpression``, to be precise) with a type that is
inferred by the context of its use. In the above case, the `dueDate` column is a query expression of
an optional date (`Date?`), and so the `<` operator helps Swift infer that `#sql("date()")` is an
optional date, as well.

It's also possible to write the entire `WHERE` clause using the macro:

```swift
Reminder.where { #sql("\($0.dueDate) < date()") }
// SELECT
//   "reminders"."id",
//   "reminders"."title",
//   "reminders"."dueDate",
//   "reminders"."isCompleted"
// FROM "reminders"
// WHERE "reminders"."dueDate" < date()
```

In this case `#sql` is inferred to be a query expression of a `Bool` because this is what is
returned from `where`'s trailing closure.

Note that `$0.dueDate` is interpolated directly into the string and rendered as the underlying SQL
string. This shows that you can retain all the static guarantees provided by the `@Table` macro when
writing SQL strings. Also note that this is a completely safe form of interpolation and is not
simply using Swift's default string interpolation: query expressions are safely written into the
underlying SQL, and Swift values are safely bound as statement parameters, preventing SQL injection
attacks.

### SQL statements

It is even possible to write entire SQL statements using `#sql`. For example, the previous query
could be written as a single invocation of the macro:

```swift
#sql(
  """
  SELECT \(Reminder.columns) FROM \(Reminder.self)
  WHERE \(Reminder.dueDate) < date()
  """,
  as: Reminder.self
)
// SELECT
//   "reminders"."id",
//   "reminders"."title",
//   "reminders"."dueDate",
//   "reminders"."isCompleted"
// FROM "reminders"
// WHERE "reminders"."dueDate" < date()
```

All of the columns provided to trailing closures in the query builder are available statically on
each table type, so you can freely interpolate this schema information into the SQL string.

Note that the query's represented type cannot be inferred here, and so the `as` parameter is used
to let Swift know that we expect to decode the `Reminder` type when we execute the query.

If we omit the `as` parameter, a return type of `Void` is assumed, which is appropriate if we don't
expect any data to be returned from the statement, _e.g._ during a schema migration:

```swift
#sql(
  """
  ALTER TABLE "reminders"
  ADD COLUMN "notes" TEXT NOT NULL DEFAULT ''
  """
)
```

### SQL linting

The `#sql` macro introduces additional compile-time safety to ensure your SQL is syntactically
valid. For example, the following fragment contains a syntax error that might be hard to spot among
the many parentheses involved in the function calls and interpolation:

```swift
Reminder.where {
  #sql("NOT (length(\($0.notes) > length(\($1.title)))")
  // ⚠️ Cannot find ')' to match opening '(' in SQL string
}
```

The macro catches such issues at _compile_ time.

It also ensures that parameters are bound at appropriate parts of the SQL string, _e.g._ outside of
identifiers and text literals:

```swift
Reminder.select {
  #sql("'\($0.id.count()) rows'", as: String.self)
  // 🛑 Bind after opening "'" in SQL string
}
```

This lets us know that we've made a mistake, and should be doing the string concatenation ourselves:

```swift
Reminder.select {
  #sql("\($0.id.count()) || ' rows'", as: String.self)
}
```

## Topics

### Supporting types

- ``QueryFragment``
- ``SQLQueryExpression``
