import Foundation

extension Date {
  public struct JulianDayRepresentation: QueryRepresentable {
    public var queryOutput: Date

    public init(queryOutput: Date) {
      self.queryOutput = queryOutput
    }
  }
}

extension Date.JulianDayRepresentation: QueryBindable {
  public var queryBinding: QueryBinding {
    .double(2440587.5 + queryOutput.timeIntervalSince1970 / 86400)
  }
}

extension Date.JulianDayRepresentation: QueryDecodable {
  public init(decoder: some QueryDecoder) throws {
    try self.init(
      queryOutput: Date(timeIntervalSince1970: (decoder.decode(Double.self) - 2440587.5) * 86400)
    )
  }
}
