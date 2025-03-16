import Foundation

// TODO: Make it easier to conform by delegating to other conformances?

extension Data: QueryBindable {
  public var queryBinding: QueryBinding {
    .blob(ContiguousArray(self))
  }

  public init(decoder: some QueryDecoder) throws {
    try self.init(decoder.decode(ContiguousArray.self))
  }
}

extension URL: QueryBindable {
  public var queryBinding: QueryBinding {
    .text(absoluteString)
  }

  public init(decoder: some QueryDecoder) throws {
    guard let url = Self(string: try decoder.decode(String.self)) else {
      throw InvalidURL()
    }
    self = url
  }
}

private struct InvalidURL: Error {}
