public protocol QueryBindable: QueryDecodable, QueryExpression where Value == Self {
  var binding: QueryBinding { get }
}

extension QueryBindable {
  public var sql: String { "?" }
  public var bindings: [QueryBinding] { [binding] }
}

extension Bool: QueryBindable {
  public var binding: QueryBinding { (self ? 1 : 0).binding }
}

extension Double: QueryBindable {
  public var binding: QueryBinding { .double(self) }
}

extension Float: QueryBindable {
  public var binding: QueryBinding { .double(Double(self)) }
}

extension Int: QueryBindable {
  public var binding: QueryBinding { Int64(self).binding }
}

extension Int8: QueryBindable {
  public var binding: QueryBinding { Int64(self).binding }
}

extension Int16: QueryBindable {
  public var binding: QueryBinding { Int64(self).binding }
}

extension Int32: QueryBindable {
  public var binding: QueryBinding { Int64(self).binding }
}

extension Int64: QueryBindable {
  public var binding: QueryBinding { .int(self) }
}

extension String: QueryBindable {
  public var binding: QueryBinding { .text(self) }
}

extension DefaultStringInterpolation {
  @_disfavoredOverload
  @available(
    *,
     deprecated,
     message: """
      String interpolation produces a debug description for a SQL expression. \
      Use '+' to concatenate SQL expressions, instead."
      """
  )
  public mutating func appendInterpolation(_ value: some QueryExpression) {
    self.appendInterpolation(value as Any)
  }

  @available(
    *,
     deprecated,
     message: """
      String interpolation produces a debug description for a SQL expression. \
      Use '+' to concatenate SQL expressions, instead."
      """
  )
  public mutating func appendInterpolation<T, V>(_ value: Column<T, V>) {
    self.appendInterpolation(value as Any)
  }
}

extension Optional: QueryBindable where Wrapped: QueryBindable {
  public var binding: QueryBinding {
    switch self {
    case let .some(wrapped):
      return wrapped.binding
    case .none:
      return .null
    }
  }
}
