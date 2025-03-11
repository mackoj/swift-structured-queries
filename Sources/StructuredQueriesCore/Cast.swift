extension QueryExpression {
  public func cast<Other: SQLiteType>(as _: Other.Type) -> some QueryExpression<Other> {
    Cast(base: self)
  }
}

public protocol SQLiteType: QueryBindable {
  static var typeAffinity: String { get }
}

extension SQLiteType where Self: BinaryInteger {
  // Should this be 'INTEGER'?
  public static var typeAffinity: String { "NUMERIC" }
}

extension Int: SQLiteType {}
extension Int8: SQLiteType {}
extension Int16: SQLiteType {}
extension Int32: SQLiteType {}
extension Int64: SQLiteType {}

extension UInt8: SQLiteType {}
extension UInt16: SQLiteType {}
extension UInt32: SQLiteType {}

extension SQLiteType where Self: FloatingPoint {
  // Should this be 'REAL'?
  public static var typeAffinity: String { "NUMERIC" }
}

extension Double: SQLiteType {}
extension Float: SQLiteType {}

extension Bool: SQLiteType {
  public static var typeAffinity: String { Int.typeAffinity }
}

extension String: SQLiteType {
  public static var typeAffinity: String { "TEXT" }
}

extension [UInt8]: SQLiteType {
  public static var typeAffinity: String { "BLOB" }
}

extension Optional: SQLiteType where Wrapped: SQLiteType {
  public static var typeAffinity: String { Wrapped.typeAffinity }
}

private struct Cast<QueryValue: SQLiteType, Base: QueryExpression>: QueryExpression {
  let base: Base
  var queryFragment: QueryFragment {
    "CAST(\(base.queryFragment) AS \(raw: QueryValue.typeAffinity))"
  }
}
