public struct Column<Root: Table, Value: QueryBindable> {
  public let name: String

  public init(_ name: String) {
    self.name = name
  }
}

extension Column: ColumnExpression {
  public typealias Value = Value.Value
  public var queryString: String { "\(Root.name.quoted()).\(name.quoted())" }
  public var queryBindings: [QueryBinding] { [] }
}
