struct QueryFunction<each Argument, Value> {
  let name: String
  let arguments: (repeat each Argument)
  init(_ name: String, _ arguments: repeat each Argument) {
    self.name = name
    self.arguments = (repeat each arguments)
  }
}

extension QueryFunction: QueryExpression where repeat (each Argument): QueryExpression {
  var sql: String {
    var argumentsSQL: [String] = []
    for argument in repeat each arguments {
      argumentsSQL.append(argument.sql)
    }
    return "\(name)(\(argumentsSQL.joined(separator: ", ")))"
  }
  var bindings: [QueryBinding] {
    var argumentsBindings: [QueryBinding] = []
    for argument in repeat each arguments {
      argumentsBindings.append(contentsOf: argument.bindings)
    }
    return argumentsBindings
  }
}
