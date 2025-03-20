extension _SelectStatement {
  public func union<F, J>(
    all: Bool = false,
    _ other: some SelectStatement<QueryValue, F, J>
  ) -> CompoundSelect<QueryValue> {
    CompoundSelect(lhs: self, operator: all ? .unionAll : .union, rhs: other)
  }

  public func intersect<F, J>(
    _ other: some SelectStatement<QueryValue, F, J>
  ) -> CompoundSelect<QueryValue> {
    CompoundSelect(lhs: self, operator: .intersect, rhs: other)
  }

  public func except<F, J>(
    _ other: some SelectStatement<QueryValue, F, J>
  ) -> CompoundSelect<QueryValue> {
    CompoundSelect(lhs: self, operator: .except, rhs: other)
  }
}

public struct CompoundSelect<QueryValue>: _SelectStatement {
  public typealias Joins = Never
  public typealias From = Never

  fileprivate enum Operator: String {
    case except = "EXCEPT"
    case intersect = "INTERSECT"
    case union = "UNION"
    case unionAll = "UNION ALL"
  }

  let lhs: QueryFragment
  fileprivate let `operator`: Operator
  var rhs: QueryFragment

  fileprivate init(lhs: some _SelectStatement, operator: Operator, rhs: some _SelectStatement) {
    self.lhs = lhs.query
    self.operator = `operator`
    self.rhs = rhs.query
  }

  public var query: QueryFragment {
    "\(lhs) \(raw: `operator`.rawValue) \(rhs)"
  }

  public func union<F, J>(
    all: Bool = false,
    _ other: some SelectStatement<QueryValue, F, J>
  ) -> CompoundSelect<QueryValue> {
    CompoundSelect(lhs: self, operator: all ? .unionAll : .union, rhs: other)
  }

  public func intersect<F, J>(
    _ other: some SelectStatement<QueryValue, F, J>
  ) -> CompoundSelect<QueryValue> {
    CompoundSelect(lhs: self, operator: .intersect, rhs: other)
  }

  public func except<F, J>(
    _ other: some SelectStatement<QueryValue, F, J>
  ) -> CompoundSelect<QueryValue> {
    CompoundSelect(lhs: self, operator: .except, rhs: other)
  }
}
