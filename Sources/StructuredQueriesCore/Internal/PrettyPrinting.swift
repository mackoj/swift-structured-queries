import Foundation
import IssueReporting

extension QueryFragment {
  @inlinable
  @inline(__always)
  static var newlineOrSpace: Self {
    #if DEBUG
      return isTesting ? "\n" : " "
    #else
      return " "
    #endif
  }

  @inlinable
  @inline(__always)
  static var newline: Self {
    #if DEBUG
      return isTesting ? "\n" : ""
    #else
      return ""
    #endif
  }

  // TODO: bring back
  //  @inlinable
  //  @inline(__always)
  func indented() -> Self {
    #if DEBUG
      guard isTesting else { return self }
      var query = self
      query.string = "  \(query.string.replacingOccurrences(of: "\n", with: "\n  "))"
      return query
    #else
      return self
    #endif
  }
}
