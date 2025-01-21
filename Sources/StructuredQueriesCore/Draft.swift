public protocol Draft: Sendable {
  associatedtype Columns: DraftSchema where Columns.QueryOutput == Self
  static var columns: Columns { get }
}

public protocol DraftSchema<QueryOutput>: Sendable {
  associatedtype QueryOutput
  var allColumns: [any _ColumnExpression<QueryOutput>] { get }
}

extension Never: Draft {
  public struct Columns: DraftSchema {
    public typealias QueryOutput = Never
    public let allColumns: [any _ColumnExpression<Never>] = []
  }
  public static var columns: Columns { Columns() }
}

public struct DraftColumn<Root: Draft, QueryOutput: Sendable>: _ColumnExpression {
  public let _keyPath: PartialKeyPath<Root> & Sendable
  public let name: String
  public let `default`: QueryOutput?

  public init(_ name: String, keyPath: KeyPath<Root, QueryOutput> & Sendable, default: QueryOutput? = nil) {
    self._keyPath = keyPath
    self.default = `default`
    self.name = name
  }

  public var keyPath: PartialKeyPath<Root> { _keyPath }
}
