extension QueryExpression where Value: Comparable {
  public func ascending() -> OrderingTerm {
    OrderingTerm(base: self, direction: .ascending)
  }

  public func descending() -> OrderingTerm {
    OrderingTerm(base: self, direction: .descending)
  }
}

public protocol _OrderingTerm {
  var _orderingTerm: OrderingTerm { get }
}

public struct OrderingTerm {
  enum Direction: String {
    case ascending = "ASC"
    case descending = "DESC"
  }

  let base: any QueryExpression

  let direction: Direction?

  init(base: any QueryExpression, direction: Direction? = nil) {
    self.base = base
    self.direction = direction
  }
}

extension OrderingTerm: QueryExpression {
  public typealias Value = Void
  public var queryString: String {
    "\(base.queryString)\(direction.map { " \($0.rawValue)" } ?? "")"
  }
  public var queryBindings: [QueryBinding] {
    base.queryBindings
  }
}

extension OrderingTerm: _OrderingTerm {
  public var _orderingTerm: Self { self }
}

extension Column: _OrderingTerm {
  public var _orderingTerm: OrderingTerm { OrderingTerm(base: self) }
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
