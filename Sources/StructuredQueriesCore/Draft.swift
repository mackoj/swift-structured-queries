public protocol Draft: Sendable {
  associatedtype Columns: DraftSchema where Columns.QueryOutput == Self
  static var columns: Columns { get }
  var queryFragment: QueryFragment { get }
}

public protocol DraftSchema<QueryOutput>: Sendable {
  associatedtype QueryOutput
  var allColumns: [any ColumnExpression<QueryOutput>] { get }
}

extension Never: Draft {
  public struct Columns: DraftSchema {
    public let allColumns: [any ColumnExpression<Never>] = []
  }
  public static var columns: Columns { Columns() }
  public var queryFragment: QueryFragment { fatalError() }
}

public struct DraftColumn<Root: Draft, QueryOutput: Sendable>: ColumnExpression {
  public let _keyPath: PartialKeyPath<Root> & Sendable
  public let name: String
  public let `default`: QueryOutput?

  public init(_ name: String, keyPath: KeyPath<Root, QueryOutput> & Sendable, default: QueryOutput? = nil) {
    self._keyPath = keyPath
    self.default = `default`
    self.name = name
  }

  public var keyPath: PartialKeyPath<Root> { _keyPath }
  public var queryFragment: QueryFragment { "\(raw: name.quoted())" }

  public func encode(_ output: QueryOutput) -> QueryFragment where QueryOutput: QueryBindable {
    output.queryFragment
  }
}
