@dynamicMemberLookup
public struct Record<Base: Table>: Sendable {
  var updates: [(any ColumnExpression, any QueryExpression)] = []

  @_disfavoredOverload
  public subscript<T: QueryBindingStrategy>(
    dynamicMember keyPath: KeyPath<Base.Columns, Column<Base, Bind<T>>>
  ) -> T.Representable {
    @available(*, unavailable)
    get { fatalError() }
    set { updates.append((Base.columns[keyPath: keyPath], .bind(newValue, as: T()))) }
  }

  public subscript<Value>(
    dynamicMember keyPath: KeyPath<Base.Columns, Column<Base, Value>>
  ) -> AnyQueryExpression<Value> {
    get { AnyQueryExpression(Base.columns[keyPath: keyPath]) }
    set { updates.append((Base.columns[keyPath: keyPath], newValue)) }
  }

  public subscript<Value>(
    dynamicMember keyPath: KeyPath<Base.Columns, Column<Base, Value>>
  ) -> any QueryExpression<Value> {
    get { Base.columns[keyPath: keyPath] }
    set { updates.append((Base.columns[keyPath: keyPath], newValue)) }
  }
}

extension Record: QueryExpression {
  public typealias QueryOutput = Void
  public var queryFragment: QueryFragment {
    "SET \(updates.map { "\(raw: $0.name.quoted()) = \(bind: $1)" }.joined(separator: ", "))"
  }
}
