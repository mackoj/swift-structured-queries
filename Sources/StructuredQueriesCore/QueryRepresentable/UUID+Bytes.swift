import Foundation

extension UUID {
  public struct BytesRepresentation: QueryRepresentable {
    public var queryOutput: UUID

    public init(queryOutput: UUID) {
      self.queryOutput = queryOutput
    }
  }
}

extension UUID.BytesRepresentation: QueryBindable {
  public var queryBinding: QueryBinding {
    .blob(withUnsafeBytes(of: queryOutput.uuid, ContiguousArray<UInt8>.init(_:)))
  }
}

extension UUID.BytesRepresentation: QueryDecodable {
  public init(decoder: inout some QueryDecoder) throws {
    let queryOutput = try ContiguousArray<UInt8>(decoder: &decoder)
    guard queryOutput.count == 16 else {
      throw InvalidBytes()
    }
    self.init(
      queryOutput: queryOutput.withUnsafeBytes {
        UUID(uuid: $0.load(as: uuid_t.self))
      }
    )
  }

  private struct InvalidBytes: Error {}
}

extension UUID.BytesRepresentation: SQLiteType {
  public static var typeAffinity: SQLiteTypeAffinity {
    ContiguousArray.typeAffinity
  }
}
