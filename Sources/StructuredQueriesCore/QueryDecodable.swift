public protocol QueryDecodable: _OptionalPromotable {
  init(decoder: inout some QueryDecoder) throws
}

extension [UInt8]: QueryDecodable {
  @inlinable
  @inline(__always)
  public init(decoder: inout some QueryDecoder) throws {
    guard let result = try decoder.decode([UInt8].self)
    else { throw QueryDecodingError.missingRequiredColumn }
    self = result
  }
}

extension Double: QueryDecodable {
  @inlinable
  @inline(__always)
  public init(decoder: inout some QueryDecoder) throws {
    guard let result = try decoder.decode(Double.self)
    else { throw QueryDecodingError.missingRequiredColumn }
    self = result
  }
}

extension Int64: QueryDecodable {
  @inlinable
  @inline(__always)
  public init(decoder: inout some QueryDecoder) throws {
    guard let result = try decoder.decode(Int64.self)
    else { throw QueryDecodingError.missingRequiredColumn }
    self = result
  }
}

extension String: QueryDecodable {
  @inlinable
  @inline(__always)
  public init(decoder: inout some QueryDecoder) throws {
    guard let result = try decoder.decode(String.self)
    else { throw QueryDecodingError.missingRequiredColumn }
    self = result
  }
}

extension Bool: QueryDecodable {
  public init(decoder: inout some QueryDecoder) throws {
    self = try Int(decoder: &decoder) != 0
  }
}

extension Float: QueryDecodable {
  public init(decoder: inout some QueryDecoder) throws {
    try self.init(Double(decoder: &decoder))
  }
}

extension Int: QueryDecodable {
  public init(decoder: inout some QueryDecoder) throws {
    let n = try Int64(decoder: &decoder)
    guard (Int64(Int.min)...Int64(Int.max)).contains(n) else { throw OverflowError() }
    self.init(n)
  }
}

extension Int8: QueryDecodable {
  public init(decoder: inout some QueryDecoder) throws {
    let n = try Int64(decoder: &decoder)
    guard (Int64(Int8.min)...Int64(Int8.max)).contains(n) else { throw OverflowError() }
    self.init(n)
  }
}

extension Int16: QueryDecodable {
  public init(decoder: inout some QueryDecoder) throws {
    let n = try Int64(decoder: &decoder)
    guard (Int64(Int16.min)...Int64(Int16.max)).contains(n) else { throw OverflowError() }
    self.init(n)
  }
}

extension Int32: QueryDecodable {
  public init(decoder: inout some QueryDecoder) throws {
    let n = try Int64(decoder: &decoder)
    guard (Int64(Int32.min)...Int64(Int32.max)).contains(n) else { throw OverflowError() }
    self.init(n)
  }
}

extension UInt: QueryDecodable {
  public init(decoder: inout some QueryDecoder) throws {
    let n = try Int64(decoder: &decoder)
    guard n >= 0 else { throw OverflowError() }
    self.init(n)
  }
}

extension UInt8: QueryDecodable {
  public init(decoder: inout some QueryDecoder) throws {
    let n = try Int64(decoder: &decoder)
    guard (Int64(UInt8.min)...Int64(UInt8.max)).contains(n) else { throw OverflowError() }
    self.init(n)
  }
}

extension UInt16: QueryDecodable {
  public init(decoder: inout some QueryDecoder) throws {
    let n = try Int64(decoder: &decoder)
    guard (Int64(UInt16.min)...Int64(UInt16.max)).contains(n) else { throw OverflowError() }
    self.init(n)
  }
}

extension UInt32: QueryDecodable {
  public init(decoder: inout some QueryDecoder) throws {
    let n = try Int64(decoder: &decoder)
    guard (Int64(UInt32.min)...Int64(UInt32.max)).contains(n) else { throw OverflowError() }
    self.init(n)
  }
}

extension UInt64: QueryDecodable {
  public init(decoder: inout some QueryDecoder) throws {
    try self.init(Int64(decoder: &decoder))
  }
}

extension QueryDecodable where Self: RawRepresentable, RawValue: QueryDecodable {
  public init(decoder: inout some QueryDecoder) throws {
    guard let rawRepresentable = try Self(rawValue: RawValue(decoder: &decoder))
    else {
      throw DataCorruptedError()
    }
    self = rawRepresentable
  }
}

private struct DataCorruptedError: Error {}
struct OverflowError: Error {}
