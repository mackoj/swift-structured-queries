public enum ConflictResolution: Sendable {
  case abort
  case fail
  case ignore
  case replace
  case rollback
}

extension ConflictResolution: QueryExpression {
  public typealias Value = Void
  public var queryString: String {
    switch self {
    case .abort: return "ABORT"
    case .fail: return "FAIL"
    case .ignore: return "IGNORE"
    case .replace: return "REPLACE"
    case .rollback: return "ROLLBACK"
    }
  }
  public var queryBindings: [QueryBinding] { [] }
}
