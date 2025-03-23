public protocol QueryDecoder {
  mutating func decode(_ columnType: ContiguousArray<UInt8>.Type) throws -> ContiguousArray<UInt8>?
  mutating func decode(_ columnType: Double.Type) throws -> Double?
  mutating func decode(_ columnType: Int64.Type) throws -> Int64?
  mutating func decode(_ columnType: String.Type) throws -> String?

  mutating func decode(_ columnType: Bool.Type) throws -> Bool?
  mutating func decode(_ columnType: Int.Type) throws -> Int?

  mutating func decode<T: QueryRepresentable>(_ columnType: T.Type) throws -> T.QueryOutput?
  // mutating func decode<T: QueryRepresentable>(_ columnType: T?.Type) throws -> T.QueryOutput?
}

extension QueryDecoder {
  @inlinable
  @inline(__always)
  public mutating func decode<T: QueryRepresentable>(
    _ columnType: T.Type
  ) throws -> T.QueryOutput? {
    try T?(decoder: &self)?.queryOutput
  }
  // @inlinable
  // @inline(__always)
  // public mutating func decode<T: QueryRepresentable>(
  //   _ columnType: T?.Type
  // ) throws -> T.QueryOutput? {
  //   try T?(decoder: &self)?.queryOutput
  // }
  @inlinable
  @inline(__always)
  public mutating func decodeColumns<each T: QueryRepresentable>(
    _ columnTypes: (repeat each T).Type
  ) throws -> (repeat (each T).QueryOutput) {
    try (repeat (each T)(decoder: &self).queryOutput)
  }
}

public enum QueryDecodingError: Error {
  case missingRequiredColumn
}

//// TODO: Simplify some of this?
//
//public protocol QueryDecoder {
//  func decode(_ type: Bool.Type) throws -> Bool
//
//  func decode(_ type: ContiguousArray<UInt8>.Type) throws -> ContiguousArray<UInt8>
//
//  func decode(_ type: Double.Type) throws -> Double
//
//  func decode(_ type: Float.Type) throws -> Float
//
//  func decode(_ type: Int.Type) throws -> Int
//
//  func decode(_ type: Int8.Type) throws -> Int8
//
//  func decode(_ type: Int16.Type) throws -> Int16
//
//  func decode(_ type: Int32.Type) throws -> Int32
//
//  func decode(_ type: Int64.Type) throws -> Int64
//
//  func decode(_ type: String.Type) throws -> String
//
//  func decode(_ type: UInt.Type) throws -> UInt
//
//  func decode(_ type: UInt8.Type) throws -> UInt8
//
//  func decode(_ type: UInt16.Type) throws -> UInt16
//
//  func decode(_ type: UInt32.Type) throws -> UInt32
//
//  func decode(_ type: UInt64.Type) throws -> UInt64
//
//  func decodeColumns<T: Table>(_ type: T.Type) throws -> T
//
//  func decodeNil() throws -> Bool
//
//  func decode(_ type: Bool?.Type) throws -> Bool?
//
//  func decode(_ type: ContiguousArray<UInt8>?.Type) throws -> ContiguousArray<UInt8>?
//
//  func decode(_ type: Double?.Type) throws -> Double?
//
//  func decode(_ type: Float?.Type) throws -> Float?
//
//  func decode(_ type: Int?.Type) throws -> Int?
//
//  func decode(_ type: Int8?.Type) throws -> Int8?
//
//  func decode(_ type: Int16?.Type) throws -> Int16?
//
//  func decode(_ type: Int32?.Type) throws -> Int32?
//
//  func decode(_ type: Int64?.Type) throws -> Int64?
//
//  func decode(_ type: String?.Type) throws -> String?
//
//  func decode(_ type: UInt?.Type) throws -> UInt?
//
//  func decode(_ type: UInt8?.Type) throws -> UInt8?
//
//  func decode(_ type: UInt16?.Type) throws -> UInt16?
//
//  func decode(_ type: UInt32?.Type) throws -> UInt32?
//
//  func decode(_ type: UInt64?.Type) throws -> UInt64?
//
//  func decodeColumns<T: Table>(_ type: T?.Type) throws -> T?
//
//  func decode<T: QueryDecodable>(_ type: T.Type) throws -> T
//
//  func decode<T: QueryRepresentable>(_ type: T.Type) throws -> T.QueryOutput
//}
//
//extension QueryDecoder {
//  @inlinable
//  @inline(__always)
//  public func decode<T: QueryDecodable>(_ type: T.Type = T.self) throws -> T {
//    try T(decoder: self)
//  }
//
//  @inlinable
//  @inline(__always)
//  public func decode<T: QueryRepresentable>(_ type: T.Type = T.self) throws -> T.QueryOutput {
//    try T(decoder: self).queryOutput
//  }
//}
