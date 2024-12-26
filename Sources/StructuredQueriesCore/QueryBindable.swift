public protocol QueryBindable<Value>: QueryDecodable, QueryExpression where Value: QueryBindable {
  associatedtype Value = Self
  var queryValue: Value { get }
  var queryBinding: QueryBinding { get }
}

extension QueryBindable {
  public var queryString: String { "?" }
  public var queryBindings: [QueryBinding] { [queryBinding] }
}

extension QueryBindable where Value == Self {
  public var queryValue: Self { self }
}

extension QueryBindable where Self: RawRepresentable, RawValue: QueryBindable {
  public var queryBinding: QueryBinding { rawValue.queryBinding }
}

extension Bool: QueryBindable {
  public var queryBinding: QueryBinding { .int(self ? 1 : 0) }
}

extension Double: QueryBindable {
  public var queryBinding: QueryBinding { .double(self) }
}

extension Float: QueryBindable {
  public var queryBinding: QueryBinding { .double(Double(self)) }
}

extension Int: QueryBindable {
  public var queryBinding: QueryBinding { .int(Int64(self)) }
}

extension Int8: QueryBindable {
  public var queryBinding: QueryBinding { .int(Int64(self)) }
}

extension Int16: QueryBindable {
  public var queryBinding: QueryBinding { .int(Int64(self)) }
}

extension Int32: QueryBindable {
  public var queryBinding: QueryBinding { .int(Int64(self)) }
}

extension Int64: QueryBindable {
  public var queryBinding: QueryBinding { .int(self) }
}

extension String: QueryBindable {
  public var queryBinding: QueryBinding { .text(self) }
}

extension UInt8: QueryBindable {
  public var queryBinding: QueryBinding { .int(Int64(self)) }
}

extension UInt16: QueryBindable {
  public var queryBinding: QueryBinding { .int(Int64(self)) }
}

extension UInt32: QueryBindable {
  public var queryBinding: QueryBinding { .int(Int64(self)) }
}

extension [UInt8]: QueryBindable {
  public var queryBinding: QueryBinding { .blob(self) }
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
  public var queryBinding: QueryBinding {
    switch self {
    case let .some(wrapped):
      return wrapped.queryBinding
    case .none:
      return .null
    }
  }
}
