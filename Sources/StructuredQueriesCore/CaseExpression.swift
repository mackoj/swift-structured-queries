// TODO: Is this worth shipping?
// The one bummer is its use of closures isn't compatible with '$0' columns:
// ```swift
// Tag.select { tags in
//   Case {
//     When(tags.name.length() > 5) { tags.name }
//   }
//   .groupConcat()
// }
// ```

package struct Case<QueryValue>: QueryExpression {
  var base: QueryFragment?
  let cases: QueryFragment

  public init<Base>(
    _ base: some QueryExpression<Base>,
    @CaseBuilder<Base, QueryValue> _ cases: () -> some QueryExpression<QueryValue>
  ) {
    self.base = base.queryFragment
    self.cases = cases().queryFragment
  }

  public init<Base, Wrapped>(
    _ base: some QueryExpression<Base>,
    @CaseBuilder<Base, Wrapped> _ cases: () -> some QueryExpression<QueryValue>
  ) where QueryValue == Wrapped? {
    self.base = base.queryFragment
    self.cases = cases().queryFragment
  }

  public init(
    @CaseBuilder<Bool, QueryValue> _ cases: () -> some QueryExpression<QueryValue>
  ) {
    self.cases = cases().queryFragment
  }

  public init<Wrapped>(
    @CaseBuilder<Bool, Wrapped> _ cases: () -> some QueryExpression<QueryValue>
  ) where QueryValue == Wrapped? {
    self.cases = cases().queryFragment
  }

  public var queryFragment: QueryFragment {
    var query: QueryFragment = "CASE"
    if let base {
      query.append(" \(base)")
    }
    query.append(" \(cases) END")
    return query
  }
}

package struct When<Base, QueryValue>: QueryExpression {
  let predicate: QueryFragment
  let expression: QueryFragment

  public init(
    _ predicate: some QueryExpression<Base>,
    then expression: () -> some QueryExpression<QueryValue>
  ) {
    self.predicate = predicate.queryFragment
    self.expression = expression().queryFragment
  }

  public init(
    _ predicate: some QueryExpression<Base>,
    then expression: () -> _Null<QueryValue>
  ) {
    self.predicate = predicate.queryFragment
    self.expression = expression().queryFragment
  }

  public var queryFragment: QueryFragment {
    "WHEN \(predicate) THEN \(expression)"
  }
}

package struct Else<QueryValue>: QueryExpression {
  let expression: QueryFragment

  init(_ expression: () -> some QueryExpression<QueryValue>) {
    self.expression = expression().queryFragment
  }

  public var queryFragment: QueryFragment {
    "ELSE \(expression)"
  }
}

@resultBuilder
package enum CaseBuilder<Base, QueryValue> {
  public static func buildExpression(
    _ expression: When<Base, QueryValue?>
  ) -> When<Base, QueryValue?> {
    expression
  }

  public static func buildExpression(
    _ expression: When<Base, QueryValue>
  ) -> When<Base, QueryValue?> {
    unsafeBitCast(expression, to: When<Base, QueryValue?>.self)
  }

  public static func buildPartialBlock(
    first: When<Base, QueryValue?>
  ) -> [When<Base, QueryValue?>] {
    [first]
  }

  public static func buildPartialBlock(
    accumulated: [When<Base, QueryValue?>], next: When<Base, QueryValue?>
  ) -> [When<Base, QueryValue?>] {
    accumulated + [next]
  }

  public static func buildPartialBlock(
    accumulated: [When<Base, QueryValue?>], next: Else<QueryValue>
  ) -> ([When<Base, QueryValue?>], Else<QueryValue>) {
    (accumulated, next)
  }

  public static func buildFinalResult(
    _ whens: [When<Base, QueryValue?>]
  ) -> some QueryExpression<QueryValue?> {
    let query = whens.map(\.queryFragment).joined(separator: " ")
    return SQLQueryExpression(query)
  }

  public static func buildFinalResult(
    _ expressions: ([When<Base, QueryValue?>], Else<QueryValue>)
  ) -> some QueryExpression<QueryValue> {
    let (whens, `else`) = expressions
    let query = (whens.map(\.queryFragment) + [`else`.queryFragment]).joined(separator: " ")
    return SQLQueryExpression(query)
  }
}
