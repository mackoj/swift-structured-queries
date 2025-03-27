import Foundation

extension QueryExpression where QueryValue == Bool {
  public func likelihood(
    _ probability: some QueryExpression<some FloatingPoint>
  ) -> some QueryExpression<QueryValue> {
    QueryFunction("likelihood", self, probability)
  }

  public func likely() -> some QueryExpression<QueryValue> {
    QueryFunction("likely", self)
  }

  public func unlikely() -> some QueryExpression<QueryValue> {
    QueryFunction("unlikely", self)
  }
}

extension QueryExpression where QueryValue: BinaryInteger {
  public func randomblob() -> some QueryExpression<[UInt8]> {
    QueryFunction("randomblob", self)
  }

  public func zeroblob() -> some QueryExpression<[UInt8]> {
    QueryFunction("zeroblob", self)
  }
}

extension QueryExpression where QueryValue: Collection {
  public func length() -> some QueryExpression<Int> {
    QueryFunction("length", self)
  }

  @available(
    *,
    deprecated,
    message: "Use 'count()' for SQL's 'count' aggregate function, or 'length()'"
  )
  public var count: some QueryExpression<Int> {
    length()
  }
}

extension QueryExpression where QueryValue: FloatingPoint {
  public func round(_ k: some QueryExpression<Int>) -> some QueryExpression<QueryValue> {
    QueryFunction("round", self, k)
  }

  public func round() -> some QueryExpression<QueryValue> {
    QueryFunction("round", self)
  }
}

extension QueryExpression where QueryValue: Numeric {
  public func abs() -> some QueryExpression<QueryValue> {
    QueryFunction("abs", self)
  }

  public func sign() -> some QueryExpression<QueryValue> {
    QueryFunction("sign", self)
  }
}

extension QueryExpression where QueryValue: _OptionalProtocol {
  public func ifnull(
    _ other: some QueryExpression<QueryValue.Wrapped>
  ) -> some QueryExpression<QueryValue.Wrapped> {
    QueryFunction("ifnull", self, other)
  }

  public func ifnull(
    _ other: some QueryExpression<QueryValue>
  ) -> some QueryExpression<QueryValue> {
    QueryFunction("ifnull", self, other)
  }

  public static func ?? (
    lhs: Self,
    rhs: some QueryExpression<QueryValue.Wrapped>
  ) -> CoalesceFunction<QueryValue.Wrapped> {
    CoalesceFunction([lhs.queryFragment, rhs.queryFragment])
  }

  public static func ?? (
    lhs: Self,
    rhs: some QueryExpression<QueryValue>
  ) -> CoalesceFunction<QueryValue> {
    CoalesceFunction([lhs.queryFragment, rhs.queryFragment])
  }

  @available(
    *,
    deprecated,
    message:
      "Left side of 'NULL' coalescing operator '??' has non-optional query type, so the right side is never used"
  )
  public static func ?? (
    lhs: some QueryExpression<QueryValue.Wrapped>,
    rhs: Self
  ) -> CoalesceFunction<QueryValue> {
    CoalesceFunction([lhs.queryFragment, rhs.queryFragment])
  }
}

extension QueryExpression {
  @available(
    *,
    deprecated,
    message:
      "Left side of 'NULL' coalescing operator '??' has non-optional query type, so the right side is never used"
  )
  public static func ?? (
    lhs: some QueryExpression<QueryValue>,
    rhs: Self
  ) -> CoalesceFunction<QueryValue> {
    CoalesceFunction([lhs.queryFragment, rhs.queryFragment])
  }
}

// TODO: Worth aliasing Swift methods like 'contains', 'lowercased', 'trimming', 'replacing'...?
extension QueryExpression where QueryValue == String {
  public func instr(_ occurrence: some QueryExpression<QueryValue>) -> some QueryExpression<Int> {
    QueryFunction("instr", self, occurrence)
  }

  public func lower() -> some QueryExpression<QueryValue> {
    QueryFunction("lower", self)
  }

  public func ltrim() -> some QueryExpression<QueryValue> {
    QueryFunction("ltrim", self)
  }

  public func ltrim(
    _ characters: some QueryExpression<QueryValue>
  ) -> some QueryExpression<QueryValue> {
    QueryFunction("ltrim", self, characters)
  }

  public func octetLength() -> some QueryExpression<Int> {
    QueryFunction("octet_length", self)
  }

  public func quote() -> some QueryExpression<QueryValue> {
    QueryFunction("quote", self)
  }

  public func replace(
    _ other: some QueryExpression<QueryValue>,
    _ replacement: some QueryExpression<QueryValue>
  ) -> some QueryExpression<QueryValue> {
    QueryFunction("replace", self, other, replacement)
  }

  public func rtrim() -> some QueryExpression<QueryValue> {
    QueryFunction("rtrim", self)
  }

  public func rtrim(
    _ characters: some QueryExpression<QueryValue>
  ) -> some QueryExpression<QueryValue> {
    QueryFunction("rtrim", self, characters)
  }

  public func substr(
    _ offset: some QueryExpression<Int>,
    _ length: some QueryExpression<Int>
  ) -> some QueryExpression<QueryValue> {
    QueryFunction("substr", self, offset, length)
  }

  public func substr(
    _ offset: some QueryExpression<Int>
  ) -> some QueryExpression<QueryValue> {
    QueryFunction("substr", self, offset)
  }

  public func trim() -> some QueryExpression<QueryValue> {
    QueryFunction("trim", self)
  }

  public func trim(
    _ characters: some QueryExpression<QueryValue>
  ) -> some QueryExpression<QueryValue> {
    QueryFunction("trim", self, characters)
  }

  public func unhex() -> some QueryExpression<[UInt8]?> {
    QueryFunction("unhex", self)
  }

  public func unhex(
    _ characters: some QueryExpression<QueryValue>
  ) -> some QueryExpression<[UInt8]?> {
    QueryFunction("unhex", self, characters)
  }

  public func unicode() -> some QueryExpression<Int?> {
    QueryFunction("unicode", self)
  }

  public func upper() -> some QueryExpression<QueryValue> {
    QueryFunction("upper", self)
  }
}

extension QueryExpression where QueryValue == [UInt8] {
  public func hex() -> some QueryExpression<String> {
    QueryFunction("hex", self)
  }
}

struct QueryFunction<QueryValue>: QueryExpression {
  let name: QueryFragment
  let arguments: [QueryFragment]

  init<each Argument: QueryExpression>(_ name: QueryFragment, _ arguments: repeat each Argument) {
    self.name = name
    self.arguments = Array(repeat each arguments)
  }

  var queryFragment: QueryFragment {
    "\(name)(\(arguments.joined(separator: ", ")))"
  }
}

public struct CoalesceFunction<QueryValue>: QueryExpression {
  private let arguments: [QueryFragment]

  fileprivate init(_ arguments: [QueryFragment]) {
    self.arguments = arguments
  }

  public var queryFragment: QueryFragment {
    "coalesce(\(arguments.joined(separator: ", ")))"
  }

  public static func ?? <T: _OptionalProtocol<QueryValue>>(
    lhs: some QueryExpression<T>,
    rhs: Self
  ) -> CoalesceFunction<QueryValue> {
    Self([lhs.queryFragment] + rhs.arguments)
  }
}

extension CoalesceFunction where QueryValue: _OptionalProtocol {
  public static func ?? (
    lhs: some QueryExpression<QueryValue>,
    rhs: Self
  ) -> Self {
    Self([lhs.queryFragment] + rhs.arguments)
  }
}
