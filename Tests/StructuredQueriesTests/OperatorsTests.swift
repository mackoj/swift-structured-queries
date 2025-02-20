import Foundation
import InlineSnapshotTesting
import StructuredQueries
import Testing

extension SnapshotTests {
  struct OperatorsTests {
    @Table
    struct User {
      var id: Int
      var name: String
      var isAdmin: Bool
      var salary: Double
      var referrerID: Int?
    }

    @Test func equatable() {
      assertInlineSnapshot(of: User.columns.id == 1, as: .sql) {
        """
        ("users"."id" = 1)
        """
      }
      assertInlineSnapshot(of: User.columns.id != 1, as: .sql) {
        """
        ("users"."id" <> 1)
        """
      }
      assertInlineSnapshot(of: User.columns.id == nil, as: .sql) {
        """
        ("users"."id" IS NULL)
        """
      }
      assertInlineSnapshot(of: User.columns.id != nil, as: .sql) {
        """
        ("users"."id" IS NOT NULL)
        """
      }
      assertInlineSnapshot(of: User.columns.id == nil as Int?, as: .sql) {
        """
        ("users"."id" IS NULL)
        """
      }
      assertInlineSnapshot(of: User.columns.id != nil as Int?, as: .sql) {
        """
        ("users"."id" IS NOT NULL)
        """
      }
      assertInlineSnapshot(of: User.columns.id == 42 as Int?, as: .sql) {
        """
        ("users"."id" = 42)
        """
      }
      assertInlineSnapshot(of: User.columns.id != 42 as Int?, as: .sql) {
        """
        ("users"."id" <> 42)
        """
      }
      assertInlineSnapshot(of: User.columns.referrerID == 1, as: .sql) {
        """
        ("users"."referrerID" = 1)
        """
      }
      assertInlineSnapshot(of: User.columns.referrerID != 1, as: .sql) {
        """
        ("users"."referrerID" <> 1)
        """
      }
      assertInlineSnapshot(of: User.columns.referrerID == nil, as: .sql) {
        """
        ("users"."referrerID" IS NULL)
        """
      }
      assertInlineSnapshot(of: User.columns.referrerID != nil, as: .sql) {
        """
        ("users"."referrerID" IS NOT NULL)
        """
      }
      assertInlineSnapshot(of: User.columns.id == User.columns.referrerID, as: .sql) {
        """
        ("users"."id" = "users"."referrerID")
        """
      }
      assertInlineSnapshot(of: User.columns.id != User.columns.referrerID, as: .sql) {
        """
        ("users"."id" <> "users"."referrerID")
        """
      }
      assertInlineSnapshot(of: User.columns.referrerID == User.columns.id, as: .sql) {
        """
        ("users"."referrerID" = "users"."id")
        """
      }
      assertInlineSnapshot(of: User.columns.referrerID != User.columns.id, as: .sql) {
        """
        ("users"."referrerID" <> "users"."id")
        """
      }
    }

    @Test func coalesce() {
      assertInlineSnapshot(of: User.columns.referrerID ?? User.columns.id, as: .sql) {
        """
        coalesce("users"."referrerID", "users"."id")
        """
      }
      assertInlineSnapshot(of: User.columns.referrerID ?? 1, as: .sql) {
        """
        coalesce("users"."referrerID", 1)
        """
      }
      assertInlineSnapshot(of: User.columns.referrerID ?? nil, as: .sql) {
        """
        coalesce("users"."referrerID", NULL)
        """
      }
      assertInlineSnapshot(of: User.columns.referrerID ?? User.columns.referrerID, as: .sql) {
        """
        coalesce("users"."referrerID", "users"."referrerID")
        """
      }
    }

    @Test func comparable() {
      assertInlineSnapshot(of: User.columns.id < 1, as: .sql) {
        """
        ("users"."id" < 1)
        """
      }
      assertInlineSnapshot(of: User.columns.id > 1, as: .sql) {
        """
        ("users"."id" > 1)
        """
      }
      assertInlineSnapshot(of: User.columns.id <= 1, as: .sql) {
        """
        ("users"."id" <= 1)
        """
      }
      assertInlineSnapshot(of: User.columns.id >= 1, as: .sql) {
        """
        ("users"."id" >= 1)
        """
      }
    }

    @Test func boolean() {
      assertInlineSnapshot(of: User.columns.isAdmin && User.columns.isAdmin, as: .sql) {
        """
        ("users"."isAdmin" AND "users"."isAdmin")
        """
      }
      assertInlineSnapshot(of: User.columns.isAdmin || User.columns.isAdmin, as: .sql) {
        """
        ("users"."isAdmin" OR "users"."isAdmin")
        """
      }
      assertInlineSnapshot(of: !User.columns.isAdmin, as: .sql) {
        """
        NOT ("users"."isAdmin")
        """
      }

      var isAdmin = AnyQueryExpression(User.columns.isAdmin)
      isAdmin.toggle()
      #expect(isAdmin.queryFragment == (!User.columns.isAdmin).queryFragment)
    }

    @Test func arithmetic() {
      assertInlineSnapshot(of: User.columns.id + 1, as: .sql) {
        """
        ("users"."id" + 1)
        """
      }
      assertInlineSnapshot(of: User.columns.salary + 50, as: .sql) {
        """
        ("users"."salary" + 50.0)
        """
      }
      assertInlineSnapshot(of: User.columns.salary + 16.50, as: .sql) {
        """
        ("users"."salary" + 16.5)
        """
      }
      assertInlineSnapshot(of: User.columns.id - 1, as: .sql) {
        """
        ("users"."id" - 1)
        """
      }
      assertInlineSnapshot(of: User.columns.salary - 50, as: .sql) {
        """
        ("users"."salary" - 50.0)
        """
      }
      assertInlineSnapshot(of: User.columns.salary - 16.50, as: .sql) {
        """
        ("users"."salary" - 16.5)
        """
      }
      assertInlineSnapshot(of: User.columns.id * 1, as: .sql) {
        """
        ("users"."id" * 1)
        """
      }
      assertInlineSnapshot(of: User.columns.salary * 50, as: .sql) {
        """
        ("users"."salary" * 50.0)
        """
      }
      assertInlineSnapshot(of: User.columns.salary * 16.50, as: .sql) {
        """
        ("users"."salary" * 16.5)
        """
      }
      assertInlineSnapshot(of: User.columns.id / 1, as: .sql) {
        """
        ("users"."id" / 1)
        """
      }
      assertInlineSnapshot(of: User.columns.salary / 50, as: .sql) {
        """
        ("users"."salary" / 50.0)
        """
      }
      assertInlineSnapshot(of: User.columns.salary / 16.50, as: .sql) {
        """
        ("users"."salary" / 16.5)
        """
      }
      assertInlineSnapshot(of: -User.columns.id, as: .sql) {
        """
        -("users"."id")
        """
      }
      assertInlineSnapshot(of: -User.columns.salary, as: .sql) {
        """
        -("users"."salary")
        """
      }
      assertInlineSnapshot(of: +User.columns.id, as: .sql) {
        """
        +("users"."id")
        """
      }
      assertInlineSnapshot(of: +User.columns.salary, as: .sql) {
        """
        +("users"."salary")
        """
      }
      // TODO: add test for casting when supported
//      assertInlineSnapshot(
//        of: User.columns.name + " (" + User.columns.id.cast(String.self) + ")",
//        as: .sql
//      ) {
//        """
//        ((("users"."name" || ' (') || '') || ')')
//        """
//      }

      var id = AnyQueryExpression(User.columns.id)
      id += 1
      #expect(id.queryFragment == (User.columns.id + 1).queryFragment)

      var salary = AnyQueryExpression(User.columns.salary)
      salary += 16.50
      #expect(salary.queryFragment == (User.columns.salary + 16.50).queryFragment)

      id = AnyQueryExpression(User.columns.id)
      id -= 1
      #expect(id.queryFragment == (User.columns.id - 1).queryFragment)

      salary = AnyQueryExpression(User.columns.salary)
      salary -= 16.50
      #expect(salary.queryFragment == (User.columns.salary - 16.50).queryFragment)

      id = AnyQueryExpression(User.columns.id)
      id *= 1
      #expect(id.queryFragment == (User.columns.id * 1).queryFragment)

      salary = AnyQueryExpression(User.columns.salary)
      salary *= 16.50
      #expect(salary.queryFragment == (User.columns.salary * 16.50).queryFragment)

      id = AnyQueryExpression(User.columns.id)
      id /= 1
      #expect(id.queryFragment == (User.columns.id / 1).queryFragment)

      salary = AnyQueryExpression(User.columns.salary)
      salary /= 16.50
      #expect(salary.queryFragment == (User.columns.salary / 16.50).queryFragment)

      id = AnyQueryExpression(User.columns.id)
      id.negate()
      #expect(id.queryFragment == (-User.columns.id).queryFragment)

      salary = AnyQueryExpression(User.columns.salary)
      salary.negate()
      #expect(salary.queryFragment == (-User.columns.salary).queryFragment)
    }

    @Test func modulo() {
      assertInlineSnapshot(of: User.columns.id % 2, as: .sql) {
        """
        ("users"."id" % 2)
        """
      }

      var id = AnyQueryExpression(User.columns.id)
      id %= 2
      #expect(id.queryFragment == (User.columns.id % 2).queryFragment)
    }

    @Test func bitwise() {
      assertInlineSnapshot(of: User.columns.id & 2, as: .sql) {
        """
        ("users"."id" & 2)
        """
      }
      assertInlineSnapshot(of: User.columns.id | 2, as: .sql) {
        """
        ("users"."id" | 2)
        """
      }
      assertInlineSnapshot(of: User.columns.id << 2, as: .sql) {
        """
        ("users"."id" << 2)
        """
      }
      assertInlineSnapshot(of: User.columns.id >> 2, as: .sql) {
        """
        ("users"."id" >> 2)
        """
      }
      assertInlineSnapshot(of: ~User.columns.id, as: .sql) {
        """
        ~("users"."id")
        """
      }

      var id = AnyQueryExpression(User.columns.id)
      id &= 2
      #expect(id.queryFragment == (User.columns.id & 2).queryFragment)

      id = AnyQueryExpression(User.columns.id)
      id |= 2
      #expect(id.queryFragment == (User.columns.id | 2).queryFragment)

      id = AnyQueryExpression(User.columns.id)
      id <<= 2
      #expect(id.queryFragment == (User.columns.id << 2).queryFragment)

      id = AnyQueryExpression(User.columns.id)
      id >>= 2
      #expect(id.queryFragment == (User.columns.id >> 2).queryFragment)
    }

    @Test func string() {
      assertInlineSnapshot(of: User.columns.name + ", Jr", as: .sql) {
        """
        ("users"."name" || ', Jr')
        """
      }
      assertInlineSnapshot(of: User.columns.name.collate(.binary), as: .sql) {
        """
        ("users"."name" COLLATE BINARY)
        """
      }
      assertInlineSnapshot(of: User.columns.name.collate(.nocase), as: .sql) {
        """
        ("users"."name" COLLATE NOCASE)
        """
      }
      assertInlineSnapshot(of: User.columns.name.collate(.rtrim), as: .sql) {
        """
        ("users"."name" COLLATE RTRIM)
        """
      }
      assertInlineSnapshot(of: User.columns.name.like("%Blob%"), as: .sql) {
        """
        ("users"."name" LIKE '%Blob%')
        """
      }
      assertInlineSnapshot(of: User.columns.name.glob("*"), as: .sql) {
        """
        ("users"."name" GLOB '*')
        """
      }
      assertInlineSnapshot(of: User.columns.name.contains("Blob"), as: .sql) {
        """
        ("users"."name" LIKE '%Blob%')
        """
      }
      assertInlineSnapshot(of: User.columns.name.hasPrefix("Blob"), as: .sql) {
        """
        ("users"."name" LIKE 'Blob%')
        """
      }
      assertInlineSnapshot(of: User.columns.name.hasSuffix("Jr"), as: .sql) {
        """
        ("users"."name" LIKE '%Jr')
        """
      }

      var name = AnyQueryExpression(User.columns.name)
      name += ", Jr"
      #expect(name.queryFragment == (User.columns.name + ", Jr").queryFragment)

      name = AnyQueryExpression(User.columns.name)
      name.append(", Jr")
      #expect(name.queryFragment == (User.columns.name + ", Jr").queryFragment)

      name = AnyQueryExpression(User.columns.name)
      name.append(contentsOf: ", Jr")
      #expect(name.queryFragment == (User.columns.name + ", Jr").queryFragment)
    }

    @Test func array() {
      assertInlineSnapshot(
        of: ["Blob", "Blob Jr", "Blob Sr"].contains(User.columns.name),
        as: .sql
      ) {
        """
        ("users"."name" IN ('Blob', 'Blob Jr', 'Blob Sr'))
        """
      }
    }

    @Test func range() {
      assertInlineSnapshot(of: (1...10).contains(User.columns.id), as: .sql) {
        """
        ("users"."id" BETWEEN 1 AND 10)
        """
      }
    }
  }
}
