@dynamicMemberLookup
public struct Record<Base: Table>: Sendable {
  var updates: [(any ColumnExpression, any QueryExpression)] = []

  public subscript<Value>(
    dynamicMember keyPath: KeyPath<Base.Columns, Column<Base, Value>>
  ) -> some QueryExpression<Value> {
    Base.columns[keyPath: keyPath]
  }

  @_disfavoredOverload
  public subscript<Value>(
    dynamicMember keyPath: KeyPath<Base.Columns, Column<Base, Value>>
  ) -> any QueryExpression<Value> {
    get { Base.columns[keyPath: keyPath] }
    set { updates.append((Base.columns[keyPath: keyPath], newValue)) }
  }

  @_disfavoredOverload
  public subscript<Value>(
    dynamicMember keyPath: KeyPath<Base.Columns, Column<Base, Value>>
  ) -> AnyQueryExpression<Value> {
    get { AnyQueryExpression(Base.columns[keyPath: keyPath]) }
    set { updates.append((Base.columns[keyPath: keyPath], newValue)) }
  }
}

extension Record: QueryExpression {
  public typealias Value = Void
  public var queryString: String {
    "SET \(updates.map { "\($0.name.quoted()) = \($1.queryString)" }.joined(separator: ", "))"
  }
  public var queryBindings: [QueryBinding] {
    updates.flatMap { $0.queryBindings + $1.queryBindings }
  }
}
