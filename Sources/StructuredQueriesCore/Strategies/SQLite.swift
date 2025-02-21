import Foundation

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
extension QueryBindingStrategy where Self == ISO8601Strategy {
  public static var iso8601: Self { Self() }
}

extension QueryBindingStrategy where Self == UnixTimeStrategy {
  public static var unixTime: Self { Self() }
}

extension QueryBindingStrategy where Self == JulianDayStrategy {
  public static var julianDay: Self { Self() }
}

extension QueryBindingStrategy where Self == UUIDBytesStrategy {
  public static var uuidBytes: Self { Self() }
}

extension QueryBindingStrategy where Self == UUIDUppercasedStrategy {
  public static var uuidUppercased: Self { Self() }
}

extension QueryBindingStrategy where Self == UUIDLowercasedStrategy {
  public static var uuidLowercased: Self { Self() }
}

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
public struct ISO8601Strategy: QueryBindingStrategy {
  public init() {}
  public static func fromQueryBindable(_ rawValue: String) throws -> Date {
    // NB: Can simplify this once ISO8601 'includingFractionalSeconds' is fixed.
    //     https://forums.swift.org/t/pitch-iso8601-components-format-style/77990
    do {
      return try Date(
        rawValue,
        strategy: .iso8601.currentTimestamp(includingFractionalSeconds: true)
      )
    } catch {
      return try Date(
        rawValue,
        strategy: .iso8601.currentTimestamp(includingFractionalSeconds: false)
      )
    }
  }
  public static func toQueryBindable(_ representable: Date) -> String {
    representable.formatted(.iso8601.currentTimestamp(includingFractionalSeconds: true))
  }
}

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
fileprivate extension Date.ISO8601FormatStyle {
  func currentTimestamp(includingFractionalSeconds: Bool) -> Self {
    year().month().day()
      .dateTimeSeparator(.space)
      .time(includingFractionalSeconds: includingFractionalSeconds)
  }
}

public struct UnixTimeStrategy: QueryBindingStrategy {
  public init() {}
  public static func fromQueryBindable(_ rawValue: Int) -> Date {
    Date(timeIntervalSince1970: TimeInterval(rawValue))
  }
  public static func toQueryBindable(_ representable: Date) -> Int {
    Int(representable.timeIntervalSince1970)
  }
}

public struct JulianDayStrategy: QueryBindingStrategy {
  public init() {}
  public static func fromQueryBindable(_ rawValue: Double) -> Date {
    Date(timeIntervalSince1970: (rawValue - 2440587.5) * 86400)
  }
  public static func toQueryBindable(_ representable: Date) -> Double {
    2440587.5 + representable.timeIntervalSince1970 / 86400
  }
}

public struct UUIDBytesStrategy: QueryBindingStrategy {
  public init() {}
  public static func fromQueryBindable(_ rawValue: [UInt8]) throws -> UUID {
    guard rawValue.count == 16 else {
      struct InvalidBytes: Error {}
      throw InvalidBytes()
    }
    return rawValue.withUnsafeBytes {
      UUID(uuid: $0.load(as: uuid_t.self))
    }
  }
  public static func toQueryBindable(_ representable: UUID) -> [UInt8] {
    withUnsafeBytes(of: representable.uuid, [UInt8].init(_:))
  }
}

public struct UUIDUppercasedStrategy: QueryBindingStrategy {
  public init() {}
  public static func fromQueryBindable(_ rawValue: String) throws -> UUID {
    guard let uuid = UUID(uuidString: rawValue) else {
      struct InvalidString: Error {}
      throw InvalidString()
    }
    return uuid
  }
  public static func toQueryBindable(_ representable: UUID) -> String {
    representable.uuidString
  }
}

public struct UUIDLowercasedStrategy: QueryBindingStrategy {
  public init() {}
  public static func fromQueryBindable(_ rawValue: String) throws -> UUID {
    guard let uuid = UUID(uuidString: rawValue) else {
      struct InvalidString: Error {}
      throw InvalidString()
    }
    return uuid
  }
  public static func toQueryBindable(_ representable: UUID) -> String {
    representable.uuidString.lowercased()
  }
}
