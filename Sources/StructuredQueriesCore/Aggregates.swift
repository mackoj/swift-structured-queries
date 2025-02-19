extension QueryExpression where QueryOutput: QueryBindable {
  public func count(distinct isDistinct: Bool = false) -> some QueryExpression<Int> {
    AggregateFunction("count", isDistinct: isDistinct, self)
  }
}

extension QueryExpression where QueryOutput: QueryBindable {
  // TODO: Support $0.name.groupConcat(separator: ",", order: $0.priority)
  // TODO: Support $0.name.groupConcat(filter: $0.name.count > 5)
  public func groupConcat(separator: String? = nil) -> some QueryExpression<String?> {
    AggregateFunction("group_concat", (self, separator))
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

private struct AggregateFunction<QueryOutput>: QueryExpression {
  var name: String
  var isDistinct: Bool
  var arguments: [any QueryExpression]

  init<each Argument: QueryExpression>(
    _ name: String,
    isDistinct: Bool = false,
    _ arguments: (repeat each Argument)
  ) {
    self.name = name
    self.isDistinct = isDistinct
    self.arguments = []
    for argument in repeat each arguments {
      self.arguments.append(argument)
    }
  }

  var queryFragment: QueryFragment {
    var fragment: QueryFragment = "\(raw: name)("
    if isDistinct {
      fragment.append("DISTINCT ")
    }
    var isFirst = true
    for argument in arguments {
      defer { isFirst = false }
      if !isFirst {
        fragment.append(", ")
      }
      fragment.append(argument.queryFragment)
    }
    fragment.append(")")
    return fragment
  }
}
