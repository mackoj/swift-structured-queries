@attached(
  extension,
  conformances: Table, PrimaryKeyedTable,
  names: named(Columns), named(Draft), named(columns), named(queryFragment), named(init(decoder:)), named(name)
)
@attached(
  memberAttribute
)
public macro Table(_ name: String? = nil) =
  #externalMacro(
    module: "StructuredQueriesMacros", type: "TableMacro"
  )

@attached(accessor, names: named(willSet))
public macro Column(_ name: String? = nil, primaryKey: Bool = false) =
  #externalMacro(
    module: "StructuredQueriesMacros", type: "ColumnMacro"
  )

@attached(accessor, names: named(willSet))
public macro Column<Strategy: QueryBindingStrategy>(
  _ name: String? = nil,
  as strategy: Strategy,
  primaryKey: Bool = false
) =
  #externalMacro(
    module: "StructuredQueriesMacros", type: "ColumnMacro"
  )

@attached(
  extension,
  conformances: QueryDecodable,
  names: named(Columns),
  named(init(decoder:))
)
public macro Selection() =
#externalMacro(
  module: "StructuredQueriesMacros", type: "SelectionMacro"
)

import Foundation

//@Table
struct User {
  let id: Int
  @Column(as: .iso8601)
  var date: Date?
}
extension User: StructuredQueries.Table, StructuredQueries.PrimaryKeyedTable {
    public struct Columns: StructuredQueries.PrimaryKeyedSchema {
        public typealias QueryOutput = User
        public let id = StructuredQueries.Column<QueryOutput, Int>("id", keyPath: \.id)
        public let date = StructuredQueries.Column<QueryOutput, _>("date", keyPath: \.date, as: .iso8601)
        public var primaryKey: some StructuredQueries.ColumnExpression<QueryOutput> & StructuredQueries.QueryExpression<Int> {
            self.id
        }
        public var allColumns: [any StructuredQueries.ColumnExpression<QueryOutput>] {
            [self.id, self.date]
        }
    }
    public struct Draft: StructuredQueries.Draft {
        var date: Date?
        public struct Columns: StructuredQueries.DraftSchema {
            public typealias QueryOutput = Draft
            public let date = StructuredQueries.DraftColumn<QueryOutput, _>("date", keyPath: \.date, as: .iso8601)
            public var allColumns: [any StructuredQueries.ColumnExpression<QueryOutput>] {
                [self.date]
            }
        }
        public static let columns = Columns()
        public var queryFragment: QueryFragment {
            var sql: QueryFragment = "("
            sql.append(
                [
                    Self.columns.date.encode(self.date)
                ]
                .joined(separator: ", ")
            )
            sql.append(")")
            return sql
        }
    }
    public static let columns = Columns()
    public static let name = "users"
    public init(decoder: some StructuredQueries.QueryDecoder) throws {
        self.id = try Self.columns.id.decode(decoder: decoder)
        self.date = try Self.columns.date.decode(decoder: decoder)
    }
    public var queryFragment: QueryFragment {
        var sql: QueryFragment = "("
        sql.append(
            [
                Self.columns.id.encode(self.id),
                Self.columns.date.encode(self.date)
            ]
            .joined(separator: ", ")
        )
        sql.append(")")
        return sql
    }
}
