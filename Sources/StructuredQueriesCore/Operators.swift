extension QueryExpression where Value: Equatable {
  public static func == (
    lhs: Self, rhs: some QueryExpression<Value>
  ) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: lhs, operator: "=", rhs: rhs)
  }

  public static func != (
    lhs: Self, rhs: some QueryExpression<Value>
  ) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: lhs, operator: "<>", rhs: rhs)
  }

  public static func == (
    lhs: Self, rhs: some QueryExpression<Value?>
  ) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: lhs, operator: isNull(rhs) ? "IS" : "=", rhs: rhs)
  }

  public static func != (
    lhs: Self, rhs: some QueryExpression<Value?>
  ) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: lhs, operator: isNull(rhs) ? "IS NOT" : "<>", rhs: rhs)
  }
}

private func isNull<Value>(_ expression: some QueryExpression<Value>) -> Bool {
  guard let expression = expression as? any _OptionalProtocol else { return false }
  return expression._wrapped == nil
}

extension QueryExpression where Value: _OptionalProtocol {
  public static func == (
    lhs: Self, rhs: some QueryExpression<Value.Wrapped>
  ) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: lhs, operator: "=", rhs: rhs)
  }

  public static func != (
    lhs: Self, rhs: some QueryExpression<Value.Wrapped>
  ) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: lhs, operator: "<>", rhs: rhs)
  }

  public static func == (
    lhs: Self, rhs: _Null<Value.Wrapped>
  ) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: lhs, operator: "IS", rhs: rhs)
  }

  public static func != (
    lhs: Self, rhs: _Null<Value.Wrapped>
  ) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: lhs, operator: "IS NOT", rhs: rhs)
  }

  public static func ?? (
    lhs: Self, rhs: some QueryExpression<Value.Wrapped>
  ) -> some QueryExpression<Value.Wrapped> {
    QueryFunction("coalesce", lhs, rhs)
  }

  public static func ?? (
    lhs: Self, rhs: some QueryExpression<Value>
  ) -> some QueryExpression<Value> {
    QueryFunction("coalesce", lhs, rhs)
  }

  public static func ?? (
    lhs: Self, rhs: _Null<Value.Wrapped>
  ) -> some QueryExpression<Value> {
    QueryFunction("coalesce", lhs, rhs)
  }
}

extension QueryExpression {
  @available(
    *, deprecated, message: "Comparing non-optional expression to 'NULL' always returns false"
  )
  public static func == (lhs: Self, rhs: _Null<Value>) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: lhs, operator: "IS", rhs: rhs)
  }

  @available(
    *, deprecated, message: "Comparing non-optional expression to 'NULL' always returns false"
  )
  public static func != (lhs: Self, rhs: _Null<Value>) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: lhs, operator: "IS NOT", rhs: rhs)
  }
}

public struct _Null<Wrapped>: QueryExpression {
  public typealias Value = Wrapped?
  public var queryString: String { "NULL" }
  public var queryBindings: [QueryBinding] { [] }
}

extension _Null: ExpressibleByNilLiteral {
  public init(nilLiteral: ()) {}
}

extension QueryExpression where Value: Comparable {
  public static func < (lhs: Self, rhs: some QueryExpression<Value>) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: lhs, operator: "<", rhs: rhs)
  }

  public static func > (lhs: Self, rhs: some QueryExpression<Value>) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: lhs, operator: ">", rhs: rhs)
  }

  public static func <= (lhs: Self, rhs: some QueryExpression<Value>) -> some QueryExpression<Bool>
  {
    BinaryOperator(lhs: lhs, operator: "<=", rhs: rhs)
  }

  public static func >= (lhs: Self, rhs: some QueryExpression<Value>) -> some QueryExpression<Bool>
  {
    BinaryOperator(lhs: lhs, operator: ">=", rhs: rhs)
  }
}

extension QueryExpression where Value == Bool {
  public static func && (
    lhs: Self, rhs: some QueryExpression<Value>
  ) -> some QueryExpression<Value> {
    BinaryOperator(lhs: lhs, operator: "AND", rhs: rhs)
  }

  public static func || (
    lhs: Self, rhs: some QueryExpression<Value>
  ) -> some QueryExpression<Value> {
    BinaryOperator(lhs: lhs, operator: "OR", rhs: rhs)
  }

  public static prefix func ! (expression: Self) -> some QueryExpression<Value> {
    UnaryOperator(operator: "NOT", base: expression)
  }
}

extension AnyQueryExpression<Bool> {
  public mutating func toggle() {
    self = Self(!self)
  }
}

extension QueryExpression where Value: Numeric {
  public static func + (lhs: Self, rhs: some QueryExpression<Value>) -> some QueryExpression<Value>
  {
    BinaryOperator(lhs: lhs, operator: "+", rhs: rhs)
  }

  public static func - (lhs: Self, rhs: some QueryExpression<Value>) -> some QueryExpression<Value>
  {
    BinaryOperator(lhs: lhs, operator: "-", rhs: rhs)
  }

  public static func * (lhs: Self, rhs: some QueryExpression<Value>) -> some QueryExpression<Value>
  {
    BinaryOperator(lhs: lhs, operator: "*", rhs: rhs)
  }

  public static func / (lhs: Self, rhs: some QueryExpression<Value>) -> some QueryExpression<Value>
  {
    BinaryOperator(lhs: lhs, operator: "/", rhs: rhs)
  }

  public static prefix func - (expression: Self) -> some QueryExpression<Value> {
    UnaryOperator(operator: "-", base: expression, separator: "")
  }

  public static prefix func + (expression: Self) -> some QueryExpression<Value> {
    UnaryOperator(operator: "+", base: expression, separator: "")
  }
}

extension AnyQueryExpression where Value: Numeric {
  public static func += (lhs: inout Self, rhs: some QueryExpression<Value>) {
    lhs = Self(lhs + rhs)
  }

  public static func -= (lhs: inout Self, rhs: some QueryExpression<Value>) {
    lhs = Self(lhs - rhs)
  }

  public static func *= (lhs: inout Self, rhs: some QueryExpression<Value>) {
    lhs = Self(lhs * rhs)
  }

  public static func /= (lhs: inout Self, rhs: some QueryExpression<Value>) {
    lhs = Self(lhs / rhs)
  }

  public mutating func negate() {
    self = Self(-self)
  }
}

extension QueryExpression where Value == Int {
  public static func % (lhs: Self, rhs: some QueryExpression<Value>) -> some QueryExpression<Value>
  {
    BinaryOperator(lhs: lhs, operator: "%", rhs: rhs)
  }

  public static func & (lhs: Self, rhs: some QueryExpression<Value>) -> some QueryExpression<Value>
  {
    BinaryOperator(lhs: lhs, operator: "&", rhs: rhs)
  }

  public static func | (lhs: Self, rhs: some QueryExpression<Value>) -> some QueryExpression<Value>
  {
    BinaryOperator(lhs: lhs, operator: "|", rhs: rhs)
  }

  public static func << (lhs: Self, rhs: some QueryExpression<Value>) -> some QueryExpression<Value>
  {
    BinaryOperator(lhs: lhs, operator: "<<", rhs: rhs)
  }

  public static func >> (lhs: Self, rhs: some QueryExpression<Value>) -> some QueryExpression<Value>
  {
    BinaryOperator(lhs: lhs, operator: ">>", rhs: rhs)
  }

  public static prefix func ~ (expression: Self) -> some QueryExpression<Value> {
    UnaryOperator(operator: "~", base: expression, separator: "")
  }
}

extension AnyQueryExpression<Int> {
  public static func %= (lhs: inout Self, rhs: some QueryExpression<Value>) {
    lhs = Self(lhs % rhs)
  }

  public static func &= (lhs: inout Self, rhs: some QueryExpression<Value>) {
    lhs = Self(lhs & rhs)
  }

  public static func |= (lhs: inout Self, rhs: some QueryExpression<Value>) {
    lhs = Self(lhs | rhs)
  }

  public static func <<= (lhs: inout Self, rhs: some QueryExpression<Value>) {
    lhs = Self(lhs << rhs)
  }

  public static func >>= (lhs: inout Self, rhs: some QueryExpression<Value>) {
    lhs = Self(lhs >> rhs)
  }
}

public enum Collation {
  case binary
  case nocase
  case rtrim
}

extension Collation: QueryExpression {
  public typealias Value = Void
  public var queryString: String {
    switch self {
    case .binary: return "BINARY"
    case .nocase: return "NOCASE"
    case .rtrim: return "RTRIM"
    }
  }
  public var queryBindings: [QueryBinding] { [] }
}

extension QueryExpression where Value == String {
  public static func + (
    lhs: Self, rhs: some QueryExpression<Value>
  ) -> some QueryExpression<Value> {
    BinaryOperator(lhs: lhs, operator: "||", rhs: rhs)
  }

  public func collate(_ collation: Collation) -> some QueryExpression<Value> {
    BinaryOperator(lhs: self, operator: "COLLATE", rhs: collation)
  }

  public func hasPrefix(_ other: Value) -> some QueryExpression<Bool> {
    like("\(other)%")
  }

  public func hasSuffix(_ other: Value) -> some QueryExpression<Bool> {
    like("%\(other)")
  }

  public func contains(_ other: Value) -> some QueryExpression<Bool> {
    like("%\(other)%")
  }

  public func like(_ other: Value) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: self, operator: "LIKE", rhs: "\(other)")
  }

  public func glob(_ other: Value) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: self, operator: "GLOB", rhs: "\(other)")
  }
}

extension AnyQueryExpression<String> {
  public static func += (lhs: inout Self, rhs: some QueryExpression<Value>) {
    lhs = Self(lhs + rhs)
  }

  public mutating func append(_ other: some QueryExpression<Value>) {
    self += other
  }

  public mutating func append(contentsOf other: some QueryExpression<Value>) {
    self += other
  }
}

extension QueryExpression {
  public func contains<Element>(_ element: some QueryExpression<Element>) -> some QueryExpression<
    Bool
  >
  where Value == [Element] {
    BinaryOperator(lhs: element, operator: "IN", rhs: self)
  }

  public func contains<Bound>(_ element: some QueryExpression<Bound>) -> some QueryExpression<Bool>
  where Value == ClosedRange<Bound> {
    BinaryOperator(lhs: element, operator: "BETWEEN", rhs: self)
  }
}

private struct UnaryOperator<Value, Base: QueryExpression>: QueryExpression {
  let `operator`: String
  let base: Base
  var separator = " "

  var queryString: String { "\(`operator`)\(separator)(\(base.queryString))" }
  var queryBindings: [QueryBinding] { base.queryBindings }
}

private struct BinaryOperator<Value, LHS: QueryExpression, RHS: QueryExpression>: QueryExpression {
  let lhs: LHS
  let `operator`: String
  let rhs: RHS

  var queryString: String { "(\(lhs.queryString) \(`operator`) \(rhs.queryString))" }
  var queryBindings: [QueryBinding] { lhs.queryBindings + rhs.queryBindings }
}

private struct Parenthesize<Base: QueryExpression>: QueryExpression {
  typealias Value = Base.Value
  let base: Base

  init(_ base: Base) { self.base = base }

  var queryString: String { "(\(base.queryString))" }
  var queryBindings: [QueryBinding] { base.queryBindings }
}
