extension QueryExpression {
  public func jsonArrayLength<Element: Codable & Sendable>() -> some QueryExpression<Int>
  where QueryValue == JSONRepresentation<[Element]> {
    QueryFunction("json_array_length", self)
  }
}

extension QueryExpression where QueryValue: Codable & Sendable {
  public func jsonGroupArray(
    order: (some QueryExpression)? = Bool?.none,
    filter: (some QueryExpression<Bool>)? = Bool?.none
  ) -> some QueryExpression<JSONRepresentation<[QueryValue]>> {
    AggregateFunction("json_group_array", self, order: order, filter: filter)
  }
}
