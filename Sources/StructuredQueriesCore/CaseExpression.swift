package struct Case<Base, QueryValue> {
  var base: QueryFragment?

  public init(
    _ base: some QueryExpression<Base>,
  ) {
    self.base = base.queryFragment
  }

  public init() where Base == Bool {}

  public func when(
    _ condition: some QueryExpression<Base>,
    then expression: some QueryExpression<QueryValue>
  ) -> Cases<Base, QueryValue?> {
    Cases(
      base: base,
      cases: [
        When(predicate: condition.queryFragment, expression: expression.queryFragment).queryFragment
      ]
    )
  }

  public func when(
    _ condition: some QueryExpression<Base>,
    then expression: some QueryExpression<QueryValue?>
  ) -> Cases<Base, QueryValue?> {
    Cases(
      base: base,
      cases: [
        When(predicate: condition.queryFragment, expression: expression.queryFragment).queryFragment
      ]
    )
  }
}

public struct Cases<Base, QueryValue: _OptionalProtocol>: QueryExpression {
  var base: QueryFragment?
  var cases: [QueryFragment]

  public func when(
    _ condition: some QueryExpression<Base>,
    then expression: some QueryExpression<QueryValue>
  ) -> Cases {
    var cases = self
    cases.cases.append(
      When(predicate: condition.queryFragment, expression: expression.queryFragment).queryFragment
    )
    return cases
  }

  public func `else`(
    _ expression: some QueryExpression<QueryValue.Wrapped>
  ) -> some QueryExpression<QueryValue.Wrapped> {
    var cases = self
    cases.cases.append(
      "ELSE \(expression)"
    )
    return SQLQueryExpression(cases.queryFragment)
  }

  public var queryFragment: QueryFragment {
    var query: QueryFragment = "CASE"
    if let base {
      query.append(" \(base)")
    }
    query.append(" \(cases.joined(separator: " ")) END")
    return query
  }
}

private struct When: QueryExpression {
  typealias QueryValue = Void
  let predicate: QueryFragment
  let expression: QueryFragment

  public var queryFragment: QueryFragment {
    "WHEN \(predicate) THEN \(expression)"
  }
}
