import Foundation

extension UUID {
  public struct UppercasedRepresentation: QueryRepresentable {
    public var queryOutput: UUID

    public init(queryOutput: UUID) {
      self.queryOutput = queryOutput
    }
  }
}

extension UUID.UppercasedRepresentation: QueryBindable {
  public var queryBinding: QueryBinding {
    .text(queryOutput.uuidString)
  }
}

extension UUID.UppercasedRepresentation: QueryDecodable {
  public init(decoder: some QueryDecoder) throws {
    guard let uuid = try UUID(uuidString: decoder.decode(String.self)) else {
      throw InvalidString()
    }
    self.init(queryOutput: uuid)
  }

  private struct InvalidString: Error {}
}

extension UUID.UppercasedRepresentation: SQLiteType {
  public static var typeAffinity: SQLiteTypeAffinity {
    String.typeAffinity
  }
}
