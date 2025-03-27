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
  ) -> SQLQueryExpression<QueryValue._Optionalized> {
    // NB: We must explicitly erase here to avoid a runtime crash with opaque return types
    // TODO: Report issue to Swift team.
    SQLQueryExpression(
      AggregateFunction<QueryValue._Optionalized>("sum", isDistinct: isDistinct, self).queryFragment
    )
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
  var name: QueryFragment
  var isDistinct: Bool
  var arguments: [QueryFragment]
  var order: QueryFragment?
  var filter: QueryFragment?

  init<each Argument: QueryExpression>(
    _ name: QueryFragment,
    isDistinct: Bool = false,
    _ arguments: repeat each Argument,
    order: (some QueryExpression)? = _EmptyQueryExpression?.none,
    filter: (some QueryExpression)? = _EmptyQueryExpression?.none
  ) {
    self.name = name
    self.isDistinct = isDistinct
    self.arguments = Array(repeat each arguments)
    self.order = order?.queryFragment
    self.filter = filter?.queryFragment
  }

  var queryFragment: QueryFragment {
    var query: QueryFragment = "\(name)("
    if isDistinct {
      query.append("DISTINCT ")
    }
    query.append(arguments.joined(separator: ", "))
    if let order {
      query.append(" ORDER BY \(order)")
    }
    query.append(")")
    if let filter {
      query.append(" FILTER (WHERE \(filter))")
    }
    return query
  }
}

struct _EmptyQueryExpression: QueryExpression {
  public typealias QueryValue = Never
  public var queryFragment: QueryFragment { "" }
}
