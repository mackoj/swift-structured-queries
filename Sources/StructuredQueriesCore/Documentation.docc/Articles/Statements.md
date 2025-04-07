# Statements

Learn how SQL's core statements (SELECT, INSERT, UPDATE, DELETE) are modeled in this library.

## Overview

The ``Statement`` protocol represents a fully formed SQL statement, and it unifies the various types
of statements in SQL, such as ``Select``, ``Insert``, ``Update``, and ``Delete``. Most queries one builds
with the library will give you some conformant to ``Statement``, such as selecting all reminders from a 
table:

```swift
let statement: some Statement = Reminder.all
```

As well as insert, update and delete queries:

```swift
_: some Statement = Reminder.insert { $0.title } values: { "Get groceries" }
_: some Statement = Reminder.update { $0.title = "Get groceries" }
_: some Statement = Reminder.delete()
```




Further, the ``Statement`` protocol has a primary associated type, ``QueryExpression/QueryValue``, which
represents the type of data that is ultimately decoded from the database after the statement is run. For 
example, select the

```swift
let statement: some Statement<Reminder> = Reminder.all
```

```swift
let statement: some Statement<(String, Bool)> = Reminder.select { ($0.title, $0.isCompleted) }
```

## Topics

### Types of statements

- <doc:Selects>
- <doc:Inserts>
- <doc:Updates>
- <doc:Deletes>
- <doc:WhereClauses>
