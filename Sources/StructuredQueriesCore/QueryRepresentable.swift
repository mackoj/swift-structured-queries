import Foundation

public protocol QueryRepresentable<QueryOutput>: QueryDecodable {
  associatedtype QueryOutput
  init(queryOutput: QueryOutput)
  var queryOutput: QueryOutput { get }
}

extension QueryRepresentable where Self: QueryDecodable, Self == QueryOutput {
  @inlinable
  @inline(__always)
  public init(queryOutput: QueryOutput) {
    self = queryOutput
  }

  @inlinable
  @inline(__always)
  public var queryOutput: QueryOutput {
    self
  }
}

extension Bool: QueryRepresentable {}

extension Double: QueryRepresentable {}

extension Float: QueryRepresentable {}

extension Int: QueryRepresentable {}

extension Int8: QueryRepresentable {}

extension Int16: QueryRepresentable {}

extension Int32: QueryRepresentable {}

extension Int64: QueryRepresentable {}

extension String: QueryRepresentable {}

extension UInt8: QueryRepresentable {}

extension UInt16: QueryRepresentable {}

extension UInt32: QueryRepresentable {}

extension ContiguousArray<UInt8>: QueryRepresentable {}
