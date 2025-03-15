import Foundation

extension Date {
  @available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
  public struct ISO8601Representation: QueryRepresentable {
    public var queryOutput: Date

    public init(queryOutput: Date) {
      self.queryOutput = queryOutput
    }
  }
}

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
extension Date.ISO8601Representation: QueryBindable {
  public var queryBinding: QueryBinding {
    .text(queryOutput.formatted(.iso8601.currentTimestamp(includingFractionalSeconds: true)))
  }
}

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
extension Date.ISO8601Representation: QueryDecodable {
  public init(decoder: some QueryDecoder) throws {
    let queryOutput = try decoder.decode(String.self)
    do {
      self.init(
        queryOutput: try Date(
          queryOutput,
          strategy: .iso8601.currentTimestamp(includingFractionalSeconds: true)
        )
      )
    } catch {
      self.init(
        queryOutput: try Date(
          queryOutput,
          strategy: .iso8601.currentTimestamp(includingFractionalSeconds: false)
        )
      )
    }
  }
}

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
extension Date.ISO8601Representation: SQLiteType {
  public static var typeAffinity: String {
    String.typeAffinity
  }
}

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
extension Date.ISO8601FormatStyle {
  fileprivate func currentTimestamp(includingFractionalSeconds: Bool) -> Self {
    year().month().day()
      .dateTimeSeparator(.space)
      .time(includingFractionalSeconds: includingFractionalSeconds)
  }
}
