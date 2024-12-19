public struct Column<Root: Table, Value: QueryDecodable> {
  public let name: String

  public init(_ name: String) {
    self.name = name
  }
}

extension Column: ColumnExpression {
  public var sql: String { "\(Root.name.quoted()).\(name.quoted())" }
  public var bindings: [QueryBinding] { [] }
}
