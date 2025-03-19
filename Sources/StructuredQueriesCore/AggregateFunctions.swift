extension QueryExpression where QueryValue: QueryBindable {
  public func count(distinct isDistinct: Bool = false) -> some QueryExpression<Int> {
    AggregateFunction("count", isDistinct: isDistinct, self)
  }
}

extension QueryExpression
where QueryValue: _OptionalPromotable, QueryValue._Optionalized.Wrapped == String {
  public func groupConcat(
    _ separator: (some QueryExpression)? = String?.none,
    order: (some QueryExpression)? = Bool?.none,
    filter: (some QueryExpression<Bool>)? = Bool?.none
  ) -> some QueryExpression<String?> {
    if let separator {
      return AggregateFunction("group_concat", self, separator, order: order, filter: filter)
    } else {
      return AggregateFunction("group_concat", self, order: order, filter: filter)
    }
  }
}

extension QueryExpression where QueryValue: QueryBindable {
  public func max(distinct isDistinct: Bool = false) -> some QueryExpression<Int?> {
    AggregateFunction("max", self)
  }

  public func min(distinct isDistinct: Bool = false) -> some QueryExpression<Int?> {
    AggregateFunction("min", self)
  }
}

extension QueryExpression
where QueryValue: _OptionalPromotable, QueryValue._Optionalized.Wrapped: Numeric {
  public func avg(distinct isDistinct: Bool = false) -> some QueryExpression<Double?> {
    AggregateFunction("avg", isDistinct: isDistinct, self)
  }

  public func sum(
    distinct isDistinct: Bool = false
  ) -> some QueryExpression<QueryValue._Optionalized> {
    AggregateFunction("sum", isDistinct: isDistinct, self)
  }

  public func total(distinct isDistinct: Bool = false) -> some QueryExpression<QueryValue> {
    AggregateFunction("total", isDistinct: isDistinct, self)
  }
}

extension QueryExpression where Self == CountExpression {
  public static func count() -> CountExpression { CountExpression() }
}

public struct CountExpression: QueryExpression {
  public typealias QueryValue = Int
  public var queryFragment: QueryFragment { "count(*)" }
}

private struct AggregateFunction<QueryValue>: QueryExpression {
  var name: String
  var isDistinct: Bool
  var arguments: [any QueryExpression]
  var order: (any QueryExpression)?
  var filter: (any QueryExpression)?

  init<each Argument: QueryExpression>(
    _ name: String,
    isDistinct: Bool = false,
    _ arguments: repeat each Argument,
    order: (some QueryExpression)? = Bool?.none,
    filter: (some QueryExpression)? = Bool?.none
  ) {
    self.name = name
    self.isDistinct = isDistinct
    self.arguments = []
    for argument in repeat each arguments {
      self.arguments.append(argument)
    }
    self.order = order
    self.filter = filter
  }

  var queryFragment: QueryFragment {
    var query: QueryFragment = "\(raw: name)("
    if isDistinct {
      query.append("DISTINCT ")
    }
    var isFirst = true
    for argument in arguments {
      defer { isFirst = false }
      if !isFirst {
        query.append(", ")
      }
      query.append(argument.queryFragment)
    }
    if let order {
      query.append(" ORDER BY ")
      query.append(order.queryFragment)
    }
    query.append(")")
    if let filter {
      query.append(" FILTER (WHERE ")
      query.append(filter.queryFragment)
      query.append(")")
    }
    return query
  }
}
