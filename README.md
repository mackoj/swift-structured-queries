# Structured Queries

A library for building SQL in a safe, expressive, and composable manner.

## Overview

This library provides a suite of tools that empower you to write safe, expressive, composable SQL
with Swift. By simply attaching a macro to types that represent your database schema:

```swift
@Table
struct Reminder {
  let id: Int
  var isCompleted = false
  var priority: Int?
  var title = ""
}
```

You get instant access to a rich set of query building APIs:

```swift
Reminder.all
// SELECT
//   "reminders"."id",
//   "reminders".isCompleted",
//   "reminders"."priority",
//   "reminders"."title"
// FROM "reminders"
// => Reminder

Reminder
  .where { !$0.isCompleted }
  .group(by: \.priority)
  .order { $0.priority.desc() }
  .select { ($0.priority, $0.title.groupConcat()) }
// SELECT "reminders"."priority", group_concat("reminders"."title")
// FROM "reminders"
// WHERE (NOT "reminders"."isCompleted")
// GROUP BY "reminders"."priority"
// ORDER BY "reminders"."priority" DESC
// => (Int?, String)
```

These APIs help you avoid runtime issues caused by typos and type errors, but still embrace SQL for
what it is. Structured Queries is not an ORM or a new query language you have to learn: its APIs are
designed to read closely to the SQL it generates, though it is often more succinct, and always
safer.

> [!IMPORTANT]
> This library does not come with any database drivers for making actual database requests, _e.g._,
> to SQLite, Postgres, MySQL. This library focuses only on building SQL statements and providing the
> tools to integrate with another library that makes the actual database requests. See
> [Database drivers](#database-drivers) for more information.

## Documentation

The documentation for the latest unstable and stable releases are available here:

  * [`main`](https://swiftpackageindex.com/pointfreeco/swift-structured-queries/main/documentation/structuredqueriescore/)
  * [0.1.x](https://swiftpackageindex.com/pointfreeco/swift-structured-queries/~/documentation/structuredqueriescore/)

## Demos

There are a number of sample applications that demonstrate how to use Structured Queries in the
[SharingGRDB](https://github.com/pointfreeco/sharing-grdb) repo. Check out
[this](https://github.com/pointfreeco/sharing-grdb/tree/main/Examples) directory to see them all,
including:

  * [Case Studies](https://github.com/pointfreeco/sharing-grdb/tree/main/Examples/CaseStudies):
    A number of case studies demonstrating the built-in features of the library.

  * [Reminders](https://github.com/pointfreeco/sharing-grdb/tree/main/Examples/Reminders): A rebuild
    of Apple's [Reminders][reminders-app-store] app that uses a SQLite database to model the
    reminders, lists and tags. It features many advanced queries, such as searching, and stats
    aggregation.

  * [SyncUps](https://github.com/pointfreeco/sharing-grdb/tree/main/Examples/SyncUps): We also
    rebuilt Apple's [Scrumdinger][scrumdinger] demo application using modern, best practices for
    SwiftUI development, including using this library to query and persist state using SQLite.

[reminders-app-store]: https://apps.apple.com/us/app/reminders/id1108187841
[scrumdinger]: https://developer.apple.com/tutorials/app-dev-training/getting-started-with-scrumdinger

## Database drivers

Structured Queries is built with the goal of supporting any SQL database (SQLite, MySQL, Postgres,
_etc._), but is currently tuned to work with SQLite. It currently has one official driver:

  * [SharingGRDB](https://github.com/pointfreeco/sharing-grdb): A lightweight replacement for
    SwiftData and the `@Query` macro. SharingGRDB includes `StructuredQueriesGRDB`, a library that
    integrates this one with the popular [GRDB](https://github.com/groue/GRDB.swift) SQLite library.

If you are interested in building a Structured Queries integration for another database library,
please see [Integrating with database libraries][sq-docs-integration], and
[start a discussion](http://github.com/pointfreeco/swift-structured-queries/discussions/new/choose)
to let us know of any challenges you encounter.

[sq-docs-integration]: https://swiftpackageindex.com/pointfreeco/swift-structured-queries/main/documentation/structuredqueriescore/integration

## Installation

You can add Structured Queries to an Xcode project by adding it to your project as a package.

> https://github.com/pointfreeco/swift-sharing

If you want to use Structured Queries in a [SwiftPM](https://swift.org/package-manager/) project,
it's as simple as adding it to your `Package.swift`:

``` swift
dependencies: [
  .package(url: "https://github.com/pointfreeco/swift-structured_queries", from: "0.1.0")
]
```

And then adding the product to any target that needs access to the library:

```swift
.product(name: "StructuredQueries", package: "swift-structured-queries"),
```

## Learn more

This library was motivated and designed over the course of many episodes on
[Point-Free](https://www.pointfree.co), a video series exploring advanced programming topics in the
Swift language, hosted by [Brandon Williams](https://x.com/mbrandonw) and
[Stephen Celis](https://x.com/stephencelis).

<a href="https://www.pointfree.co/collections/sqlite/sql-building">
  <img alt="video poster image" src="https://d3rccdn33rt8ze.cloudfront.net/episodes/0317.jpeg" width="600">
</a>

## Community

If you want to discuss this library or have a question about how to use it to solve a particular
problem, there are a number of places you can discuss with fellow
[Point-Free](http://www.pointfree.co) enthusiasts:

  * For long-form discussions, we recommend the
    [discussions](http://github.com/pointfreeco/swift-structured-queries/discussions) tab of this
    repo.

  * For casual chat, we recommend the
    [Point-Free Community Slack](http://www.pointfree.co/slack-invite).

## License

This library is released under the MIT license. See [LICENSE](LICENSE) for details.
