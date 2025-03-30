extension QueryExpression where QueryValue: QueryBindable {
  /// A predicate expression indicating whether two query expressions are equal.
  ///
  /// ```swift
  /// Reminder.where { $0.title == "Buy milk" }
  /// // SELECT … FROM "reminders" WHERE "reminders"."title" = 'Buy milk'
  /// ```
  ///
  /// > Important: Overloaded operators can strain the Swift compiler's type checking ability.
  /// > Consider using ``eq``, instead.
  ///
  /// - Parameters:
  ///   - lhs: An expression to compare.
  ///   - rhs: Another expression to compare.
  /// - Returns: A predicate expression.
  public static func == (
    lhs: Self, rhs: some QueryExpression<QueryValue>
  ) -> some QueryExpression<Bool> {
    lhs.eq(rhs)
  }

  /// A predicate expression indicating whether two query expressions are not equal.
  ///
  /// ```swift
  /// Reminder.where { $0.title != "Buy milk" }
  /// // SELECT … FROM "reminders" WHERE "reminders"."title" <> 'Buy milk'
  /// ```
  ///
  /// > Important: Overloaded operators can strain the Swift compiler's type checking ability.
  /// > Consider using ``neq``, instead.
  ///
  /// - Parameters:
  ///   - lhs: An expression to compare.
  ///   - rhs: Another expression to compare.
  /// - Returns: A predicate expression.
  public static func != (
    lhs: Self, rhs: some QueryExpression<QueryValue>
  ) -> some QueryExpression<Bool> {
    lhs.neq(rhs)
  }

  @_disfavoredOverload
  @_documentation(visibility: private)
  public static func == (
    lhs: Self, rhs: some QueryExpression<QueryValue?>
  ) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: lhs, operator: isNull(rhs) ? "IS" : "=", rhs: rhs)
  }

  @_disfavoredOverload
  @_documentation(visibility: private)
  public static func != (
    lhs: Self, rhs: some QueryExpression<QueryValue?>
  ) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: lhs, operator: isNull(rhs) ? "IS NOT" : "<>", rhs: rhs)
  }

  /// Returns a predicate expression indicating whether two query expressions are equal.
  ///
  /// ```swift
  /// Reminder.where { $0.title.eq("Buy milk") }
  /// // SELECT … FROM "reminders" WHERE "reminders"."title" = 'Buy milk'
  /// ```
  ///
  /// - Parameters:
  ///   - lhs: An expression to compare.
  ///   - rhs: Another expression to compare.
  /// - Returns: A predicate expression.
  public func eq(_ other: some QueryExpression<QueryValue>) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: self, operator: "=", rhs: other)
  }

  /// Returns a predicate expression indicating whether two query expressions are not equal.
  ///
  /// ```swift
  /// Reminder.where { $0.title.neq("Buy milk") }
  /// // SELECT … FROM "reminders" WHERE "reminders"."title" <> 'Buy milk'
  /// ```
  ///
  /// - Parameters:
  ///   - lhs: An expression to compare.
  ///   - rhs: Another expression to compare.
  /// - Returns: A predicate expression.
  public func neq(_ other: some QueryExpression<QueryValue>) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: self, operator: "<>", rhs: other)
  }

  public func `is`(
    _ other: some QueryExpression<QueryValue._Optionalized>
  ) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: self, operator: "IS", rhs: other)
  }

  // TODO: Should this be 'isnt' (or aliased to it) for similar brevity to 'neq'?
  public func isNot(
    _ other: some QueryExpression<QueryValue._Optionalized>
  ) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: self, operator: "IS NOT", rhs: other)
  }
}

private func isNull<Value>(_ expression: some QueryExpression<Value>) -> Bool {
  (expression as? any _OptionalProtocol).map { $0._wrapped == nil } ?? false
}

extension QueryExpression where QueryValue: QueryBindable & _OptionalProtocol {
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
    BinaryOperator(lhs: self, operator: "<>", rhs: other)
  }

  public func eq(_ other: some QueryExpression<QueryValue>) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: self, operator: "=", rhs: other)
  }

  public func neq(_ other: some QueryExpression<QueryValue>) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: self, operator: "<>", rhs: other)
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

extension QueryExpression where QueryValue: QueryBindable {
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

extension QueryExpression where QueryValue: QueryBindable & Comparable {
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
  func open(_ expression: some QueryExpression<Bool>) -> SQLQueryExpression<Bool> {
    SQLQueryExpression(expression.not())
  }
  return open(expression)
}

extension SQLQueryExpression<Bool> {
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
  func open(_ expression: some QueryExpression<QueryValue>) -> SQLQueryExpression<QueryValue> {
    SQLQueryExpression(UnaryOperator(operator: "-", base: expression, separator: ""))
  }
  return open(expression)
}

// NB: This overload is required due to an overload resolution bug of 'Record[dynamicMember:]'.
@_documentation(visibility: private)
public prefix func + <QueryValue: Numeric>(
  expression: any QueryExpression<QueryValue>
) -> some QueryExpression<QueryValue> {
  func open(_ expression: some QueryExpression<QueryValue>) -> SQLQueryExpression<QueryValue> {
    SQLQueryExpression(UnaryOperator(operator: "+", base: expression, separator: ""))
  }
  return open(expression)
}

extension SQLQueryExpression where QueryValue: Numeric {
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
  func open(_ expression: some QueryExpression<QueryValue>) -> SQLQueryExpression<QueryValue> {
    SQLQueryExpression(UnaryOperator(operator: "~", base: expression, separator: ""))
  }
  return open(expression)
}

extension SQLQueryExpression where QueryValue: BinaryInteger {
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
      rhs: SQLQueryExpression("\(collation.rawValue)", as: Void.self)
    )
  }

  /// A predicate expression from this string expression matched against another _via_ the `GLOB`
  /// operator.
  ///
  /// ```swift
  /// Asset.where { $0.path.glob("Resources/*.png") }
  /// // SELECT … FROM "assets" WHERE ("assets"."path" GLOB 'Resources/*.png')
  /// ```
  ///
  /// - Parameter pattern: A string expression describing the `GLOB` pattern.
  /// - Returns: A predicate expression.
  public func glob(_ pattern: QueryValue) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: self, operator: "GLOB", rhs: pattern)
  }

  /// A predicate expression from this string expression matched against another _via_ the `LIKE`
  /// operator.
  ///
  /// ```swift
  /// Reminder.where { $0.title.like("%get%") }
  /// // SELECT … FROM "reminders" WHERE ("reminders"."title" LIKE '%get%')
  /// ```
  ///
  /// - Parameter pattern: A string expression describing the `LIKE` pattern.
  /// - Returns: A predicate expression.
  public func like(_ pattern: QueryValue, escape: Character? = nil) -> some QueryExpression<Bool> {
    LikeOperator(string: self, pattern: pattern, escape: escape)
  }

  /// A predicate expression from this string expression matched against another _via_ the `MATCH`
  /// operator.
  ///
  /// ```swift
  /// Reminder.where { $0.title.match("get") }
  /// // SELECT … FROM "reminders" WHERE ("reminders"."title" MATCH 'get')
  /// ```
  ///
  /// - Parameter pattern: A string expression describing the `MATCH` pattern.
  /// - Returns: A predicate expression.
  public func match(_ pattern: QueryValue) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: self, operator: "MATCH", rhs: pattern)
  }

  /// A predicate expression from this string expression matched against another _via_ the `LIKE`
  /// operator given a prefix.
  ///
  /// ```swift
  /// Reminder.where { $0.title.hasPrefix("get") }
  /// // SELECT … FROM "reminders" WHERE ("reminders"."title" LIKE 'get%')
  /// ```
  ///
  /// - Parameter pattern: A string expression describing the prefix.
  /// - Returns: A predicate expression.
  public func hasPrefix(_ other: QueryValue) -> some QueryExpression<Bool> {
    like("\(other)%")
  }

  /// A predicate expression from this string expression matched against another _via_ the `LIKE`
  /// operator given a suffix.
  ///
  /// ```swift
  /// Reminder.where { $0.title.hasSuffix("get") }
  /// // SELECT … FROM "reminders" WHERE ("reminders"."title" LIKE '%get')
  /// ```
  ///
  /// - Parameter pattern: A string expression describing the suffix.
  /// - Returns: A predicate expression.
  public func hasSuffix(_ other: QueryValue) -> some QueryExpression<Bool> {
    like("%\(other)")
  }

  /// A predicate expression from this string expression matched against another _via_ the `LIKE`
  /// operator given an infix.
  ///
  /// ```swift
  /// Reminder.where { $0.title.contains("get") }
  /// // SELECT … FROM "reminders" WHERE ("reminders"."title" LIKE '%get%')
  /// ```
  ///
  /// - Parameter pattern: A string expression describing the infix.
  /// - Returns: A predicate expression.
  @_disfavoredOverload
  public func contains(_ other: QueryValue) -> some QueryExpression<Bool> {
    like("%\(other)%")
  }
}

extension SQLQueryExpression<String> {
  /// Appends a string expression in an update clause.
  ///
  /// Can be used in an `UPDATE` clause to append an existing column:
  ///
  /// ```swift
  /// Reminder.update { $0.title += " 2" }
  /// // UPDATE "reminders" SET "title" = ("reminders"."title" || " 2")
  /// ```
  ///
  /// - Parameters:
  ///   - lhs: The column to append.
  ///   - rhs: The appended text.
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

extension QueryExpression where QueryValue: QueryBindable {
  public func `in`(_ expression: [some QueryExpression<QueryValue>]) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: self, operator: "IN", rhs: Array.Expression(elements: expression))
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
      rhs: BinaryOperator<Void>(lhs: lowerBound, operator: "AND", rhs: upperBound)
    )
  }
}

extension Array where Element: QueryBindable {
  public func contains(
    _ element: some QueryExpression<Element.QueryValue>
  ) -> some QueryExpression<Bool> {
    element.in(self)
  }
}

extension ClosedRange where Bound: QueryBindable {
  public func contains(
    _ element: some QueryExpression<Bound.QueryValue>
  ) -> some QueryExpression<Bool> {
    element.between(lowerBound, and: upperBound)
  }
}

extension Statement where QueryValue: QueryBindable {
  public func contains(
    _ element: some QueryExpression<QueryValue>
  ) -> some QueryExpression<Bool> {
    element.in(self)
  }
}

private struct UnaryOperator<QueryValue>: QueryExpression {
  let `operator`: QueryFragment
  let base: QueryFragment
  let separator: QueryFragment

  init(operator: QueryFragment, base: some QueryExpression, separator: QueryFragment = " ") {
    self.operator = `operator`
    self.base = base.queryFragment
    self.separator = separator
  }

  var queryFragment: QueryFragment {
    "\(`operator`)\(separator)(\(base))"
  }
}

struct BinaryOperator<QueryValue>: QueryExpression {
  let lhs: QueryFragment
  let `operator`: QueryFragment
  let rhs: QueryFragment

  init(
    lhs: some QueryExpression,
    operator: QueryFragment,
    rhs: some QueryExpression
  ) {
    self.lhs = lhs.queryFragment
    self.operator = `operator`
    self.rhs = rhs.queryFragment
  }

  var queryFragment: QueryFragment {
    "(\(lhs) \(`operator`) \(rhs))"
  }
}

private struct LikeOperator<
  LHS: QueryExpression<String>,
  RHS: QueryExpression<String>
>: QueryExpression {
  typealias QueryValue = Bool

  let string: LHS
  let pattern: RHS
  let escape: Character?

  var queryFragment: QueryFragment {
    var query: QueryFragment = "(\(string.queryFragment) LIKE \(pattern.queryFragment)"
    if let escape {
      query.append(" ESCAPE \(bind: String(escape))")
    }
    query.append(")")
    return query
  }
}

extension Array where Element: QueryExpression, Element.QueryValue: QueryBindable {
  fileprivate struct Expression: QueryExpression {
    typealias QueryValue = Array

    let elements: [Element]
    init(elements: [Element]) {
      self.elements = elements
    }
    var queryFragment: QueryFragment {
      "(\(elements.map(\.queryFragment).joined(separator: ", ")))"
    }
  }
}
