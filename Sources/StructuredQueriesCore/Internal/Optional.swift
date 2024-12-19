public protocol _OptionalProtocol<Wrapped> {
  associatedtype Wrapped
  var _wrapped: Wrapped? { get }
}

extension Optional: _OptionalProtocol {
  public var _wrapped: Wrapped? { self }
}
