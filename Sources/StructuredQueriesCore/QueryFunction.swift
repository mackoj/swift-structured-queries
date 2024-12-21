struct QueryFunction<Value>: QueryExpression {
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
