extension QueryExpression {
  public static func == (
    lhs: Self, rhs: some QueryExpression<QueryValue>
  ) -> some QueryExpression<Bool> {
    lhs.eq(rhs)
  }

  public static func != (
    lhs: Self, rhs: some QueryExpression<QueryValue>
  ) -> some QueryExpression<Bool> {
    lhs.neq(rhs)
  }

  @_disfavoredOverload
  public static func == (
    lhs: Self, rhs: some QueryExpression<QueryValue?>
  ) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: lhs, operator: isNull(rhs) ? "IS" : "=", rhs: rhs)
  }

  @_disfavoredOverload
  public static func != (
    lhs: Self, rhs: some QueryExpression<QueryValue?>
  ) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: lhs, operator: isNull(rhs) ? "IS NOT" : "<>", rhs: rhs)
  }

  public func eq(_ other: some QueryExpression<QueryValue>) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: self, operator: "=", rhs: other)
  }

  public func neq(_ other: some QueryExpression<QueryValue>) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: self, operator: "<>", rhs: other)
  }
}

extension QueryExpression where QueryValue: _OptionalPromotable {
  public func `is`(
    _ other: some QueryExpression<QueryValue._Optionalized>
  ) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: self, operator: "IS", rhs: other)
  }

  public func isNot(
    _ other: some QueryExpression<QueryValue._Optionalized>
  ) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: self, operator: "IS NOT", rhs: other)
  }
}

private func isNull<Value>(_ expression: some QueryExpression<Value>) -> Bool {
  (expression as? any _OptionalProtocol).map { $0._wrapped == nil } ?? false
}

extension QueryExpression where QueryValue: _OptionalProtocol {
  public static func == (
    lhs: Self, rhs: some QueryExpression<QueryValue.Wrapped>
  ) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: lhs, operator: isNull(lhs) ? "IS" : "=", rhs: rhs)
  }

  public static func != (
    lhs: Self, rhs: some QueryExpression<QueryValue.Wrapped>
  ) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: lhs, operator: isNull(lhs) ? "IS NOT" : "<>", rhs: rhs)
  }

  public static func == (
    lhs: Self, rhs: some QueryExpression<QueryValue>
  ) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: lhs, operator: isNull(lhs) || isNull(rhs) ? "IS" : "=", rhs: rhs)
  }

  public static func != (
    lhs: Self, rhs: some QueryExpression<QueryValue>
  ) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: lhs, operator: isNull(lhs) || isNull(rhs) ? "IS NOT" : "<>", rhs: rhs)
  }

  public func eq(_ other: some QueryExpression<QueryValue.Wrapped>) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: self, operator: "=", rhs: other)
  }

  public func neq(_ other: some QueryExpression<QueryValue.Wrapped>) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: self, operator: "=", rhs: other)
  }

  public func eq(_ other: some QueryExpression<QueryValue>) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: self, operator: "=", rhs: other)
  }

  public func neq(_ other: some QueryExpression<QueryValue>) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: self, operator: "=", rhs: other)
  }

  public func `is`(
    _ other: some QueryExpression<QueryValue>
  ) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: self, operator: "IS", rhs: other)
  }

  public func isNot(
    _ other: some QueryExpression<QueryValue>
  ) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: self, operator: "IS NOT", rhs: other)
  }
}

extension QueryExpression {
  public static func == (lhs: Self, rhs: _Null<QueryValue>) -> some QueryExpression<Bool> {
    lhs.is(rhs)
  }

  public static func != (lhs: Self, rhs: _Null<QueryValue>) -> some QueryExpression<Bool> {
    lhs.isNot(rhs)
  }

  public func `is`(
    _ other: _Null<QueryValue>
  ) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: self, operator: "IS", rhs: other)
  }

  public func isNot(
    _ other: _Null<QueryValue>
  ) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: self, operator: "IS NOT", rhs: other)
  }
}

public struct _Null<Wrapped>: QueryExpression {
  public typealias QueryValue = Wrapped?
  public var queryFragment: QueryFragment { "NULL" }
}

extension _Null: ExpressibleByNilLiteral {
  public init(nilLiteral: ()) {}
}

extension QueryExpression {
  public static func < (
    lhs: Self, rhs: some QueryExpression<QueryValue>
  ) -> some QueryExpression<Bool> {
    lhs.lt(rhs)
  }

  public static func > (
    lhs: Self, rhs: some QueryExpression<QueryValue>
  ) -> some QueryExpression<Bool> {
    lhs.gt(rhs)
  }

  public static func <= (
    lhs: Self, rhs: some QueryExpression<QueryValue>
  ) -> some QueryExpression<Bool> {
    lhs.lte(rhs)
  }

  public static func >= (
    lhs: Self, rhs: some QueryExpression<QueryValue>
  ) -> some QueryExpression<Bool> {
    lhs.gte(rhs)
  }

  public func lt(
    _ other: some QueryExpression<QueryValue>
  ) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: self, operator: "<", rhs: other)
  }

  public func gt(
    _ other: some QueryExpression<QueryValue>
  ) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: self, operator: ">", rhs: other)
  }

  public func lte(
    _ other: some QueryExpression<QueryValue>
  ) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: self, operator: "<=", rhs: other)
  }

  public func gte(
    _ other: some QueryExpression<QueryValue>
  ) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: self, operator: ">=", rhs: other)
  }
}

extension QueryExpression where QueryValue == Bool {
  public static func && (
    lhs: Self, rhs: some QueryExpression<QueryValue>
  ) -> some QueryExpression<QueryValue> {
    lhs.and(rhs)
  }

  public static func || (
    lhs: Self, rhs: some QueryExpression<QueryValue>
  ) -> some QueryExpression<QueryValue> {
    lhs.or(rhs)
  }

  public static prefix func ! (expression: Self) -> some QueryExpression<QueryValue> {
    expression.not()
  }

  public func and(_ other: some QueryExpression<QueryValue>) -> some QueryExpression<QueryValue> {
    BinaryOperator(lhs: self, operator: "AND", rhs: other)
  }

  public func or(_ other: some QueryExpression<QueryValue>) -> some QueryExpression<QueryValue> {
    BinaryOperator(lhs: self, operator: "OR", rhs: other)
  }

  public func not() -> some QueryExpression<QueryValue> {
    UnaryOperator(operator: "NOT", base: self)
  }
}

// NB: This overload is required due to an overload resolution bug of 'Record[dynamicMember:]'.
@_documentation(visibility: private)
public prefix func ! (
  expression: any QueryExpression<Bool>
) -> some QueryExpression<Bool> {
  func open(_ expression: some QueryExpression<Bool>) -> AnyQueryExpression<Bool> {
    AnyQueryExpression(expression.not())
  }
  return open(expression)
}

extension AnyQueryExpression<Bool> {
  public mutating func toggle() {
    self = Self(not())
  }
}

extension QueryExpression where QueryValue: Numeric {
  public static func + (
    lhs: Self, rhs: some QueryExpression<QueryValue>
  ) -> some QueryExpression<QueryValue> {
    BinaryOperator(lhs: lhs, operator: "+", rhs: rhs)
  }

  public static func - (
    lhs: Self, rhs: some QueryExpression<QueryValue>
  ) -> some QueryExpression<QueryValue> {
    BinaryOperator(lhs: lhs, operator: "-", rhs: rhs)
  }

  public static func * (
    lhs: Self, rhs: some QueryExpression<QueryValue>
  ) -> some QueryExpression<QueryValue> {
    BinaryOperator(lhs: lhs, operator: "*", rhs: rhs)
  }

  public static func / (
    lhs: Self, rhs: some QueryExpression<QueryValue>
  ) -> some QueryExpression<QueryValue> {
    BinaryOperator(lhs: lhs, operator: "/", rhs: rhs)
  }

  public static prefix func - (expression: Self) -> some QueryExpression<QueryValue> {
    UnaryOperator(operator: "-", base: expression, separator: "")
  }

  public static prefix func + (expression: Self) -> some QueryExpression<QueryValue> {
    UnaryOperator(operator: "+", base: expression, separator: "")
  }
}

// NB: This overload is required due to an overload resolution bug of 'Record[dynamicMember:]'.
@_documentation(visibility: private)
public prefix func - <QueryValue: Numeric>(
  expression: any QueryExpression<QueryValue>
) -> some QueryExpression<QueryValue> {
  func open(_ expression: some QueryExpression<QueryValue>) -> AnyQueryExpression<QueryValue> {
    AnyQueryExpression(UnaryOperator(operator: "-", base: expression, separator: ""))
  }
  return open(expression)
}

// NB: This overload is required due to an overload resolution bug of 'Record[dynamicMember:]'.
@_documentation(visibility: private)
public prefix func + <QueryValue: Numeric>(
  expression: any QueryExpression<QueryValue>
) -> some QueryExpression<QueryValue> {
  func open(_ expression: some QueryExpression<QueryValue>) -> AnyQueryExpression<QueryValue> {
    AnyQueryExpression(UnaryOperator(operator: "+", base: expression, separator: ""))
  }
  return open(expression)
}

extension AnyQueryExpression where QueryValue: Numeric {
  public static func += (lhs: inout Self, rhs: some QueryExpression<QueryValue>) {
    lhs = Self(lhs + rhs)
  }

  public static func -= (lhs: inout Self, rhs: some QueryExpression<QueryValue>) {
    lhs = Self(lhs - rhs)
  }

  public static func *= (lhs: inout Self, rhs: some QueryExpression<QueryValue>) {
    lhs = Self(lhs * rhs)
  }

  public static func /= (lhs: inout Self, rhs: some QueryExpression<QueryValue>) {
    lhs = Self(lhs / rhs)
  }

  public mutating func negate() {
    self = Self(-self)
  }
}

extension QueryExpression where QueryValue: BinaryInteger {
  public static func % (
    lhs: Self, rhs: some QueryExpression<QueryValue>
  ) -> some QueryExpression<QueryValue> {
    BinaryOperator(lhs: lhs, operator: "%", rhs: rhs)
  }

  public static func & (
    lhs: Self, rhs: some QueryExpression<QueryValue>
  ) -> some QueryExpression<QueryValue> {
    BinaryOperator(lhs: lhs, operator: "&", rhs: rhs)
  }

  public static func | (
    lhs: Self, rhs: some QueryExpression<QueryValue>
  ) -> some QueryExpression<QueryValue> {
    BinaryOperator(lhs: lhs, operator: "|", rhs: rhs)
  }

  public static func << (
    lhs: Self, rhs: some QueryExpression<QueryValue>
  ) -> some QueryExpression<QueryValue> {
    BinaryOperator(lhs: lhs, operator: "<<", rhs: rhs)
  }

  public static func >> (
    lhs: Self, rhs: some QueryExpression<QueryValue>
  ) -> some QueryExpression<QueryValue> {
    BinaryOperator(lhs: lhs, operator: ">>", rhs: rhs)
  }

  public static prefix func ~ (expression: Self) -> some QueryExpression<QueryValue> {
    UnaryOperator(operator: "~", base: expression, separator: "")
  }
}

// NB: This overload is required due to an overload resolution bug of 'Record[dynamicMember:]'.
@_documentation(visibility: private)
public prefix func ~ <QueryValue: BinaryInteger>(
  expression: any QueryExpression<QueryValue>
) -> some QueryExpression<QueryValue> {
  func open(_ expression: some QueryExpression<QueryValue>) -> AnyQueryExpression<QueryValue> {
    AnyQueryExpression(UnaryOperator(operator: "~", base: expression, separator: ""))
  }
  return open(expression)
}

extension AnyQueryExpression where QueryValue: BinaryInteger {
  public static func %= (lhs: inout Self, rhs: some QueryExpression<QueryValue>) {
    lhs = Self(lhs % rhs)
  }

  public static func &= (lhs: inout Self, rhs: some QueryExpression<QueryValue>) {
    lhs = Self(lhs & rhs)
  }

  public static func |= (lhs: inout Self, rhs: some QueryExpression<QueryValue>) {
    lhs = Self(lhs | rhs)
  }

  public static func <<= (lhs: inout Self, rhs: some QueryExpression<QueryValue>) {
    lhs = Self(lhs << rhs)
  }

  public static func >>= (lhs: inout Self, rhs: some QueryExpression<QueryValue>) {
    lhs = Self(lhs >> rhs)
  }
}

extension QueryExpression where QueryValue == String {
  public static func + (
    lhs: Self, rhs: some QueryExpression<QueryValue>
  ) -> some QueryExpression<QueryValue> {
    BinaryOperator(lhs: lhs, operator: "||", rhs: rhs)
  }

  public func collate(_ collation: Collation) -> some QueryExpression<QueryValue> {
    BinaryOperator(
      lhs: self,
      operator: "COLLATE",
      rhs: SQLQueryExpression("\(raw: collation.rawValue)", as: Void.self)
    )
  }

  public func glob(_ pattern: QueryValue) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: self, operator: "GLOB", rhs: pattern)
  }

  public func like(_ pattern: QueryValue, escape: Character? = nil) -> some QueryExpression<Bool> {
    LikeOperator(string: self, pattern: pattern, escape: escape)
  }

  public func hasPrefix(_ other: QueryValue) -> some QueryExpression<Bool> {
    like("\(other)%")
  }

  public func hasSuffix(_ other: QueryValue) -> some QueryExpression<Bool> {
    like("%\(other)")
  }

  @_disfavoredOverload
  public func contains(_ other: QueryValue) -> some QueryExpression<Bool> {
    like("%\(other)%")
  }
}

extension AnyQueryExpression<String> {
  public static func += (
    lhs: inout Self, rhs: some QueryExpression<QueryValue>
  ) {
    lhs = Self(lhs + rhs)
  }

  public mutating func append(_ other: some QueryExpression<QueryValue>) {
    self += other
  }

  public mutating func append(contentsOf other: some QueryExpression<QueryValue>) {
    self += other
  }
}

extension QueryExpression {
  public func `in`(_ expression: some QueryExpression<[QueryValue]>) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: self, operator: "IN", rhs: expression)
  }

  public func `in`(_ query: some Statement<QueryValue>) -> some QueryExpression<Bool> {
    BinaryOperator(
      lhs: self,
      operator: "IN",
      rhs: SQLQueryExpression("(\(query.query))", as: Void.self)
    )
  }

  public func between(
    _ lowerBound: some QueryExpression<QueryValue>,
    and upperBound: some QueryExpression<QueryValue>
  ) -> some QueryExpression<Bool> {
    BinaryOperator(
      lhs: self,
      operator: "BETWEEN",
      rhs: BinaryOperator<Void, _, _>(lhs: lowerBound, operator: "AND", rhs: upperBound)
    )
  }

  public func contains<Element>(
    _ element: some QueryExpression<Element>
  ) -> some QueryExpression<Bool>
  where QueryValue == [Element] {
    element.in(self)
  }

  public func contains<Bound>(_ element: some QueryExpression<Bound>) -> some QueryExpression<Bool>
  where QueryValue == ClosedRange<Bound> {
    BinaryOperator(lhs: element, operator: "BETWEEN", rhs: self)
  }
}

extension Statement {
  public func contains(
    _ element: some QueryExpression<QueryValue>
  ) -> some QueryExpression<Bool> {
    element.in(self)
  }
}

private struct UnaryOperator<QueryValue, Base: QueryExpression>: QueryExpression {
  let `operator`: String
  let base: Base
  var separator = " "

  var queryFragment: QueryFragment {
    "\(raw: `operator`)\(raw: separator)(\(base.queryFragment))"
  }
}

struct BinaryOperator<
  QueryValue,
  LHS: QueryExpression,
  RHS: QueryExpression
>: QueryExpression {
  let lhs: LHS
  let `operator`: String
  let rhs: RHS

  var queryFragment: QueryFragment {
    "(\(lhs.queryFragment) \(raw: `operator`) \(rhs.queryFragment))"
  }
}

private struct LikeOperator<
  LHS: QueryExpression<String>,
  RHS: QueryExpression<String>
>: QueryExpression {
  typealias QueryValue = Bool

  let string: LHS
  let pattern: RHS
  let escape: Character?  // TODO: 'QueryExpression<Character>?'

  var queryFragment: QueryFragment {
    var query: QueryFragment = "(\(string.queryFragment) LIKE \(pattern.queryFragment)"
    if let escape {
      query.append(" ESCAPE \(bind: String(escape))")
    }
    query.append(")")
    return query
  }
}
