extension QueryExpression /*where QueryOutput: Equatable*/ {
  public static func == (
    lhs: Self, rhs: some QueryExpression<QueryOutput>
  ) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: lhs, operator: "=", rhs: rhs)
  }

  public static func != (
    lhs: Self, rhs: some QueryExpression<QueryOutput>
  ) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: lhs, operator: "<>", rhs: rhs)
  }

  @_disfavoredOverload
  public static func == (
    lhs: Self, rhs: some QueryExpression<QueryOutput?>
  ) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: lhs, operator: isNull(rhs) ? "IS" : "=", rhs: rhs)
  }

  @_disfavoredOverload
  public static func != (
    lhs: Self, rhs: some QueryExpression<QueryOutput?>
  ) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: lhs, operator: isNull(rhs) ? "IS NOT" : "<>", rhs: rhs)
  }
}

private func isNull<QueryOutput>(_ expression: some QueryExpression<QueryOutput>) -> Bool {
  guard let expression = expression as? any _OptionalProtocol else { return false }
  return expression._wrapped == nil
}

extension QueryExpression where QueryOutput: _OptionalProtocol {
  public static func == (
    lhs: Self, rhs: some QueryExpression<QueryOutput.Wrapped>
  ) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: lhs, operator: "=", rhs: rhs)
  }

  public static func != (
    lhs: Self, rhs: some QueryExpression<QueryOutput.Wrapped>
  ) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: lhs, operator: "<>", rhs: rhs)
  }

  public static func == (
    lhs: Self, rhs: _Null<QueryOutput.Wrapped>
  ) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: lhs, operator: "IS", rhs: rhs)
  }

  public static func != (
    lhs: Self, rhs: _Null<QueryOutput.Wrapped>
  ) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: lhs, operator: "IS NOT", rhs: rhs)
  }

  public static func ?? (
    lhs: Self, rhs: some QueryExpression<QueryOutput.Wrapped>
  ) -> some QueryExpression<QueryOutput.Wrapped> {
    QueryFunction("coalesce", lhs, rhs)
  }

  public static func ?? (
    lhs: Self, rhs: some QueryExpression<QueryOutput>
  ) -> some QueryExpression<QueryOutput> {
    QueryFunction("coalesce", lhs, rhs)
  }

  public static func ?? (
    lhs: Self, rhs: _Null<QueryOutput.Wrapped>
  ) -> some QueryExpression<QueryOutput> {
    QueryFunction("coalesce", lhs, rhs)
  }
}

extension QueryExpression {
  @available(
    *, deprecated, message: "Comparing non-optional expression to 'NULL' always returns false"
  )
  public static func == (lhs: Self, rhs: _Null<QueryOutput>) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: lhs, operator: "IS", rhs: rhs)
  }

  @available(
    *, deprecated, message: "Comparing non-optional expression to 'NULL' always returns false"
  )
  public static func != (lhs: Self, rhs: _Null<QueryOutput>) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: lhs, operator: "IS NOT", rhs: rhs)
  }
}

public struct _Null<Wrapped>: QueryExpression {
  public typealias QueryOutput = Wrapped?
  public var queryFragment: QueryFragment { "NULL" }
}

extension _Null: ExpressibleByNilLiteral {
  public init(nilLiteral: ()) {}
}

extension QueryExpression /*where QueryOutput: Comparable*/ {
  public static func < (lhs: Self, rhs: some QueryExpression<QueryOutput>) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: lhs, operator: "<", rhs: rhs)
  }

  public static func > (lhs: Self, rhs: some QueryExpression<QueryOutput>) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: lhs, operator: ">", rhs: rhs)
  }

  public static func <= (lhs: Self, rhs: some QueryExpression<QueryOutput>) -> some QueryExpression<Bool>
  {
    BinaryOperator(lhs: lhs, operator: "<=", rhs: rhs)
  }

  public static func >= (lhs: Self, rhs: some QueryExpression<QueryOutput>) -> some QueryExpression<Bool>
  {
    BinaryOperator(lhs: lhs, operator: ">=", rhs: rhs)
  }
}

extension QueryExpression where QueryOutput == Bool {
  public static func && (
    lhs: Self, rhs: some QueryExpression<QueryOutput>
  ) -> some QueryExpression<QueryOutput> {
    BinaryOperator(lhs: lhs, operator: "AND", rhs: rhs)
  }

  public static func || (
    lhs: Self, rhs: some QueryExpression<QueryOutput>
  ) -> some QueryExpression<QueryOutput> {
    BinaryOperator(lhs: lhs, operator: "OR", rhs: rhs)
  }

  public static prefix func ! (expression: Self) -> some QueryExpression<QueryOutput> {
    UnaryOperator(operator: "NOT", base: expression)
  }
}

extension AnyQueryExpression<Bool> {
  public mutating func toggle() {
    self = Self(!self)
  }
}

extension QueryExpression where QueryOutput: Numeric {
  public static func + (lhs: Self, rhs: some QueryExpression<QueryOutput>) -> some QueryExpression<QueryOutput>
  {
    BinaryOperator(lhs: lhs, operator: "+", rhs: rhs)
  }

  public static func - (lhs: Self, rhs: some QueryExpression<QueryOutput>) -> some QueryExpression<QueryOutput>
  {
    BinaryOperator(lhs: lhs, operator: "-", rhs: rhs)
  }

  public static func * (lhs: Self, rhs: some QueryExpression<QueryOutput>) -> some QueryExpression<QueryOutput>
  {
    BinaryOperator(lhs: lhs, operator: "*", rhs: rhs)
  }

  public static func / (lhs: Self, rhs: some QueryExpression<QueryOutput>) -> some QueryExpression<QueryOutput>
  {
    BinaryOperator(lhs: lhs, operator: "/", rhs: rhs)
  }

  public static prefix func - (expression: Self) -> some QueryExpression<QueryOutput> {
    UnaryOperator(operator: "-", base: expression, separator: "")
  }

  public static prefix func + (expression: Self) -> some QueryExpression<QueryOutput> {
    UnaryOperator(operator: "+", base: expression, separator: "")
  }
}

extension AnyQueryExpression where QueryOutput: Numeric {
  public static func += (lhs: inout Self, rhs: some QueryExpression<QueryOutput>) {
    lhs = Self(lhs + rhs)
  }

  public static func -= (lhs: inout Self, rhs: some QueryExpression<QueryOutput>) {
    lhs = Self(lhs - rhs)
  }

  public static func *= (lhs: inout Self, rhs: some QueryExpression<QueryOutput>) {
    lhs = Self(lhs * rhs)
  }

  public static func /= (lhs: inout Self, rhs: some QueryExpression<QueryOutput>) {
    lhs = Self(lhs / rhs)
  }

  public mutating func negate() {
    self = Self(-self)
  }
}

extension QueryExpression where QueryOutput == Int {
  public static func % (lhs: Self, rhs: some QueryExpression<QueryOutput>) -> some QueryExpression<QueryOutput>
  {
    BinaryOperator(lhs: lhs, operator: "%", rhs: rhs)
  }

  public static func & (lhs: Self, rhs: some QueryExpression<QueryOutput>) -> some QueryExpression<QueryOutput>
  {
    BinaryOperator(lhs: lhs, operator: "&", rhs: rhs)
  }

  public static func | (lhs: Self, rhs: some QueryExpression<QueryOutput>) -> some QueryExpression<QueryOutput>
  {
    BinaryOperator(lhs: lhs, operator: "|", rhs: rhs)
  }

  public static func << (lhs: Self, rhs: some QueryExpression<QueryOutput>) -> some QueryExpression<QueryOutput>
  {
    BinaryOperator(lhs: lhs, operator: "<<", rhs: rhs)
  }

  public static func >> (lhs: Self, rhs: some QueryExpression<QueryOutput>) -> some QueryExpression<QueryOutput>
  {
    BinaryOperator(lhs: lhs, operator: ">>", rhs: rhs)
  }

  public static prefix func ~ (expression: Self) -> some QueryExpression<QueryOutput> {
    UnaryOperator(operator: "~", base: expression, separator: "")
  }
}

extension AnyQueryExpression<Int> {
  public static func %= (lhs: inout Self, rhs: some QueryExpression<QueryOutput>) {
    lhs = Self(lhs % rhs)
  }

  public static func &= (lhs: inout Self, rhs: some QueryExpression<QueryOutput>) {
    lhs = Self(lhs & rhs)
  }

  public static func |= (lhs: inout Self, rhs: some QueryExpression<QueryOutput>) {
    lhs = Self(lhs | rhs)
  }

  public static func <<= (lhs: inout Self, rhs: some QueryExpression<QueryOutput>) {
    lhs = Self(lhs << rhs)
  }

  public static func >>= (lhs: inout Self, rhs: some QueryExpression<QueryOutput>) {
    lhs = Self(lhs >> rhs)
  }
}

public enum Collation {
  case binary
  case nocase
  case rtrim
}

extension Collation: QueryExpression {
  public typealias QueryOutput = Void
  public var queryFragment: QueryFragment {
    switch self {
    case .binary: return "BINARY"
    case .nocase: return "NOCASE"
    case .rtrim: return "RTRIM"
    }
  }
}

extension QueryExpression where QueryOutput == String {
  public static func + (
    lhs: Self, rhs: some QueryExpression<QueryOutput>
  ) -> some QueryExpression<QueryOutput> {
    BinaryOperator(lhs: lhs, operator: "||", rhs: rhs)
  }

  public func collate(_ collation: Collation) -> some QueryExpression<QueryOutput> {
    BinaryOperator(lhs: self, operator: "COLLATE", rhs: collation)
  }

  public func hasPrefix(_ other: QueryOutput) -> some QueryExpression<Bool> {
    like("\(other)%")
  }

  public func hasSuffix(_ other: QueryOutput) -> some QueryExpression<Bool> {
    like("%\(other)")
  }

  @_disfavoredOverload
  public func contains(_ other: QueryOutput) -> some QueryExpression<Bool> {
    like("%\(other)%")
  }

  public func like(_ other: QueryOutput) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: self, operator: "LIKE", rhs: "\(other)")
  }

  public func glob(_ other: QueryOutput) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: self, operator: "GLOB", rhs: "\(other)")
  }
}

extension AnyQueryExpression<String> {
  public static func += (lhs: inout Self, rhs: some QueryExpression<QueryOutput>) {
    lhs = Self(lhs + rhs)
  }

  public mutating func append(_ other: some QueryExpression<QueryOutput>) {
    self += other
  }

  public mutating func append(contentsOf other: some QueryExpression<QueryOutput>) {
    self += other
  }
}

extension QueryExpression {
  public func contains<Element>(_ element: some QueryExpression<Element>) -> some QueryExpression<
    Bool
  >
  where QueryOutput == [Element] {
    BinaryOperator(lhs: element, operator: "IN", rhs: Parenthesize(self))
  }

  public func contains<Bound>(_ element: some QueryExpression<Bound>) -> some QueryExpression<Bool>
  where QueryOutput == ClosedRange<Bound> {
    BinaryOperator(lhs: element, operator: "BETWEEN", rhs: self)
  }
}

private struct UnaryOperator<QueryOutput, Base: QueryExpression>: QueryExpression {
  let `operator`: String
  let base: Base
  var separator = " "

  var queryFragment: QueryFragment { "\(raw: `operator`)\(raw: separator)(\(base.queryFragment))" }
}

struct BinaryOperator<QueryOutput, LHS: QueryExpression, RHS: QueryExpression>: QueryExpression {
  let lhs: LHS
  let `operator`: String
  let rhs: RHS

  var queryFragment: QueryFragment {
    "(\(lhs.queryFragment) \(raw: `operator`) \(rhs.queryFragment))"
  }
}

struct Parenthesize<Base: QueryExpression>: QueryExpression {
  typealias QueryOutput = Base.QueryOutput
  let base: Base

  init(_ base: Base) { self.base = base }

  var queryFragment: QueryFragment { "(\(base.queryFragment))" }
}
