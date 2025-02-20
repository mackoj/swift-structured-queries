// TODO: Finalize/finesse APIs for raw SQL

extension QueryExpression {
  public static func raw<QueryOutput>(
    _ queryFragment: QueryFragment,
    as output: QueryOutput.Type = QueryOutput.self
  ) -> Self
  where Self == RawQueryExpression<QueryOutput> {
    Self(queryFragment: queryFragment)
  }

  public static func raw<Strategy: QueryBindingStrategy>(
    _ queryFragment: QueryFragment,
    as strategy: Strategy
  ) -> Self
  where Self == RawQueryExpression<Bind<Strategy>> {
    Self(queryFragment: queryFragment)
  }
}

extension AnyQueryExpression {
  public static func raw(
    _ queryFragment: QueryFragment,
    as output: QueryOutput.Type = QueryOutput.self
  ) -> Self {
    AnyQueryExpression(RawQueryExpression(queryFragment: queryFragment))
  }

  public static func raw<Strategy: QueryBindingStrategy>(
    _ queryFragment: QueryFragment,
    as strategy: Strategy
  ) -> Self
  where QueryOutput == Bind<Strategy> {
    AnyQueryExpression(RawQueryExpression(queryFragment: queryFragment))
  }
}

public struct RawQueryExpression<QueryOutput>: QueryExpression {
  public let queryFragment: QueryFragment
}

extension RawQueryExpression: _OrderingTerm where QueryOutput == Void {
  public var _orderingTerm: OrderingTerm {
    OrderingTerm(base: self)
  }
}

// TODO: Use a type init instead?
public func raw<QueryOutput>(
  _ queryFragment: QueryFragment,
  as output: QueryOutput.Type = QueryOutput.self
) -> RawQueryExpression<QueryOutput> {
  RawQueryExpression(queryFragment: queryFragment)
}
