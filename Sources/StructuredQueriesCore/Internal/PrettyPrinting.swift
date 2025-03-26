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
}
