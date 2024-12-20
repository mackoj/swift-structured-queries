extension QueryExpression where Value: Comparable {
  public func ascending() -> some QueryExpression<Value> {
    OrderingTerm(base: self, direction: .ascending)
  }

  public func descending() -> some QueryExpression<Value> {
    OrderingTerm(base: self, direction: .descending)
  }
}

private struct OrderingTerm<Value: Comparable> {
  enum Direction: String {
    case ascending = "ASC"
    case descending = "DESC"
  }

  let base: any QueryExpression<Value>

  let direction: Direction

  init(base: any QueryExpression<Value>, direction: Direction) {
    if let base = base as? Self {
      self.base = base.base
      self.direction = direction
    } else {
      self.base = base
      self.direction = direction
    }
  }
}

extension OrderingTerm: QueryExpression {
  var queryString: String { "\(base.queryString) \(direction.rawValue)" }
  var queryBindings: [QueryBinding] { base.queryBindings }
}
