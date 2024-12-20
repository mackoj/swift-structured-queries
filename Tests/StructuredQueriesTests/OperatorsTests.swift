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
      (User.columns.id == 1).queryString == """
        ("users"."id" = ?)
        """
    )
    #expect(
      (User.columns.id != 1).queryString == """
        ("users"."id" <> ?)
        """
    )
    #expect(
      (User.columns.id == 1).queryString == """
        ("users"."id" = ?)
        """
    )
    #expect(
      (User.columns.id != 1).queryString == """
        ("users"."id" <> ?)
        """
    )
    #expect(
      (User.columns.id == nil).queryString == """
        ("users"."id" IS NULL)
        """
    )
    #expect(
      (User.columns.id != nil).queryString == """
        ("users"."id" IS NOT NULL)
        """
    )
    var id: Int? = nil
    #expect(
      (User.columns.id == id).queryString == """
        ("users"."id" IS ?)
        """
    )
    #expect(
      (User.columns.id != id).queryString == """
        ("users"."id" IS NOT ?)
        """
    )
    id = 42
    #expect(
      (User.columns.id == id).queryString == """
        ("users"."id" = ?)
        """
    )
    #expect(
      (User.columns.id != id).queryString == """
        ("users"."id" <> ?)
        """
    )
    #expect(
      (User.columns.referrerID == 1).queryString == """
        ("users"."referrerID" = ?)
        """
    )
    #expect(
      (User.columns.referrerID != 1).queryString == """
        ("users"."referrerID" <> ?)
        """
    )
    #expect(
      (User.columns.referrerID == nil).queryString == """
        ("users"."referrerID" IS NULL)
        """
    )
    #expect(
      (User.columns.referrerID != nil).queryString == """
        ("users"."referrerID" IS NOT NULL)
        """
    )
    #expect(
      (User.columns.id == User.columns.referrerID).queryString == """
        ("users"."id" = "users"."referrerID")
        """
    )
    #expect(
      (User.columns.id != User.columns.referrerID).queryString == """
        ("users"."id" <> "users"."referrerID")
        """
    )
    #expect(
      (User.columns.referrerID == User.columns.id).queryString == """
        ("users"."referrerID" = "users"."id")
        """
    )
    #expect(
      (User.columns.referrerID != User.columns.id).queryString == """
        ("users"."referrerID" <> "users"."id")
        """
    )
  }

  @Test func coalesce() {
    #expect(
      (User.columns.referrerID ?? User.columns.id).queryString == """
        coalesce("users"."referrerID", "users"."id")
        """
    )
    #expect(
      (User.columns.referrerID ?? 1).queryString == """
        coalesce("users"."referrerID", ?)
        """
    )
    #expect(
      (User.columns.referrerID ?? nil).queryString == """
        coalesce("users"."referrerID", NULL)
        """
    )
    #expect(
      (User.columns.referrerID ?? User.columns.referrerID).queryString == """
        coalesce("users"."referrerID", "users"."referrerID")
        """
    )
  }

  @Test func comparable() {
    #expect(
      (User.columns.id < 1).queryString == """
        ("users"."id" < ?)
        """
    )
    #expect(
      (User.columns.id > 1).queryString == """
        ("users"."id" > ?)
        """
    )
    #expect(
      (User.columns.id <= 1).queryString == """
        ("users"."id" <= ?)
        """
    )
    #expect(
      (User.columns.id >= 1).queryString == """
        ("users"."id" >= ?)
        """
    )
  }

  @Test func boolean() {
    #expect(
      (User.columns.isAdmin && User.columns.isAdmin).queryString == """
        ("users"."isAdmin" AND "users"."isAdmin")
        """
    )
    #expect(
      (User.columns.isAdmin || User.columns.isAdmin).queryString == """
        ("users"."isAdmin" OR "users"."isAdmin")
        """
    )
    #expect(
      (!User.columns.isAdmin).queryString == """
        NOT ("users"."isAdmin")
        """
    )
    var isAdmin = AnyQueryExpression(User.columns.isAdmin)
    isAdmin.toggle()
    #expect(isAdmin.queryString == (!User.columns.isAdmin).queryString)
  }

  @Test func arithmetic() {
    #expect(
      (User.columns.id + 1).queryString == """
        ("users"."id" + ?)
        """
    )
    #expect(
      (User.columns.salary + 16.50).queryString == """
        ("users"."salary" + ?)
        """
    )
    #expect(
      (User.columns.id - 1).queryString == """
        ("users"."id" - ?)
        """
    )
    #expect(
      (User.columns.salary - 16.50).queryString == """
        ("users"."salary" - ?)
        """
    )
    #expect(
      (User.columns.id * 1).queryString == """
        ("users"."id" * ?)
        """
    )
    #expect(
      (User.columns.salary * 16.50).queryString == """
        ("users"."salary" * ?)
        """
    )
    #expect(
      (User.columns.id / 1).queryString == """
        ("users"."id" / ?)
        """
    )
    #expect(
      (User.columns.salary / 16.50).queryString == """
        ("users"."salary" / ?)
        """
    )
    #expect(
      (-User.columns.id).queryString == """
        -("users"."id")
        """
    )
    #expect(
      (-User.columns.salary).queryString == """
        -("users"."salary")
        """
    )
    #expect(
      (+User.columns.id).queryString == """
        +("users"."id")
        """
    )
    #expect(
      (+User.columns.salary).queryString == """
        +("users"."salary")
        """
    )
    var id = AnyQueryExpression(User.columns.id)
    id += 1
    #expect(id.queryString == (User.columns.id + 1).queryString)

    var salary = AnyQueryExpression(User.columns.salary)
    salary += 1
    #expect(salary.queryString == (User.columns.salary + 16.50).queryString)

    id = AnyQueryExpression(User.columns.id)
    id -= 1
    #expect(id.queryString == (User.columns.id - 1).queryString)

    salary = AnyQueryExpression(User.columns.salary)
    salary -= 1
    #expect(salary.queryString == (User.columns.salary - 16.50).queryString)

    id = AnyQueryExpression(User.columns.id)
    id *= 1
    #expect(id.queryString == (User.columns.id * 1).queryString)

    salary = AnyQueryExpression(User.columns.salary)
    salary *= 1
    #expect(salary.queryString == (User.columns.salary * 16.50).queryString)

    id = AnyQueryExpression(User.columns.id)
    id /= 1
    #expect(id.queryString == (User.columns.id / 1).queryString)

    salary = AnyQueryExpression(User.columns.salary)
    salary /= 1
    #expect(salary.queryString == (User.columns.salary / 16.50).queryString)

    id = AnyQueryExpression(User.columns.id)
    id.negate()
    #expect(id.queryString == (-User.columns.id).queryString)

    salary = AnyQueryExpression(User.columns.salary)
    salary.negate()
    #expect(salary.queryString == (-User.columns.salary).queryString)
  }

  @Test func modulo() {
    #expect(
      (User.columns.id % 2).queryString == """
        ("users"."id" % ?)
        """
    )
    var id = AnyQueryExpression(User.columns.id)
    id %= 2
    #expect(id.queryString == (User.columns.id % 2).queryString)
  }

  @Test func bitwise() {
    #expect(
      (User.columns.id & 2).queryString == """
        ("users"."id" & ?)
        """
    )
    #expect(
      (User.columns.id | 2).queryString == """
        ("users"."id" | ?)
        """
    )
    #expect(
      (User.columns.id << 2).queryString == """
        ("users"."id" << ?)
        """
    )
    #expect(
      (User.columns.id >> 2).queryString == """
        ("users"."id" >> ?)
        """
    )
    #expect(
      (~User.columns.id).queryString == """
        ~("users"."id")
        """
    )
    var id = AnyQueryExpression(User.columns.id)
    id &= 2
    #expect(id.queryString == (User.columns.id & 2).queryString)

    id = AnyQueryExpression(User.columns.id)
    id |= 2
    #expect(id.queryString == (User.columns.id | 2).queryString)

    id = AnyQueryExpression(User.columns.id)
    id <<= 2
    #expect(id.queryString == (User.columns.id << 2).queryString)

    id = AnyQueryExpression(User.columns.id)
    id >>= 2
    #expect(id.queryString == (User.columns.id >> 2).queryString)
  }

  @Test func string() {
    #expect(
      (User.columns.name + ", Jr").queryString == """
        ("users"."name" || ?)
        """
    )
    #expect(
      User.columns.name.collate(.binary).queryString == """
        ("users"."name" COLLATE BINARY)
        """
    )
    #expect(
      User.columns.name.collate(.nocase).queryString == """
        ("users"."name" COLLATE NOCASE)
        """
    )
    #expect(
      User.columns.name.collate(.rtrim).queryString == """
        ("users"."name" COLLATE RTRIM)
        """
    )
    #expect(
      User.columns.name.collate(.binary).queryString == """
        ("users"."name" COLLATE BINARY)
        """
    )
    #expect(
      User.columns.name.like("%foo%").queryString == """
        ("users"."name" LIKE ?)
        """
    )
    #expect(
      User.columns.name.glob("*").queryString == """
        ("users"."name" GLOB ?)
        """
    )
    do {
      let query = User.columns.name.hasPrefix("foo")
      #expect(
        query.queryString == """
          ("users"."name" LIKE ?)
          """
      )
      #expect(query.queryBindings == [.text("foo%")])
    }
    do {
      let query = User.columns.name.hasSuffix("foo")
      #expect(
        query.queryString == """
          ("users"."name" LIKE ?)
          """
      )
      #expect(query.queryBindings == [.text("%foo")])
    }
    do {
      let query = User.columns.name.contains("foo")
      #expect(
        query.queryString == """
          ("users"."name" LIKE ?)
          """
      )
      #expect(query.queryBindings == [.text("%foo%")])
    }
    var name = AnyQueryExpression(User.columns.name)
    name += ", Jr"
    #expect(name.queryString == (User.columns.name + ", Jr").queryString)

    name = AnyQueryExpression(User.columns.name)
    name.append(", Jr")
    #expect(name.queryString == (User.columns.name + ", Jr").queryString)

    name = AnyQueryExpression(User.columns.name)
    name.append(contentsOf: ", Jr")
    #expect(name.queryString == (User.columns.name + ", Jr").queryString)
  }

  @Test func array() {
    #expect(
      ["Blob", "Blob Jr", "Blob Sr"].contains(User.columns.name).queryString == """
        ("users"."name" IN (?, ?, ?))
        """
    )
  }

  @Test func range() {
    #expect(
      (1...10).contains(User.columns.id).queryString == """
        ("users"."id" BETWEEN ? AND ?)
        """
    )
  }
}
