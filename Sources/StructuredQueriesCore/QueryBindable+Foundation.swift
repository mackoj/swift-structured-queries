import Foundation

// TODO: Make it easier to conform by delegating to other conformances?

extension Data: QueryBindable {
  public var queryBinding: QueryBinding {
    .blob(ContiguousArray(self))
  }

  public init(decoder: inout some QueryDecoder) throws {
    try self.init(ContiguousArray(decoder: &decoder))
  }
}

extension URL: QueryBindable {
  public var queryBinding: QueryBinding {
    .text(absoluteString)
  }

  public init(decoder: inout some QueryDecoder) throws {
    guard let url = Self(string: try String(decoder: &decoder)) else {
      throw InvalidURL()
    }
    self = url
  }
}

private struct InvalidURL: Error {}
