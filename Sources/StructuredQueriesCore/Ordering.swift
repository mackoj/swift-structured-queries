extension QueryExpression where QueryOutput: QueryBindable {
  public func ascending(nulls: NullOrdering? = nil) -> OrderingTerm {
    OrderingTerm(base: self, direction: .ascending, nulls: nulls)
  }

  public func descending(nulls: NullOrdering? = nil) -> OrderingTerm {
    OrderingTerm(base: self, direction: .descending, nulls: nulls)
  }
}

public protocol _OrderingTerm {
  var _orderingTerm: OrderingTerm { get }
}

public enum NullOrdering: String, Sendable {
  case first = "FIRST"
  case last = "LAST"
}

public struct OrderingTerm {
  enum Direction: String {
    case ascending = "ASC"
    case descending = "DESC"
  }

  let base: any QueryExpression
  let direction: Direction?
  let nulls: NullOrdering?

  init(base: any QueryExpression, direction: Direction? = nil, nulls: NullOrdering? = nil) {
    self.base = base
    self.direction = direction
    self.nulls = nulls
  }
}

extension OrderingTerm: QueryExpression {
  public typealias QueryOutput = Void
  public var queryFragment: QueryFragment {
    var fragment: QueryFragment = base.queryFragment
    if let direction {
      fragment.append(" \(raw: direction.rawValue)")
    }
    if let nulls {
      fragment.append(" NULLS \(raw: nulls.rawValue)")
    }
    return fragment
  }
}

extension OrderingTerm: _OrderingTerm {
  public var _orderingTerm: Self { self }
}

@resultBuilder
public enum OrderingBuilder {
  public static func buildExpression<each Value: _OrderingTerm>(
    _ expression: (repeat each Value)
  ) -> [OrderingTerm] {
    var terms: [OrderingTerm] = []
    for term in repeat each expression {
      terms.append(term._orderingTerm)
    }
    return terms
  }

  public static func buildBlock(_ component: [OrderingTerm]) -> [OrderingTerm] {
    component
  }

  public static func buildEither(first component: [OrderingTerm]) -> [OrderingTerm] {
    component
  }

  public static func buildEither(second component: [OrderingTerm]) -> [OrderingTerm] {
    component
  }

  public static func buildOptional(_ component: [OrderingTerm]?) -> [OrderingTerm] {
    component ?? []
  }
}
