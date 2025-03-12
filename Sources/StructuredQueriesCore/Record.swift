@dynamicMemberLookup
public struct Record<Base: Table> {
  var updates: [(String, QueryFragment)] = []

  public subscript<Value>(
    dynamicMember keyPath: KeyPath<Base.Columns, Column<Base, Value>>
  ) -> any QueryExpression<Value> {
    get { Base.columns[keyPath: keyPath] }
    set { updates.append((Base.columns[keyPath: keyPath].name, newValue.queryFragment)) }
  }

  @_disfavoredOverload
  public subscript<Value>(
    dynamicMember keyPath: KeyPath<Base.Columns, Column<Base, Value>>
  ) -> AnyQueryExpression<Value> {
    get { AnyQueryExpression(Base.columns[keyPath: keyPath]) }
    set { updates.append((Base.columns[keyPath: keyPath].name, newValue.queryFragment)) }
  }

  @_disfavoredOverload
  public subscript<Value: QueryExpression>(
    dynamicMember keyPath: KeyPath<Base.Columns, some ColumnExpression<Base, Value>>
  ) -> Value.QueryOutput {
    @available(*, unavailable)
    get { fatalError() }
    set {
      updates.append(
        (Base.columns[keyPath: keyPath].name, Value(queryOutput: newValue).queryFragment)
      )
    }
  }
}

extension Record: QueryExpression {
  public typealias QueryValue = Void

  public var queryFragment: QueryFragment {
    "SET \(updates.map { "\(raw: $0.quoted()) = \($1)" }.joined(separator: ", "))"
  }
}
