extension _SelectStatement {
  public func union<F, J>(
    all: Bool = false,
    _ other: some SelectStatement<QueryValue, F, J>
  ) -> CompoundSelect<QueryValue> {
    CompoundSelect(lhs: self, operator: all ? "UNION ALL" : "UNION", rhs: other)
  }

  public func intersect<F, J>(
    _ other: some SelectStatement<QueryValue, F, J>
  ) -> CompoundSelect<QueryValue> {
    CompoundSelect(lhs: self, operator: "INTERSECT", rhs: other)
  }

  public func except<F, J>(
    _ other: some SelectStatement<QueryValue, F, J>
  ) -> CompoundSelect<QueryValue> {
    CompoundSelect(lhs: self, operator: "EXCEPT", rhs: other)
  }
}

public struct CompoundSelect<QueryValue>: _SelectStatement {
  public typealias Joins = Never
  public typealias From = Never

  let lhs: any Statement
  let `operator`: String
  var rhs: any SelectStatement

  public var query: QueryFragment {
    "\(lhs.query) \(raw: `operator`) \(rhs.query)"
  }

  public func union<F, J>(
    all: Bool = false,
    _ other: some SelectStatement<QueryValue, F, J>
  ) -> CompoundSelect<QueryValue> {
    CompoundSelect(lhs: self, operator: all ? "UNION ALL" : "UNION", rhs: other)
  }

  public func intersect<F, J>(
    _ other: some SelectStatement<QueryValue, F, J>
  ) -> CompoundSelect<QueryValue> {
    CompoundSelect(lhs: self, operator: "INTERSECT", rhs: other)
  }

  public func except<F, J>(
    _ other: some SelectStatement<QueryValue, F, J>
  ) -> CompoundSelect<QueryValue> {
    CompoundSelect(lhs: self, operator: "EXCEPT", rhs: other)
  }
}
