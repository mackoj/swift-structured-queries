public protocol QueryExpression<Value>: Sendable {
  associatedtype Value

  var sql: String { get }

  var bindings: [QueryBinding] { get }
}
