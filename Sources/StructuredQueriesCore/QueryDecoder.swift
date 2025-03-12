public protocol QueryDecoder {
  func decode(_ type: Double.Type) throws -> Double

  func decode(_ type: Int64.Type) throws -> Int64

  func decode(_ type: String.Type) throws -> String

  func decode(_ type: ContiguousArray<UInt8>.Type) throws -> ContiguousArray<UInt8>

  func decode<T: QueryDecodable>(_ type: T.Type) throws -> T

  func decode<T: QueryRepresentable>(_ type: T.Type) throws -> T.QueryOutput

  func decodeNil() throws -> Bool
}

extension QueryDecoder {
  public func decode<T: QueryDecodable>(_ type: T.Type = T.self) throws -> T {
    try T(decoder: self)
  }

  public func decode<T: QueryRepresentable>(_ type: T.Type = T.self) throws -> T.QueryOutput {
    try T(decoder: self).queryOutput
  }
}

