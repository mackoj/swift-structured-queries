import Dependencies
import Foundation
import InlineSnapshotTesting
import StructuredQueries
import Testing

extension SnapshotTests {
  @Suite struct ValuesTests {
    @Dependency(\.defaultDatabase) var db

    @Test func basics() {
      assertQuery(Values(1, "Hello", true)) {
        """
        SELECT 1, 'Hello', 1
        """
      } results: {
        """
        ┌───┬─────────┬──────┐
        │ 1 │ "Hello" │ true │
        └───┴─────────┴──────┘
        """
      }
    }

    @Test func union() {
      assertQuery(
        Values(1, "Hello", true)
          .union(Values(2, "Goodbye", false))
      ) {
        """
        SELECT 1, 'Hello', 1 UNION SELECT 2, 'Goodbye', 0
        """
      } results: {
        """
        ┌───┬───────────┬───────┐
        │ 1 │ "Hello"   │ true  │
        │ 2 │ "Goodbye" │ false │
        └───┴───────────┴───────┘
        """
      }
    }

    @Test func selectColumns() {
      assertQuery(
        Values(WorksForAlice(id: 42, name: "Blob"))
      ) {
        """
        SELECT (SELECT 42 AS "id", 'Blob' AS "name")
        """
      } results: {
        """
        sub-select returns 2 columns - expected 1
        """
      }
    }

    // TODO: Move to CTE tests file
    @Test func recursiveCTE() {
      assertQuery(
        With {
          Count(value: 1)
            .union(Count.select { Count.Columns(value: $0.value + 1) })
        } query: {
          Count.limit(4)
        }
      ) {
        """
        WITH "counts" AS (SELECT 1 AS "value" UNION SELECT ("counts"."value" + 1) AS "value" FROM "counts") SELECT "counts"."value" FROM "counts" LIMIT 4
        """
      } results: {
        """
        ┌─────────────────┐
        │ Count(value: 1) │
        │ Count(value: 2) │
        │ Count(value: 3) │
        │ Count(value: 4) │
        └─────────────────┘
        """
      }
    }

    @Test func avg() throws {
      try db.execute(
        """
        CREATE TABLE "employees" (
          "id" INTEGER PRIMARY KEY AUTOINCREMENT,
          "bossID" INTEGER REFERENCES "employees",
          "height" INTEGER NOT NULL,
          "name" TEXT NOT NULL
        )
        """
      )
      try db.execute(
        Employee.insert([
          Employee.Draft(name: "Root", bossID: nil, height: 100),
          Employee.Draft(name: "Alice", bossID: 1, height: 120),
          Employee.Draft(name: "Blob", bossID: 2, height: 90),
          Employee.Draft(name: "Blob Jr", bossID: 3, height: 80),
          Employee.Draft(name: "Blob Sr", bossID: 3, height: 150),
          Employee.Draft(name: "Blob Esq", bossID: 1, height: 1000),
        ])
      )

      // TODO: Cannot currently put select before join
      assertQuery(
        With {
          WorksForAlice(id: 2, name: "Alice")
            .union(
              Employee
                .join(WorksForAlice.all()) { $0.bossID == $1.id }
                .select { e, _ in WorksForAlice.Columns(id: e.id, name: e.name) }
            )
        } query: {
          Employee.select { $0.height.avg() }
            .where { $0.name.in(WorksForAlice.select(\.name)) && $0.id.neq(2) }
        }
      ) {
        """
        WITH "worksForAlices" AS (SELECT 2 AS "id", 'Alice' AS "name" UNION SELECT "employees"."id" AS "id", "employees"."name" AS "name" FROM "employees" JOIN "worksForAlices" ON ("employees"."bossID" = "worksForAlices"."id")) SELECT avg("employees"."height") FROM "employees" WHERE (("employees"."name" IN (SELECT "worksForAlices"."name" FROM "worksForAlices")) AND ("employees"."id" <> 2))
        """
      } results: {
        """
        ┌────────────────────┐
        │ 106.66666666666667 │
        └────────────────────┘
        """
      }

      assertQuery(
        // TODO: figure out ".query" subtlety, query vs queryFragment
        #sql(
          """
          WITH "worksForAlices" AS (
            \(WorksForAlice(id: 2, name: "Alice").query)
            UNION 
            SELECT \(Employee.id), \(Employee.name)
            FROM \(Employee.self) 
            JOIN \(WorksForAlice.self) ON (\(Employee.bossID) = \(WorksForAlice.id))
          ) 
          SELECT \(Employee.height.avg())
          FROM \(Employee.self) 
          WHERE \(Employee.name) IN \(WorksForAlice.select(\.name)) AND \(Employee.id) <> 2
          """,
          as: Double.self
        )
      ) {
        """
        WITH "worksForAlices" AS (
          SELECT 2 AS "id", 'Alice' AS "name"
          UNION 
          SELECT "employees"."id", "employees"."name"
          FROM "employees" 
          JOIN "worksForAlices" ON ("employees"."bossID" = "worksForAlices"."id")
        ) 
        SELECT avg("employees"."height")
        FROM "employees" 
        WHERE "employees"."name" IN (SELECT "worksForAlices"."name" FROM "worksForAlices") AND "employees"."id" <> 2
        """
      } results: {
        """
        ┌────────────────────┐
        │ 106.66666666666667 │
        └────────────────────┘
        """
      }
    }

    // TODO: Get an example of tree printing
    // https://www.sqlite.org/lang_with.html
  }
}

// TODO: Should '@Table @Selection' automatically add _SelectStatement conformance? Or can we do with protocol extension?
@Table @Selection
struct Count: _SelectStatement {
  typealias From = Never
  typealias QueryValue = Self
  let value: Int
  var queryFragment: StructuredQueriesCore.QueryFragment {
    "\(value) AS \"value\""
  }
  var query: QueryFragment {
    "SELECT \(queryFragment)"
  }
}

@Table struct Employee {
  let id: Int
  let name: String
  let bossID: Int?
  let height: Int
}
@Table @Selection struct WorksForAlice {
  let id: Int
  let name: String
}
extension WorksForAlice: _SelectStatement, QueryExpression {
  typealias From = Never

  //  var queryFragment: StructuredQueriesCore.QueryFragment {
  //    #"\#(id) AS "id", \#(bind: name) AS "name""#
  //  }
  var query: QueryFragment {
    """
    SELECT \(id) AS "id", \(bind: name) AS "name"
    """
  }
  typealias QueryValue = Self
}

//extension Table where Self: QueryExpression {
//  public typealias QueryValue = Self
//  public var queryFragment: QueryFragment {
//    func open<Root, Value>(_ column: some TableColumnExpression<Root, Value>) -> QueryFragment {
//      let root = self as! Root
//      let value = Value(queryOutput: root[keyPath: column.keyPath])
//      return "\(value) AS \(quote: column.name)"
//    }
//    return Self.columns.allColumns.map { open($0) }.joined(separator: ", ")
//  }
//}
