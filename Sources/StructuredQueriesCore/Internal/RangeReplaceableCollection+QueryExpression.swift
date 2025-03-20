extension RangeReplaceableCollection {
  package init<each Q: QueryExpression>(_ elements: repeat each Q)
  where Element == QueryFragment {
    self.init()
    for element in repeat each elements {
      append(element.queryFragment)
    }
  }
}
