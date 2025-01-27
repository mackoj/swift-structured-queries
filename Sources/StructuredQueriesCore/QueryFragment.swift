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
    var sql = lhs
    sql += rhs
    return sql
  }

  public var debugDescription: String {
    var compiled = ""
    var bindings = bindings
    compiled.reserveCapacity(string.count)
    for character in string {
      // TODO: This is brittle
      switch character {
      case "?":
        compiled.append(bindings.removeFirst().debugDescription)
      default:
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
  }
}
