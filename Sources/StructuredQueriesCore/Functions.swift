extension QueryExpression where Value == Int {
  public func signum() -> some QueryExpression<Value> {
    QueryFunction("sign", self)
  }
}

extension QueryExpression where Value == Double {
  public var sign: some QueryExpression<Value> {
    QueryFunction("sign", self)
  }
}

extension QueryExpression where Value == String {
  public func lowercased() -> some QueryExpression<Value> {
    QueryFunction("lower", self)
  }

  public func uppercased() -> some QueryExpression<Value> {
    QueryFunction("upper", self)
  }
}

extension QueryExpression where Value: Collection {
  public var length: some QueryExpression<Int> {
    QueryFunction("length", self)
  }

  @available(
    *, deprecated, message: "Use 'count()' for SQL's 'count' aggregate function, or 'length'"
  )
  public var count: some QueryExpression<Int> {
    length
  }
}
