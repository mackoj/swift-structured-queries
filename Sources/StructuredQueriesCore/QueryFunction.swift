struct QueryFunction<each Argument: QueryExpression, Value>: QueryExpression {
  let name: String
  let arguments: (repeat each Argument)
  init(_ name: String, _ arguments: repeat each Argument) {
    self.name = name
    self.arguments = (repeat each arguments)
  }

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
