import Foundation

extension Date {
  public struct UnixTimeRepresentation: QueryRepresentable {
    public var queryOutput: Date

    public init(queryOutput: Date) {
      self.queryOutput = queryOutput
    }
  }
}

extension Date.UnixTimeRepresentation: QueryBindable {
  public var queryBinding: QueryBinding {
    .int(Int64(queryOutput.timeIntervalSince1970))
  }
}

extension Date.UnixTimeRepresentation: QueryDecodable {
  public init(decoder: some QueryDecoder) throws {
    try self.init(queryOutput: Date(timeIntervalSince1970: Double(decoder.decode(Int.self))))
  }
}

extension Date.UnixTimeRepresentation: SQLiteType {
  public static var typeAffinity: String {
    Int.typeAffinity
  }
}
