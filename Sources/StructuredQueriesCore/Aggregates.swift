extension QueryExpression where QueryOutput: QueryBindable {
  public func count(distinct isDistinct: Bool = false) -> some QueryExpression<Int> {
    AggregateFunction("count", isDistinct: isDistinct, self)
  }
}

extension QueryExpression where QueryOutput: Comparable {
  public func maximum(distinct isDistinct: Bool = false) -> some QueryExpression<Int?> {
    AggregateFunction("max", self)
  }

  public func minimum(distinct isDistinct: Bool = false) -> some QueryExpression<Int?> {
    AggregateFunction("min", self)
  }
}

extension QueryExpression where QueryOutput: Numeric {
  public func average(distinct isDistinct: Bool = false) -> some QueryExpression<Double?> {
    AggregateFunction("avg", isDistinct: isDistinct, self)
  }

  public func sum(distinct isDistinct: Bool = false) -> some QueryExpression<QueryOutput?> {
    AggregateFunction("sum", isDistinct: isDistinct, self)
  }

  public func total(distinct isDistinct: Bool = false) -> some QueryExpression<QueryOutput> {
    AggregateFunction("total", isDistinct: isDistinct, self)
  }
}

extension QueryExpression where Self == CountExpression {
  public static func count() -> CountExpression { CountExpression() }
}

public struct CountExpression: QueryExpression {
  public typealias QueryOutput = Int
  public var queryFragment: QueryFragment { "count(*)" }
}

private struct AggregateFunction<Argument: QueryExpression, QueryOutput>: QueryExpression {
  var name: String
  var isDistinct: Bool
  var argument: Argument

  init(
    _ name: String,
    isDistinct: Bool = false,
    _ argument: Argument
  ) {
    self.name = name
    self.isDistinct = isDistinct
    self.argument = argument
  }

  var queryFragment: QueryFragment {
    var fragment: QueryFragment = "\(raw: name)("
    if isDistinct {
      fragment.append("DISTINCT ")
    }
    fragment.append(argument.queryFragment)
    fragment.append(")")
    return fragment
  }
}
