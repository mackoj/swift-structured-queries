// TODO: Rename to avoid conflicts (with GRDB, other generic types)?
// TODO: `map` operation for bundling up data?

public protocol Statement<Value>: QueryExpression, Hashable {}

extension Statement {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.queryString == rhs.queryString && lhs.queryBindings == rhs.queryBindings
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(queryString)
    hasher.combine(queryBindings)
  }
}
