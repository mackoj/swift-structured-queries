public protocol QueryDecodable: _OptionalPromotable {
  init(decoder: some QueryDecoder) throws
}

extension Bool: QueryDecodable {
  public init(decoder: some QueryDecoder) throws {
    self = try decoder.decode(Int.self) != 0
  }
}

extension Double: QueryDecodable {
  public init(decoder: some QueryDecoder) throws {
    self = try decoder.decode(Double.self)
  }
}

extension Float: QueryDecodable {
  public init(decoder: some QueryDecoder) throws {
    try self.init(decoder.decode(Double.self))
  }
}

extension Int: QueryDecodable {
  public init(decoder: some QueryDecoder) throws {
    self = try Int(decoder.decode(Int64.self))
  }
}

extension Int8: QueryDecodable {
  public init(decoder: some QueryDecoder) throws {
    let n = try decoder.decode(Int64.self)
    guard (Int64(Int8.min)...Int64(Int8.max)).contains(n) else { throw OverflowError() }
    self.init(n)
  }
}

extension Int16: QueryDecodable {
  public init(decoder: some QueryDecoder) throws {
    let n = try decoder.decode(Int64.self)
    guard (Int64(Int16.min)...Int64(Int16.max)).contains(n) else { throw OverflowError() }
    self.init(n)
  }
}

extension Int32: QueryDecodable {
  public init(decoder: some QueryDecoder) throws {
    let n = try decoder.decode(Int64.self)
    guard (Int64(Int32.min)...Int64(Int32.max)).contains(n) else { throw OverflowError() }
    self.init(n)
  }
}

extension Int64: QueryDecodable {
  public init(decoder: some QueryDecoder) throws {
    self = try decoder.decode(Int64.self)
  }
}

extension String: QueryDecodable {
  public init(decoder: some QueryDecoder) throws {
    self = try decoder.decode(String.self)
  }
}

extension UInt: QueryDecodable {
  public init(decoder: some QueryDecoder) throws {
    let n = try decoder.decode(Int64.self)
    guard n >= 0 else { throw OverflowError() }
    self.init(n)
  }
}

extension UInt8: QueryDecodable {
  public init(decoder: some QueryDecoder) throws {
    let n = try decoder.decode(Int64.self)
    guard (Int64(UInt8.min)...Int64(UInt8.max)).contains(n) else { throw OverflowError() }
    self.init(n)
  }
}

extension UInt16: QueryDecodable {
  public init(decoder: some QueryDecoder) throws {
    let n = try decoder.decode(Int64.self)
    guard (Int64(UInt16.min)...Int64(UInt16.max)).contains(n) else { throw OverflowError() }
    self.init(n)
  }
}

extension UInt32: QueryDecodable {
  public init(decoder: some QueryDecoder) throws {
    let n = try decoder.decode(Int64.self)
    guard (Int64(UInt32.min)...Int64(UInt32.max)).contains(n) else { throw OverflowError() }
    self.init(n)
  }
}

extension UInt64: QueryDecodable {
  public init(decoder: some QueryDecoder) throws {
    try self.init(decoder.decode(Int64.self))
  }
}

extension ContiguousArray<UInt8>: QueryDecodable, _OptionalPromotable {
  public init(decoder: some QueryDecoder) throws {
    self = try decoder.decode(ContiguousArray<UInt8>.self)
  }
}

extension QueryDecodable where Self: RawRepresentable, RawValue: QueryDecodable {
  public init(decoder: some QueryDecoder) throws {
    guard let rawRepresentable = try Self(rawValue: decoder.decode(RawValue.self))
    else {
      throw DataCorruptedError()
    }
    self = rawRepresentable
  }
}

private struct DataCorruptedError: Error {}
private struct OverflowError: Error {}
