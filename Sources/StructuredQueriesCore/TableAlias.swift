import StructuredQueriesSupport

/// A type identifying a table alias.
///
/// Conform to this protocol to provide an alias to a table.
///
/// This protocol contains a single, optional requirement, ``aliasName``, which is the string used
/// to use in the SQL `AS` clause. When left omitted, it will default to the same strategy applied
/// to table names in the `@Table` macro, which is a lowercased, pluralized version of the type
/// name.
///
/// ```swift
/// enum Referrer: AliasName {}
///
/// Referrer.aliasName  // "referrers"
/// ```
///
/// See ``Table/as(_:)`` for more information on using this conformance.
public protocol AliasName {
  /// The string used to alias a table, _e.g._ `"tableName" AS "aliasName"`.
  static var aliasName: String { get }
}

extension AliasName {
  public static var aliasName: String {
    _typeName(Self.self, qualified: false).lowerCamelCased().pluralized()
  }
}

extension Table {
  /// A table alias of this table type.
  ///
  /// This is useful for building queries where a table is joined multiple times. For example, a
  /// "users" table may have an optional `referrerID` column that points to another row in the
  /// table, and you may want to join on this constraint:
  ///
  /// ```swift
  /// @Table
  /// struct User {
  ///   let id: Int
  ///   var name = ""
  ///   var referrerID: Int?
  /// }
  /// ```
  ///
  /// To do so, define an ``AliasName`` for referrers and then build the appropriate query:
  ///
  /// ```swift
  /// enum Referrer: AliasName {}
  ///
  /// let usersWithReferrers = User
  ///   .join(User.as(Referrer.self).all) { $0.referrerID == $1.id }
  ///   .select { ($0.name, $1.name) }
  /// // SELECT "users"."name", "referrers.name"
  /// // FROM "users"
  /// // JOIN "users" AS "referrers"
  /// // ON "users"."referrerID" = "referrers"."id"
  /// ```
  ///
  /// - Parameter aliasName: An alias name for this table.
  /// - Returns: A table alias of this table type.
  public static func `as`<Name: AliasName>(_ aliasName: Name.Type) -> TableAlias<Self, Name>.Type {
    TableAlias.self
  }
}

/// An aliased table.
///
/// This type is returned from ``Table/as(_:)``.
public struct TableAlias<
  Base: Table,
  Name: AliasName  // We should use a value generic here when it's possible.
>: _OptionalPromotable, Table {
  public static var columns: TableColumns {
    TableColumns()
  }

  public static var tableName: String {
    Base.tableName
  }

  public static var tableAlias: String? {
    Name.aliasName
  }

  let base: Base

  subscript<Member: QueryRepresentable>(
    member _: KeyPath<Member, Member> & Sendable,
    column keyPath: KeyPath<Base, Member.QueryOutput> & Sendable
  ) -> Member.QueryOutput {
    base[keyPath: keyPath]
  }

  @dynamicMemberLookup
  public struct TableColumns: Schema {
    public static var allColumns: [any TableColumnExpression] {
      #if compiler(>=6.1)
        return Base.TableColumns.allColumns.map { $0._aliased(Name.self) }
      #else
        func open(_ column: some TableColumnExpression) -> any TableColumnExpression {
          column._aliased(Name.self)
        }
        return Base.TableColumns.allColumns.map { open($0) }
      #endif
    }

    public typealias QueryValue = TableAlias

    public subscript<Member>(
      dynamicMember keyPath: KeyPath<Base.TableColumns, TableColumn<Base, Member>>
    ) -> TableColumn<TableAlias, Member> {
      let column = Base.columns[keyPath: keyPath]
      return TableColumn<TableAlias, Member>(
        column.name,
        keyPath: \.[member: \Member.self, column: column._keyPath]
      )
    }
  }
}

extension TableAlias: PrimaryKeyedTable where Base: PrimaryKeyedTable {
  public typealias Draft = TableAlias<Base.Draft, Name>
}

extension TableAlias.TableColumns: PrimaryKeyedSchema where Base.TableColumns: PrimaryKeyedSchema {
  public typealias PrimaryKey = Base.TableColumns.PrimaryKey

  public var primaryKey: TableColumn<TableAlias, Base.TableColumns.PrimaryKey.QueryValue> {
    self[dynamicMember: \.primaryKey]
  }
}

extension TableAlias: QueryExpression where Base: QueryExpression {
  public typealias QueryValue = Base.QueryValue

  public var queryFragment: QueryFragment {
    base.queryFragment
  }
}

extension TableAlias: QueryBindable where Base: QueryBindable {
  public var queryBinding: QueryBinding {
    base.queryBinding
  }
}

extension TableAlias: QueryDecodable where Base: QueryDecodable {
  public init(decoder: inout some QueryDecoder) throws {
    try self.init(base: Base(decoder: &decoder))
  }
}

extension TableAlias: QueryRepresentable where Base: QueryRepresentable {
  public typealias QueryOutput = Base

  public init(queryOutput: Base) {
    self.init(base: queryOutput)
  }

  public var queryOutput: Base {
    base
  }
}

extension TableAlias: Sendable where Base: Sendable {}
