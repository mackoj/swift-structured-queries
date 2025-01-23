import Foundation

extension QueryBindingStrategy where Self == SQLiteISO8601Strategy {
  public static var iso8601: Self { Self() }
}

extension QueryBindingStrategy where Self == SQLiteUnixTimeStrategy {
  public static var unixTime: Self { Self() }
}

extension QueryBindingStrategy where Self == SQLiteJulianDayStrategy {
  public static var julianDay: Self { Self() }
}

extension QueryBindingStrategy where Self == SQLiteUUIDBytesStrategy {
  public static var uuidBytes: Self { Self() }
}

extension QueryBindingStrategy where Self == SQLiteUUIDUppercasedStrategy {
  public static var uuidUppercased: Self { Self() }
}

extension QueryBindingStrategy where Self == SQLiteUUIDLowercasedStrategy {
  public static var uuidLowercased: Self { Self() }
}

extension QueryBindingStrategy {
  public static func sqlite(_ strategy: Self.Name) -> Self where Self == SQLiteISO8601Strategy {
    Self()
  }

  public static func sqlite(_ strategy: Self.Name) -> Self where Self == SQLiteUnixTimeStrategy {
    Self()
  }

  public static func sqlite(_ strategy: Self.Name) -> Self where Self == SQLiteJulianDayStrategy {
    Self()
  }

  public static func sqlite(_ strategy: Self.Name) -> Self where Self == SQLiteUUIDBytesStrategy {
    Self()
  }

  public static func sqlite(_ strategy: Self.Name) -> Self
  where Self == SQLiteUUIDLowercasedStrategy {
    Self()
  }

  public static func sqlite(_ strategy: Self.Name) -> Self
  where Self == SQLiteUUIDUppercasedStrategy {
    Self()
  }
}

public struct SQLiteISO8601Strategy: QueryBindingStrategy {
  public struct Name: Sendable { public static let iso8601 = Self() }
  public init() {}
  public func fromQueryBindable(_ rawValue: String) throws -> Date {
    try Date(rawValue, strategy: .iso8601)
  }
  public func toQueryBindable(_ representable: Date) -> String {
    representable.formatted(.iso8601)
  }
}

public struct SQLiteUnixTimeStrategy: QueryBindingStrategy {
  public struct Name: Sendable { public static let unixTime = Self() }
  public init() {}
  public func fromQueryBindable(_ rawValue: Int) -> Date {
    Date(timeIntervalSince1970: TimeInterval(rawValue))
  }
  public func toQueryBindable(_ representable: Date) -> Int {
    Int(representable.timeIntervalSince1970)
  }
}

public struct SQLiteJulianDayStrategy: QueryBindingStrategy {
  public struct Name: Sendable { public static let julianDay = Self() }
  public init() {}
  public func fromQueryBindable(_ rawValue: Double) -> Date {
    Date(timeIntervalSince1970: (rawValue - 2440587.5) * 86400)
  }
  public func toQueryBindable(_ representable: Date) -> Double {
    2440587.5 + representable.timeIntervalSince1970 / 86400
  }
}

public struct SQLiteUUIDBytesStrategy: QueryBindingStrategy {
  public struct Name: Sendable { public static let uuidBytes = Self() }
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

public struct SQLiteUUIDUppercasedStrategy: QueryBindingStrategy {
  public struct Name: Sendable { public static let uuidUppercased = Self() }
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

public struct SQLiteUUIDLowercasedStrategy: QueryBindingStrategy {
  public struct Name: Sendable { public static let uuidLowercased = Self() }
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
