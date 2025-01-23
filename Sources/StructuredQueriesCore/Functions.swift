extension QueryExpression where QueryOutput == Int {
  // TODO: Should this be 'sign()' to more closely match the SQL function?
  public func signum() -> some QueryExpression<QueryOutput> {
    QueryFunction("sign", self)
  }
}

extension QueryExpression where QueryOutput == Double {
  // TODO: Should this be a method?
  public var sign: some QueryExpression<QueryOutput> {
    QueryFunction("sign", self)
  }
  // TODO: Should this be 'rounded(precision:)' to more closely match the Swift function?
  public func round(_ k: some QueryExpression<Int>) -> some QueryExpression<QueryOutput> {
    QueryFunction("round", self, k)
  }
  // TODO: Should this be 'rounded' to more closely match the Swift function?
  public func round() -> some QueryExpression<QueryOutput> {
    QueryFunction("round", self)
  }
}

extension QueryExpression where QueryOutput == String {
  // TODO: Other options:
  // { $0.name.lower() }
  // { .count($0.id) }

  // TODO: Should this be 'lower()' to more closely match the SQL function?
  public func lowercased() -> some QueryExpression<QueryOutput> {
    QueryFunction("lower", self)
  }
  // TODO: Should this be 'upper()' to more closely match the SQL function?
  public func uppercased() -> some QueryExpression<QueryOutput> {
    QueryFunction("upper", self)
  }
}

extension QueryExpression where QueryOutput == Bind<SQLiteISO8601Strategy> {
  public func strftime(
    _ format: some QueryExpression<String>
  ) -> some QueryExpression<QueryOutput> {
    QueryFunction("strftime", format, self)
  }
}

extension QueryExpression where QueryOutput: Collection {
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

struct QueryFunction<QueryOutput>: QueryExpression {
  let name: String
  let arguments: [any QueryExpression]
  init<each Argument: QueryExpression>(_ name: String, _ arguments: repeat each Argument) {
    self.name = name
    var expressions: [any QueryExpression] = []
    for argument in repeat each arguments {
      expressions.append(argument)
    }
    self.arguments = expressions
  }

  var queryString: String {
    "\(name)(\(arguments.map(\.queryString).joined(separator: ", ")))"
  }
  var queryBindings: [QueryBinding] {
    arguments.flatMap(\.queryBindings)
  }
}
