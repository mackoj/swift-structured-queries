extension _SelectStatement {
  public func union(
    all: Bool = false,
    _ other: some _SelectStatement<QueryValue>
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

  fileprivate struct Operator {
    static var except: Self { Self(queryFragment: "EXCEPT") }
    static var intersect: Self { Self(queryFragment: "INTERSECT") }
    static var union: Self { Self(queryFragment: "UNION") }
    static var unionAll: Self { Self(queryFragment: "UNION ALL") }
    let queryFragment: QueryFragment
  }

  let lhs: QueryFragment
  let `operator`: QueryFragment
  let rhs: QueryFragment

  fileprivate init(lhs: some _SelectStatement, operator: Operator, rhs: some _SelectStatement) {
    self.lhs = lhs.query
    self.operator = `operator`.queryFragment
    self.rhs = rhs.query
  }

  public var query: QueryFragment {
    "\(lhs) \(`operator`) \(rhs)"
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
