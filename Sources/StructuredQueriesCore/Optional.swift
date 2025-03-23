public protocol _OptionalProtocol<Wrapped> {
  associatedtype Wrapped
  var _wrapped: Wrapped? { get }
}

extension Optional: _OptionalProtocol {
  public var _wrapped: Wrapped? { self }
}

public protocol _OptionalPromotable<_Optionalized> {
  associatedtype _Optionalized: _OptionalProtocol = Self?
}

extension Optional: _OptionalPromotable {
  public typealias _Optionalized = Self
}

extension Optional: QueryBindable where Wrapped: QueryBindable {
  public typealias QueryValue = Wrapped.QueryValue?

  public var queryBinding: QueryBinding {
    self?.queryBinding ?? .null
  }
}

extension Optional: QueryDecodable where Wrapped: QueryDecodable {
  @inlinable
  @inline(__always)
  public init(decoder: inout some QueryDecoder) throws {
    do {
      self = try Wrapped(decoder: &decoder)
    } catch QueryDecodingError.missingRequiredColumn {
      self = nil
    }
  }
}

extension Optional: QueryExpression where Wrapped: QueryExpression {
  public typealias QueryValue = Wrapped.QueryValue?

  public var queryFragment: QueryFragment {
    self?.queryFragment ?? "NULL"
  }
}

extension Optional: QueryRepresentable where Wrapped: QueryRepresentable {
  public typealias QueryOutput = Wrapped.QueryOutput?

  @inlinable
  @inline(__always)
  public init(queryOutput: Wrapped.QueryOutput?) {
    if let queryOutput {
      self = Wrapped(queryOutput: queryOutput)
    } else {
      self = nil
    }
  }

  @inlinable
  @inline(__always)
  public var queryOutput: Wrapped.QueryOutput? {
    self?.queryOutput
  }
}

extension ContiguousArray: _OptionalPromotable where Element: _OptionalPromotable {}
