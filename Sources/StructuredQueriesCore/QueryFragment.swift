/// A type representing a SQL statement and its bindings.
///
/// You will typically create instances of this type using string literals, where bindings are
/// directly interpolated into the string.
public struct QueryFragment: Hashable, Sendable, CustomDebugStringConvertible {
  public var string: String
  public var bindings: [QueryBinding]

  init(_ string: String = "", _ bindings: [QueryBinding] = []) {
    self.string = string
    self.bindings = bindings
  }

  public mutating func append(_ other: Self) {
    string.append(other.string)
    bindings.append(contentsOf: other.bindings)
  }

  public var isEmpty: Bool {
    string.isEmpty && bindings.isEmpty
  }

  public static func += (lhs: inout Self, rhs: Self) {
    lhs.append(rhs)
  }

  public static func + (lhs: Self, rhs: Self) -> Self {
    var query = lhs
    query += rhs
    return query
  }

  public var debugDescription: String {
    var compiled = ""
    var bindings = bindings
    var currentDelimiter: Character?
    compiled.reserveCapacity(string.count)
    let delimiters: [Character: Character] = [
      #"""#: #"""#,
      "'": "'",
      "`": "`",
      "[": "]",
    ]
    for character in string {
      if let delimiter = currentDelimiter {
        if delimiter == character,
          compiled.last != character || compiled.last == delimiters[delimiter]
        {
          currentDelimiter = nil
        }
        compiled.append(character)
      } else if delimiters.keys.contains(character) {
        currentDelimiter = character
        compiled.append(character)
      } else if character == "?" {
        compiled.append(bindings.removeFirst().debugDescription)
      } else {
        compiled.append(character)
      }
    }
    return compiled
  }
}

extension [QueryFragment] {
  public func joined(separator: QueryFragment = "") -> QueryFragment {
    guard var joined = first else { return QueryFragment() }
    for fragment in dropFirst() {
      joined.append(separator)
      joined.append(fragment)
    }
    return joined
  }
}

extension QueryFragment: ExpressibleByStringInterpolation {
  public init(stringInterpolation: StringInterpolation) {
    self.init(stringInterpolation.string, stringInterpolation.bindings)
  }

  public init(stringLiteral value: String) {
    self.init(value)
  }

  public struct StringInterpolation: StringInterpolationProtocol {
    public var string = ""
    public var bindings: [QueryBinding] = []

    public init(literalCapacity: Int, interpolationCount: Int) {
      string.reserveCapacity(literalCapacity)
      bindings.reserveCapacity(interpolationCount)
    }

    public mutating func appendLiteral(_ literal: String) {
      string.append(literal)
    }

    public mutating func appendInterpolation(raw sql: String) {
      string.append(sql)
    }

    public mutating func appendInterpolation(raw sql: some LosslessStringConvertible) {
      string.append(sql.description)
    }

    public mutating func appendInterpolation(_ binding: QueryBinding) {
      string.append("?")
      bindings.append(binding)
    }

    public mutating func appendInterpolation(_ fragment: QueryFragment) {
      string.append(fragment.string)
      bindings.append(contentsOf: fragment.bindings)
    }

    public mutating func appendInterpolation(bind expression: some QueryExpression) {
      appendInterpolation(expression.queryFragment)
    }

    public mutating func appendInterpolation(_ expression: some QueryExpression) {
      appendInterpolation(expression.queryFragment)
    }

    @available(
      *,
      deprecated,
      renamed: "appendInterpolation(bind:)",
      message: """
        String interpolation produces a bind for a string value; did you mean to make this explicit? To append raw SQL, use "\\(raw: sqlString)".
        """
    )
    public mutating func appendInterpolation(_ expression: String) {
      appendInterpolation(bind: expression)
    }
  }
}
