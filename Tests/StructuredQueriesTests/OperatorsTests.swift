import StructuredQueries
import Testing

@Table
private struct User {
  var id: Int
  var name: String
  var isAdmin: Bool
  var salary: Double
  var referrerID: Int?
}

struct OperatorsTests {
  @Test func equatable() {
    #expect(
      (User.columns.id == 1).sql == """
        ("users"."id" = ?)
        """
    )
    #expect(
      (User.columns.id != 1).sql == """
        ("users"."id" <> ?)
        """
    )
    #expect(
      (User.columns.id == 1).sql == """
        ("users"."id" = ?)
        """
    )
    #expect(
      (User.columns.id != 1).sql == """
        ("users"."id" <> ?)
        """
    )
    #expect(
      (User.columns.id == nil).sql == """
        ("users"."id" IS NULL)
        """
    )
    #expect(
      (User.columns.id != nil).sql == """
        ("users"."id" IS NOT NULL)
        """
    )
    var id: Int? = nil
    #expect(
      (User.columns.id == id).sql == """
        ("users"."id" IS ?)
        """
    )
    #expect(
      (User.columns.id != id).sql == """
        ("users"."id" IS NOT ?)
        """
    )
    id = 42
    #expect(
      (User.columns.id == id).sql == """
        ("users"."id" = ?)
        """
    )
    #expect(
      (User.columns.id != id).sql == """
        ("users"."id" <> ?)
        """
    )
    #expect(
      (User.columns.referrerID == 1).sql == """
        ("users"."referrerID" = ?)
        """
    )
    #expect(
      (User.columns.referrerID != 1).sql == """
        ("users"."referrerID" <> ?)
        """
    )
    #expect(
      (User.columns.referrerID == nil).sql == """
        ("users"."referrerID" IS NULL)
        """
    )
    #expect(
      (User.columns.referrerID != nil).sql == """
        ("users"."referrerID" IS NOT NULL)
        """
    )
    #expect(
      (User.columns.id == User.columns.referrerID).sql == """
        ("users"."id" = "users"."referrerID")
        """
    )
    #expect(
      (User.columns.id != User.columns.referrerID).sql == """
        ("users"."id" <> "users"."referrerID")
        """
    )
    #expect(
      (User.columns.referrerID == User.columns.id).sql == """
        ("users"."referrerID" = "users"."id")
        """
    )
    #expect(
      (User.columns.referrerID != User.columns.id).sql == """
        ("users"."referrerID" <> "users"."id")
        """
    )
  }

  @Test func coalesce() {
    #expect(
      (User.columns.referrerID ?? User.columns.id).sql == """
        coalesce("users"."referrerID", "users"."id")
        """
    )
    #expect(
      (User.columns.referrerID ?? 1).sql == """
        coalesce("users"."referrerID", ?)
        """
    )
    #expect(
      (User.columns.referrerID ?? nil).sql == """
        coalesce("users"."referrerID", NULL)
        """
    )
    #expect(
      (User.columns.referrerID ?? User.columns.referrerID).sql == """
        coalesce("users"."referrerID", "users"."referrerID")
        """
    )
  }

  @Test func comparable() {
    #expect(
      (User.columns.id < 1).sql == """
        ("users"."id" < ?)
        """
    )
    #expect(
      (User.columns.id > 1).sql == """
        ("users"."id" > ?)
        """
    )
    #expect(
      (User.columns.id <= 1).sql == """
        ("users"."id" <= ?)
        """
    )
    #expect(
      (User.columns.id >= 1).sql == """
        ("users"."id" >= ?)
        """
    )
  }

  @Test func boolean() {
    #expect(
      (User.columns.isAdmin && User.columns.isAdmin).sql == """
        ("users"."isAdmin" AND "users"."isAdmin")
        """
    )
    #expect(
      (User.columns.isAdmin || User.columns.isAdmin).sql == """
        ("users"."isAdmin" OR "users"."isAdmin")
        """
    )
    #expect(
      (!User.columns.isAdmin).sql == """
        NOT ("users"."isAdmin")
        """
    )
    var isAdmin = AnyQueryExpression(User.columns.isAdmin)
    isAdmin.toggle()
    #expect(isAdmin.sql == (!User.columns.isAdmin).sql)
  }

  @Test func arithmetic() {
    #expect(
      (User.columns.id + 1).sql == """
        ("users"."id" + ?)
        """
    )
    #expect(
      (User.columns.salary + 16.50).sql == """
        ("users"."salary" + ?)
        """
    )
    #expect(
      (User.columns.id - 1).sql == """
        ("users"."id" - ?)
        """
    )
    #expect(
      (User.columns.salary - 16.50).sql == """
        ("users"."salary" - ?)
        """
    )
    #expect(
      (User.columns.id * 1).sql == """
        ("users"."id" * ?)
        """
    )
    #expect(
      (User.columns.salary * 16.50).sql == """
        ("users"."salary" * ?)
        """
    )
    #expect(
      (User.columns.id / 1).sql == """
        ("users"."id" / ?)
        """
    )
    #expect(
      (User.columns.salary / 16.50).sql == """
        ("users"."salary" / ?)
        """
    )
    #expect(
      (-User.columns.id).sql == """
        -("users"."id")
        """
    )
    #expect(
      (-User.columns.salary).sql == """
        -("users"."salary")
        """
    )
    #expect(
      (+User.columns.id).sql == """
        +("users"."id")
        """
    )
    #expect(
      (+User.columns.salary).sql == """
        +("users"."salary")
        """
    )
    var id = AnyQueryExpression(User.columns.id)
    id += 1
    #expect(id.sql == (User.columns.id + 1).sql)

    var salary = AnyQueryExpression(User.columns.salary)
    salary += 1
    #expect(salary.sql == (User.columns.salary + 16.50).sql)

    id = AnyQueryExpression(User.columns.id)
    id -= 1
    #expect(id.sql == (User.columns.id - 1).sql)

    salary = AnyQueryExpression(User.columns.salary)
    salary -= 1
    #expect(salary.sql == (User.columns.salary - 16.50).sql)

    id = AnyQueryExpression(User.columns.id)
    id *= 1
    #expect(id.sql == (User.columns.id * 1).sql)

    salary = AnyQueryExpression(User.columns.salary)
    salary *= 1
    #expect(salary.sql == (User.columns.salary * 16.50).sql)

    id = AnyQueryExpression(User.columns.id)
    id /= 1
    #expect(id.sql == (User.columns.id / 1).sql)

    salary = AnyQueryExpression(User.columns.salary)
    salary /= 1
    #expect(salary.sql == (User.columns.salary / 16.50).sql)

    id = AnyQueryExpression(User.columns.id)
    id.negate()
    #expect(id.sql == (-User.columns.id).sql)

    salary = AnyQueryExpression(User.columns.salary)
    salary.negate()
    #expect(salary.sql == (-User.columns.salary).sql)
  }

  @Test func modulo() {
    #expect(
      (User.columns.id % 2).sql == """
        ("users"."id" % ?)
        """
    )
    var id = AnyQueryExpression(User.columns.id)
    id %= 2
    #expect(id.sql == (User.columns.id % 2).sql)
  }

  @Test func bitwise() {
    #expect(
      (User.columns.id & 2).sql == """
        ("users"."id" & ?)
        """
    )
    #expect(
      (User.columns.id | 2).sql == """
        ("users"."id" | ?)
        """
    )
    #expect(
      (User.columns.id << 2).sql == """
        ("users"."id" << ?)
        """
    )
    #expect(
      (User.columns.id >> 2).sql == """
        ("users"."id" >> ?)
        """
    )
    #expect(
      (~User.columns.id).sql == """
        ~("users"."id")
        """
    )
    var id = AnyQueryExpression(User.columns.id)
    id &= 2
    #expect(id.sql == (User.columns.id & 2).sql)

    id = AnyQueryExpression(User.columns.id)
    id |= 2
    #expect(id.sql == (User.columns.id | 2).sql)

    id = AnyQueryExpression(User.columns.id)
    id <<= 2
    #expect(id.sql == (User.columns.id << 2).sql)

    id = AnyQueryExpression(User.columns.id)
    id >>= 2
    #expect(id.sql == (User.columns.id >> 2).sql)
  }

  @Test func string() {
    #expect(
      (User.columns.name + ", Jr").sql == """
        ("users"."name" || ?)
        """
    )
    #expect(
      User.columns.name.collate(.binary).sql == """
        ("users"."name" COLLATE BINARY)
        """
    )
    #expect(
      User.columns.name.collate(.nocase).sql == """
        ("users"."name" COLLATE NOCASE)
        """
    )
    #expect(
      User.columns.name.collate(.rtrim).sql == """
        ("users"."name" COLLATE RTRIM)
        """
    )
    #expect(
      User.columns.name.collate(.binary).sql == """
        ("users"."name" COLLATE BINARY)
        """
    )
    #expect(
      User.columns.name.like("%foo%").sql == """
        ("users"."name" LIKE ?)
        """
    )
    #expect(
      User.columns.name.glob("*").sql == """
        ("users"."name" GLOB ?)
        """
    )
    do {
      let query = User.columns.name.hasPrefix("foo")
      #expect(
        query.sql == """
          ("users"."name" LIKE ?)
          """
      )
      #expect(query.bindings == [.text("foo%")])
    }
    do {
      let query = User.columns.name.hasSuffix("foo")
      #expect(
        query.sql == """
          ("users"."name" LIKE ?)
          """
      )
      #expect(query.bindings == [.text("%foo")])
    }
    do {
      let query = User.columns.name.contains("foo")
      #expect(
        query.sql == """
          ("users"."name" LIKE ?)
          """
      )
      #expect(query.bindings == [.text("%foo%")])
    }
    var name = AnyQueryExpression(User.columns.name)
    name += ", Jr"
    #expect(name.sql == (User.columns.name + ", Jr").sql)

    name = AnyQueryExpression(User.columns.name)
    name.append(", Jr")
    #expect(name.sql == (User.columns.name + ", Jr").sql)

    name = AnyQueryExpression(User.columns.name)
    name.append(contentsOf: ", Jr")
    #expect(name.sql == (User.columns.name + ", Jr").sql)
  }

  @Test func array() {
    #expect(
      ["Blob", "Blob Jr", "Blob Sr"].contains(User.columns.name).sql == """
        ("users"."name" IN (?, ?, ?))
        """
    )
  }

  @Test func range() {
    #expect(
      (1...10).contains(User.columns.id).sql == """
        ("users"."id" BETWEEN ? AND ?)
        """
    )
  }
}
