# Compiler performance

Learn how to write complex queries that do not tax the compiler too much in order to keep compile
times quick.

## Overview

The library makes use of overloaded operators in order to allow you to write SQL queries in a 
syntax that mimics what SQL actually looks like, while also being true to how Swift code is written.
This typically works without any problems, but for very complex queries, especially ones involving
joins, the compiler can have trouble figuring out the types involved with the overloaded operators.
The library provides a few tools to help mitigate this problem so that you can continue reaping the
benefits of type-safety and expressivity in your queries, while also helping out Swift in compiling
your queries.

### Method operators

By far the easiest way to mitigate compiler performance problems in complex expressions is to use
the method version of the various operators SQL has to offer, e.g. using ``QueryExpression/eq(_:)``
instead of ``QueryExpression/==(_:_:)``. Consider a database schema that has a "reminders" table, a
"tags" table, as well as a many-to-many join table that can associated any number of tags to any
number of reminders:

```swift
@Table struct Reminder: Identifiable {
  let id: Int 
  var title = ""
  var isCompleted = false 
}
@Table struct Tag: Identifiable {
  let id: Int 
  var title = ""
}
@Table struct ReminderTag {
  let reminderID: Reminder.ID 
  let tagID: Tag.ID
}
```

With this schema it is possible to write a query that selects all reminders' titles, along with a 
comma-separated string of every tag associated with each reminder:

```swift
Reminder
  .group(by: \.id)
  .join(ReminderTag.all) { $0.id == $1.reminderID }
  .join(Tag.all) { $1.tagID == $2.id }
  .select { ($0.title, $2.title.groupConcat()) }
// SELECT "reminders"."title", group_concat("tags"."title")
// FROM "reminders"
// JOIN "reminderTags" ON "reminders"."id" = "reminderTags"."reminderID"
// JOIN "tags" ON "reminderTags"."tagID" = "tags"."id"
// GROUP BY "reminders"."id"
```

While this is a moderately complex query, it is definitely something that should compile quite 
quickly, but unfortunately Swift currently cannot type-check it quickly enough (as of Swift 6.1).
The problem is that the overload space of `==` is so large that Swift has too many possibilities 
to choose from when compiling this expression.

The easiest fix is to use the dedicated ``QueryExpression/eq(_:)`` methods that have a much 
smaller overload space:

```diff
 Reminder
   .group(by: \.id)
-  .join(ReminderTag.all) { $0.id == $1.reminderID }
+  .join(ReminderTag.all) { $0.id.eq($1.reminderID) }
-  .join(Tag.all) { $1.tagID == $2.id }
+  .join(Tag.all) { $1.tagID.eq($2.id) }
   .select { ($0.title, $2.title.groupConcat()) }
```

With that one change the expression now compiles immediately. We find that the equality operator
is by far the worst when it comes to compilation speed, and so we always recommend using 
``QueryExpression/eq(_:)`` over ``QueryExpression/==(_:_:)``, but other operators can benefit 
from this too if you notice problems, such as ``QueryExpression/neq(_:)`` over 
``QueryExpression/!=(_:_:)``, ``QueryExpression/gt(_:)`` over ``QueryExpression/>(_:_:)``, and so 
on. Here is a table of method equivalents of the most common operators:

| Method          | Operator      |
| --------------- | ------------- |
| `lhs == rhs`       | `lhs.eq(rhs)`     |
|                    | `lhs.is(rhs)`     |
| `lhs != rhs`       |    `lhs.neq(rhs)` |
|                    | `lhs.isNot(rhs)`  |
| `lhs && rhs`       | `lhs.and(rhs)`    |
| `lhs \|\| rhs`     |  `lhs.or(rhs)`    |
| `!value`           |  `value.not()`    |
| `lhs < rhs`        |  `lhs.lt(rhs)`    |
| `lhs > rhs`        |  `lhs.gt(rhs)`    |
| `lhs <= rhs`       |  `lhs.lte(rhs)`   |
| `lhs >= rhs`       |  `lhs.gte(rhs)`   |

Often one does not need to convert _every_ operator to the method style. You can usually do it for
just a few operators to get a big boost, and we recommend starting with `==`.

### The #sql macro

The library ships with a tool that allows one to write safe SQL strings via the `#sql` macro. Usage
of the `#sql` macro does not affect the safetly of your queries from SQL injection attacks, nor
does it prevent you making use of your table's schema in the query. The primary downside to using
`#sql` is that it can complicate decoding query results into custom types, but when used for small
fragments of a query one typically avoids such complications.

And because `#sql` works on a simple string, it is capable of being compiled much faster than the
equivalent version using the builder syntax with operators. Consider the following query that
selects all reminders with no due date, or whose due date is in the past:

```sql
SELECT *
FROM "reminders"
WHERE
  coalesce("reminders"."date", date('now')) <= date('now')
```

One can theoretically write the `coalesce` SQL fragment using the query building tools of this 
library, but doing so can be overhanded and obscure what the query is trying to do. For this 
very specific, complex logic it can be beneficial to use the `#sql` macro to write the fragment
directly as SQL:

```swift
Reminder
  .where { 
    #sql("coalesce(\($0.date), date('now')) <= date('now')")
  }
```

This generates the same query but we use the `#sql` tool for just the small fragment of SQL that 
we do not want to recreate in the builder. We are still protected from SQL injection attacks
with this tool, and we are even able to use the the statically defined columns of our type via
interpolation, but it should compile immediately compared to trying to piece together the complex
expression with the tools of the builder.
