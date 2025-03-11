extension RangeReplaceableCollection {
  init<each Q: QueryExpression>(_ elements: repeat each Q) where Element == any QueryExpression {
    self.init()
    for element in repeat each elements {
      append(element)
    }
  }
}
