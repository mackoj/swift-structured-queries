public enum ConflictResolution: Sendable {
  case abort
  case fail
  case ignore
  case replace
  case rollback
}

extension ConflictResolution: QueryExpression {
  public typealias QueryOutput = Void
  public var queryFragment: QueryFragment {
    switch self {
    case .abort: return "ABORT"
    case .fail: return "FAIL"
    case .ignore: return "IGNORE"
    case .replace: return "REPLACE"
    case .rollback: return "ROLLBACK"
    }
  }
}
