struct QueryFunction<each Argument: QueryExpression, Value>: QueryExpression {
  let name: String
  let arguments: (repeat each Argument)
  init(_ name: String, _ arguments: repeat each Argument) {
    self.name = name
    self.arguments = (repeat each arguments)
  }

  var queryString: String {
    var argumentsSQL: [String] = []
    for argument in repeat each arguments {
      argumentsSQL.append(argument.queryString)
    }
    return "\(name)(\(argumentsSQL.joined(separator: ", ")))"
  }
  var queryBindings: [QueryBinding] {
    var argumentsBindings: [QueryBinding] = []
    for argument in repeat each arguments {
      argumentsBindings.append(contentsOf: argument.queryBindings)
    }
    return argumentsBindings
  }
}
