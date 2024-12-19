extension QueryExpression where Value: QueryColumnDecodable {
  public func count(distinct isDistinct: Bool = false) -> some QueryExpression<Int> {
    AggregateFunction("count", isDistinct: isDistinct, self)
  }
}

extension QueryExpression where Value: Comparable {
  public func maximum(distinct isDistinct: Bool = false) -> some QueryExpression<Int?> {
    AggregateFunction("max", self)
  }

  public func minimum(distinct isDistinct: Bool = false) -> some QueryExpression<Int?> {
    AggregateFunction("min", self)
  }
}

extension QueryExpression where Value: Numeric {
  public func average(distinct isDistinct: Bool = false) -> some QueryExpression<Double?> {
    AggregateFunction("avg", isDistinct: isDistinct, self)
  }

  public func sum(distinct isDistinct: Bool = false) -> some QueryExpression<Value?> {
    AggregateFunction("sum", isDistinct: isDistinct, self)
  }

  public func total(distinct isDistinct: Bool = false) -> some QueryExpression<Value> {
    AggregateFunction("total", isDistinct: isDistinct, self)
  }
}

private struct AggregateFunction<Argument, Value> {
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
}

extension AggregateFunction: QueryExpression where Argument: QueryExpression {
  var sql: String {
    var sql = "\(name)("
    if isDistinct {
      sql.append("DISTINCT ")
    }
    sql.append("\(argument.sql))")
    return sql
  }
  var bindings: [QueryBinding] { argument.bindings }
}
