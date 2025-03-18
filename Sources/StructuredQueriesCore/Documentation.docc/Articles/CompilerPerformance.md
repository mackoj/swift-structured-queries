# Compiler Performance

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

### The problem


```swift
@Table struct Reminder {
  let id: Int 
  var title = ""
  var isCompleted = false 
  var priority: Int?
}

Reminder
  .where { !$0.isCompleted && $0.priority == 3 }
```

### Method operators

By far the easiest way to mitigate compiler performance problems in complex expressions is to use
the method version of the various operators SQL (and this library) has to offer. For example,
when joining two tables, rather than checking for equality of a foreign key relationship using
`==`, you can use the ``QueryExpression/eq(_:)`` function:

```diff
 ReminderList
   .join(Reminder.all()) {
-    $0.id == $0.reminderListID
+    $0.id.eq($0.reminderListID)
   }
```

The overload space for `eq` is much, _much_ smaller than `==`, and using it is only a single 
character more than using `==`.

The same goes for any mathematical operator supported by SQL, such as `&&`, `||`, `!`, etc. You can
start out using those operators, but if you notice a compiler slowdown, your first instinct should
be to convert a few of those operators to their method variant, ``QueryExpression/and(_:)``,
``QueryExpression/or(_:)``, ``QueryExpression/not()``. 

Often one does not need to convert _every_ operator to the method style. You can usually do it for
just a few operators to get a big boost, and we recommend starting with `==`.

### The #sql macro

The library ships with an "escape hatch" into a SQL string via the `#sql` macro. Importantly, this
is not an unsafe escape hatch. You can still use your data type's structure to refer to its columns,
and any value interpolated into

```swift
Reminder
  .where { 
    #sql("coalesce(\($0.date), date('now')) < date('now')")
  }
```
