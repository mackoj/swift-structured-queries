public protocol QueryDecoder {
  func decode(_ type: Double.Type) throws -> Double

  func decode(_ type: Int64.Type) throws -> Int64

  func decode(_ type: String.Type) throws -> String

  func decode(_ type: [UInt8].Type) throws -> [UInt8]

  func decode<T: QueryDecodable>(_ type: T.Type) throws -> T

  func decodeNil() throws -> Bool
}

extension QueryDecoder {
  public func decode<T: QueryDecodable>(_ type: T.Type) throws -> T {
    try T(decoder: self)
  }
}
