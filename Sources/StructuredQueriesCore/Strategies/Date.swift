import Foundation

// TODO: Restruture to .sqlite(.iso8601) (as String), .sqlite(.unixEpoch) (as Int), .sqlite(.julianDays) (as Double)

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
extension QueryBindingStrategy where Self == ISO8601Strategy {
  public static var iso8601: Self { Self() }
}

@available(iOS 15, macOS 12, tvOS 15, watchOS 8, *)
public struct ISO8601Strategy: QueryBindingStrategy {
  public init() {}
  public func fromQueryBindable(_ rawValue: String) throws -> Date {
    try Date(rawValue, strategy: .iso8601)
  }
  public func toQueryBindable(_ representable: Date) -> String {
    representable.formatted(.iso8601)
  }
}

public struct TimeIntervalSince1970Strategy: QueryBindingStrategy {
  public init() {}
  public func fromQueryBindable(_ rawValue: Double) throws -> Date {
    Date(timeIntervalSince1970: rawValue)
  }
  public func toQueryBindable(_ representable: Date) -> Double {
    representable.timeIntervalSince1970
  }
}

extension QueryBindingStrategy where Self == TimeIntervalSince1970Strategy {
  public static var timeIntervalSince1970: Self { Self() }
}
