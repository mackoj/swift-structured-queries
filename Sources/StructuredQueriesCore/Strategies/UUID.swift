import Foundation

extension QueryBindingStrategy where Self == UUIDBytesStrategy {
  public static var uuidBytes: Self { Self() }
}

public struct UUIDBytesStrategy: QueryBindingStrategy {
  public init() {}
  public func fromQueryBindable(_ rawValue: [UInt8]) throws -> UUID {
    guard rawValue.count == 16 else {
      struct InvalidBytes: Error {}
      throw InvalidBytes()
    }
    return rawValue.withUnsafeBytes {
      UUID(uuid: $0.load(as: uuid_t.self))
    }
  }
  public func toQueryBindable(_ representable: UUID) -> [UInt8] {
    withUnsafeBytes(of: representable.uuid, [UInt8].init(_:))
  }
}

extension QueryBindingStrategy where Self == UUIDUppercasedStrategy {
  public static var uuidUppercased: Self { Self() }
}

public struct UUIDUppercasedStrategy: QueryBindingStrategy {
  public init() {}
  public func fromQueryBindable(_ rawValue: String) throws -> UUID {
    guard let uuid = UUID(uuidString: rawValue) else {
      struct InvalidString: Error {}
      throw InvalidString()
    }
    return uuid
  }
  public func toQueryBindable(_ representable: UUID) -> String {
    representable.uuidString
  }
}

extension QueryBindingStrategy where Self == UUIDLowercasedStrategy {
  public static var uuidLowercased: Self { Self() }
}

public struct UUIDLowercasedStrategy: QueryBindingStrategy {
  public init() {}
  public func fromQueryBindable(_ rawValue: String) throws -> UUID {
    guard let uuid = UUID(uuidString: rawValue) else {
      struct InvalidString: Error {}
      throw InvalidString()
    }
    return uuid
  }
  public func toQueryBindable(_ representable: UUID) -> String {
    representable.uuidString.lowercased()
  }
}
