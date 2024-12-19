extension Table {
  public static func all() -> Select<Columns, Self> {
    Select(input: Self.columns, from: Self.self)
  }
}

public struct Select<Input: Sendable, Output> {
  fileprivate var input: Input
  fileprivate var isDistinct = false
  fileprivate var select: [any QueryExpression] = []
  fileprivate var from: any Table.Type
  fileprivate var joins: [JoinClause] = []
  fileprivate var `where`: WhereClause?
  fileprivate var group: GroupClause?
  fileprivate var having: HavingClause?
  fileprivate var order: OrderClause?
  fileprivate var limit: LimitClause?

  // TODO: Should 'distinct()' be a separate method?
  //       'SyncUp.all().distinct()' vs. 'SyncUp.all().select(distinct: true, \.self)'

  public func select<each O: QueryExpression>(
    distinct isDistinct: Bool = false,
    _ selection: (Input) -> (repeat each O)
  ) -> Select<Input, (repeat (each O).Value)>
  where repeat (each O).Value: QueryDecodable {
    var select: [any QueryExpression] = []
    for o in repeat each selection(input) {
      select.append(o)
    }
    return Select<Input, (repeat (each O).Value)>(
      input: input,
      isDistinct: isDistinct,
      select: select,
      from: from,
      joins: joins,
      where: `where`,
      group: group,
      having: having,
      order: order,
      limit: limit
    )
  }

  // https://github.com/swiftlang/swift/issues/78191
  // public func join<each I1, each I2, each O1, each O2>(
  //   _ other: Select<(repeat each I2), (repeat each O2)>,
  //   on constraint: ((repeat each I1, repeat each I2)) -> some QueryExpression<Bool>
  // ) -> Select<(repeat each I1, repeat each I2), (repeat each O1, repeat each O2)>
  // where Input == (repeat each I1), Output == (repeat each O1) {
  //   _join(self, other, on: constraint)
  // }
  //
  // public func join<each I1, each I2, each O1, each O2>(
  //   left other: Select<(repeat each I2), (repeat each O2)>,
  //   on constraint: ((repeat each I1, repeat each I2)) -> some QueryExpression<Bool>
  // ) -> Select<(repeat each I1, repeat each I2), (repeat each O1, repeat (each O2)?)>
  // where Input == (repeat each I1), Output == (repeat each O1) {
  //   _leftJoin(self, other, on: constraint)
  // }
  //
  // public func join<each I1, each I2, each O1, each O2>(
  //   right other: Select<(repeat each I2), (repeat each O2)>,
  //   on constraint: ((repeat each I1, repeat each I2)) -> some QueryExpression<Bool>
  // ) -> Select<(repeat each I1, repeat each I2), (repeat (each O1)?, repeat each O2)>
  // where Input == (repeat each I1), Output == (repeat each O1) {
  //   _rightJoin(self, other, on: constraint)
  // }
  //
  // public func join<each I1, each I2, each O1, each O2>(
  //   full other: Select<(repeat each I2), (repeat each O2)>,
  //   on constraint: ((repeat each I1, repeat each I2)) -> some QueryExpression<Bool>
  // ) -> Select<(repeat each I1, repeat each I2), (repeat (each O1)?, repeat (each O2)?)>
  // where Input == (repeat each I1), Output == (repeat each O1) {
  //   _fullJoin(self, other, on: constraint)
  // }

  public func join<OtherInput, OtherOutput>(
    _ other: Select<OtherInput, OtherOutput>,
    on constraint: ((Input, OtherInput)) -> some QueryExpression<Bool>
  ) -> Select<(Input, OtherInput), (Output, OtherOutput)> {
    _join(self, other, on: constraint)
  }

  public func join<OtherInput, OtherOutput>(
    left other: Select<OtherInput, OtherOutput>,
    on constraint: ((Input, OtherInput)) -> some QueryExpression<Bool>
  ) -> Select<(Input, OtherInput), (Output, OtherOutput?)> {
    _leftJoin(self, other, on: constraint)
  }

  public func join<OtherInput, OtherOutput>(
    right other: Select<OtherInput, OtherOutput>,
    on constraint: ((Input, OtherInput)) -> some QueryExpression<Bool>
  ) -> Select<(Input, OtherInput), (Output?, OtherOutput)> {
    _rightJoin(self, other, on: constraint)
  }

  public func join<OtherInput, OtherOutput>(
    full other: Select<OtherInput, OtherOutput>,
    on constraint: ((Input, OtherInput)) -> some QueryExpression<Bool>
  ) -> Select<(Input, OtherInput), (Output?, OtherOutput?)> {
    _fullJoin(self, other, on: constraint)
  }

  public func `where`(_ predicate: (Input) -> some QueryExpression<Bool>) -> Self {
    func open(_ `where`: some QueryExpression<Bool>) -> WhereClause {
      WhereClause(predicate: `where` && predicate(input))
    }
    var copy = self
    copy.`where` = if let `where` {
      open(`where`.predicate)
    } else {
      WhereClause(predicate: predicate(input))
    }
    return copy
  }

  public func group<each O: QueryExpression>(by grouping: (Input) -> (repeat each O)) -> Self {
    var copy = self
    copy.group = GroupClause(repeat each grouping(input))
    return copy
  }

  public func having(_ predicate: (Input) -> some QueryExpression<Bool>) -> Self {
    func open(_ having: some QueryExpression<Bool>) -> HavingClause {
      HavingClause(predicate: having && predicate(input))
    }
    var copy = self
    copy.having = if let having {
      open(having.predicate)
    } else {
      HavingClause(predicate: predicate(input))
    }
    return copy
  }

  public func order<each O: QueryExpression>(_ ordering: (Input) -> (repeat each O)) -> Self
  where repeat (each O).Value: Comparable {
    var copy = self
    copy.order = OrderClause(repeat each ordering(input))
    return copy
  }

  public func limit(
    _ maxLength: (Input) -> some QueryExpression<Int>,
    offset: ((Input) -> some QueryExpression<Int>)? = nil
  ) -> Self {
    var copy = self
    copy.limit = LimitClause(maxLength: maxLength(input), offset: offset?(input))
    return copy
  }

  public func limit(_ maxLength: Int, offset: Int? = nil) -> Self {
    limit(
      { _ in maxLength },
      offset: offset.map { offset in { _ in offset } }
    )
  }
}

extension Select: Statement {
  public typealias Value = [Output]
  public var sql: String {
    var sql = "SELECT"
    if isDistinct {
      sql.append(" DISTINCT")
    }
    let columns = select.isEmpty
      ? ([from] + joins.map(\.right)).map { $0.columns.sql }
      : select.map(\.sql)
    sql.append(" \(columns.joined(separator: ", "))")
    sql.append(" FROM \(from.name.quoted())")
    for join in joins {
      sql.append(" \(join.sql)")
    }
    if let `where` {
      sql.append(" \(`where`.sql)")
    }
    if let group {
      sql.append(" \(group.sql)")
    }
    if let having {
      sql.append(" \(having.sql)")
    }
    if let order {
      sql.append(" \(order.sql)")
    }
    if let limit {
      sql.append(" \(limit.sql)")
    }
    return sql
  }
  public var bindings: [QueryBinding] {
    var bindings: [QueryBinding] = []
    for column in select {
      bindings.append(contentsOf: column.bindings)
    }
    for join in joins {
      bindings.append(contentsOf: join.bindings)
    }
    if let `where` {
      bindings.append(contentsOf: `where`.bindings)
    }
    if let group {
      bindings.append(contentsOf: group.bindings)
    }
    if let having {
      bindings.append(contentsOf: having.bindings)
    }
    if let order {
      bindings.append(contentsOf: order.bindings)
    }
    if let limit {
      bindings.append(contentsOf: limit.bindings)
    }
    return bindings
  }
}

private func _join<each I1, each I2, each O1, each O2>(
  _ lhs: Select<(repeat each I1), (repeat each O1)>,
  _ rhs: Select<(repeat each I2), (repeat each O2)>,
  on predicate: ((repeat each I1, repeat each I2)) -> some QueryExpression<Bool>
) -> Select<(repeat each I1, repeat each I2), (repeat each O1, repeat each O2)> {
  let join = JoinClause(
    operator: nil,
    right: rhs.from,
    condition: predicate((repeat each lhs.input, repeat each rhs.input))
  )
  func open(
    _ lhs: some QueryExpression<Bool>, _ rhs: some QueryExpression<Bool>
  ) -> some QueryExpression<Bool> {
    lhs && rhs
  }
  let `where` = if let lhsWhere = lhs.where, let rhsWhere = rhs.where {
    WhereClause(predicate: open(lhsWhere.predicate, rhsWhere.predicate))
  } else {
    lhs.where ?? rhs.where
  }
  let group = if let lhsGroup = lhs.group, let rhsGroup = rhs.group {
    GroupClause(terms: lhsGroup.terms + rhsGroup.terms)
  } else {
    lhs.group ?? rhs.group
  }
  let having = if let lhsHaving = lhs.having, let rhsHaving = rhs.having {
    HavingClause(predicate: open(lhsHaving.predicate, rhsHaving.predicate))
  } else {
    lhs.having ?? rhs.having
  }
  let order = if let lhsOrder = lhs.order, let rhsOrder = rhs.order {
    OrderClause(terms: lhsOrder.terms + rhsOrder.terms)
  } else {
    lhs.order ?? rhs.order
  }
  return Select(
    input: (repeat each lhs.input, repeat each rhs.input),
    select: lhs.select + rhs.select,
    from: lhs.from,
    joins: lhs.joins + rhs.joins + [join],
    where: `where`,
    group: group,
    having: having,
    order: order,
    limit: lhs.limit ?? rhs.limit
  )
}

private func _leftJoin<each I1, each I2, each O1, each O2>(
  _ lhs: Select<(repeat each I1), (repeat each O1)>,
  _ rhs: Select<(repeat each I2), (repeat each O2)>,
  on predicate: ((repeat each I1, repeat each I2)) -> some QueryExpression<Bool>
) -> Select<(repeat each I1, repeat each I2), (repeat each O1, repeat (each O2)?)> {
  let join = JoinClause(
    operator: .left,
    right: rhs.from,
    condition: predicate((repeat each lhs.input, repeat each rhs.input))
  )
  func open(
    _ lhs: some QueryExpression<Bool>, _ rhs: some QueryExpression<Bool>
  ) -> some QueryExpression<Bool> {
    lhs && rhs
  }
  let `where` = if let lhsWhere = lhs.where, let rhsWhere = rhs.where {
    WhereClause(predicate: open(lhsWhere.predicate, rhsWhere.predicate))
  } else {
    lhs.where ?? rhs.where
  }
  let group = if let lhsGroup = lhs.group, let rhsGroup = rhs.group {
    GroupClause(terms: lhsGroup.terms + rhsGroup.terms)
  } else {
    lhs.group ?? rhs.group
  }
  let having = if let lhsHaving = lhs.having, let rhsHaving = rhs.having {
    HavingClause(predicate: open(lhsHaving.predicate, rhsHaving.predicate))
  } else {
    lhs.having ?? rhs.having
  }
  let order = if let lhsOrder = lhs.order, let rhsOrder = rhs.order {
    OrderClause(terms: lhsOrder.terms + rhsOrder.terms)
  } else {
    lhs.order ?? rhs.order
  }
  return Select(
    input: (repeat each lhs.input, repeat each rhs.input),
    select: lhs.select + rhs.select,
    from: lhs.from,
    joins: lhs.joins + rhs.joins + [join],
    where: `where`,
    group: group,
    having: having,
    order: order,
    limit: lhs.limit ?? rhs.limit
  )
}

private func _rightJoin<each I1, each I2, each O1, each O2>(
  _ lhs: Select<(repeat each I1), (repeat each O1)>,
  _ rhs: Select<(repeat each I2), (repeat each O2)>,
  on predicate: ((repeat each I1, repeat each I2)) -> some QueryExpression<Bool>
) -> Select<(repeat each I1, repeat each I2), (repeat (each O1)?, repeat each O2)> {
  let join = JoinClause(
    operator: .right,
    right: rhs.from,
    condition: predicate((repeat each lhs.input, repeat each rhs.input))
  )
  func open(
    _ lhs: some QueryExpression<Bool>, _ rhs: some QueryExpression<Bool>
  ) -> some QueryExpression<Bool> {
    lhs && rhs
  }
  let `where` = if let lhsWhere = lhs.where, let rhsWhere = rhs.where {
    WhereClause(predicate: open(lhsWhere.predicate, rhsWhere.predicate))
  } else {
    lhs.where ?? rhs.where
  }
  let group = if let lhsGroup = lhs.group, let rhsGroup = rhs.group {
    GroupClause(terms: lhsGroup.terms + rhsGroup.terms)
  } else {
    lhs.group ?? rhs.group
  }
  let having = if let lhsHaving = lhs.having, let rhsHaving = rhs.having {
    HavingClause(predicate: open(lhsHaving.predicate, rhsHaving.predicate))
  } else {
    lhs.having ?? rhs.having
  }
  let order = if let lhsOrder = lhs.order, let rhsOrder = rhs.order {
    OrderClause(terms: lhsOrder.terms + rhsOrder.terms)
  } else {
    lhs.order ?? rhs.order
  }
  return Select(
    input: (repeat each lhs.input, repeat each rhs.input),
    select: lhs.select + rhs.select,
    from: lhs.from,
    joins: lhs.joins + rhs.joins + [join],
    where: `where`,
    group: group,
    having: having,
    order: order,
    limit: lhs.limit ?? rhs.limit
  )
}

private func _fullJoin<each I1, each I2, each O1, each O2>(
  _ lhs: Select<(repeat each I1), (repeat each O1)>,
  _ rhs: Select<(repeat each I2), (repeat each O2)>,
  on predicate: ((repeat each I1, repeat each I2)) -> some QueryExpression<Bool>
) -> Select<(repeat each I1, repeat each I2), (repeat (each O1)?, repeat (each O2)?)> {
  let join = JoinClause(
    operator: .full,
    right: rhs.from,
    condition: predicate((repeat each lhs.input, repeat each rhs.input))
  )
  func open(
    _ lhs: some QueryExpression<Bool>, _ rhs: some QueryExpression<Bool>
  ) -> some QueryExpression<Bool> {
    lhs && rhs
  }
  let `where` = if let lhsWhere = lhs.where, let rhsWhere = rhs.where {
    WhereClause(predicate: open(lhsWhere.predicate, rhsWhere.predicate))
  } else {
    lhs.where ?? rhs.where
  }
  let group = if let lhsGroup = lhs.group, let rhsGroup = rhs.group {
    GroupClause(terms: lhsGroup.terms + rhsGroup.terms)
  } else {
    lhs.group ?? rhs.group
  }
  let having = if let lhsHaving = lhs.having, let rhsHaving = rhs.having {
    HavingClause(predicate: open(lhsHaving.predicate, rhsHaving.predicate))
  } else {
    lhs.having ?? rhs.having
  }
  let order = if let lhsOrder = lhs.order, let rhsOrder = rhs.order {
    OrderClause(terms: lhsOrder.terms + rhsOrder.terms)
  } else {
    lhs.order ?? rhs.order
  }
  return Select(
    input: (repeat each lhs.input, repeat each rhs.input),
    select: lhs.select + rhs.select,
    from: lhs.from,
    joins: lhs.joins + rhs.joins + [join],
    where: `where`,
    group: group,
    having: having,
    order: order,
    limit: lhs.limit ?? rhs.limit
  )
}

private struct JoinClause {
  enum Operator: String { case full = "FULL", inner = "INNER", left = "LEFT", right = "RIGHT" }
  let `operator`: Operator?
  let right: any Table.Type
  let condition: any QueryExpression<Bool>
}
extension JoinClause: QueryExpression {
  typealias Value = Void
  var sql: String {
    "\(`operator`.map { "\($0.rawValue) " } ?? "")JOIN \(right.name.quoted()) ON \(condition.sql)"
  }
  var bindings: [QueryBinding] { condition.bindings }
}

private struct GroupClause {
  var terms: [any QueryExpression]
  init(terms: [any QueryExpression]) {
    self.terms = terms
  }
  init?<each O: QueryExpression>(_ terms: repeat each O) {
    var expressions: [any QueryExpression] = []
    for term in repeat each terms {
      expressions.append(term)
    }
    guard !expressions.isEmpty else { return nil }
    self.terms = expressions
  }
}
extension GroupClause: QueryExpression {
  typealias Value = Void
  var sql: String { "GROUP BY \(terms.map(\.sql).joined(separator: ", "))" }
  var bindings: [QueryBinding] { terms.flatMap(\.bindings) }
}

private struct HavingClause {
  var predicate: any QueryExpression<Bool>
}
extension HavingClause: QueryExpression {
  typealias Value = Void
  var sql: String { "HAVING \(predicate.sql)" }
  var bindings: [QueryBinding] { predicate.bindings }
}

private struct OrderClause {
  let terms: [any QueryExpression]
  init(terms: [any QueryExpression]) {
    self.terms = terms
  }
  init?<each O: QueryExpression>(_ terms: repeat each O) where repeat (each O).Value: Comparable {
    var expressions: [any QueryExpression] = []
    for term in repeat each terms {
      expressions.append(term)
    }
    guard !expressions.isEmpty else { return nil }
    self.terms = expressions
  }
}
extension OrderClause: QueryExpression {
  typealias Value = Void
  var sql: String { "ORDER BY \(terms.map(\.sql).joined(separator: ", "))" }
  var bindings: [QueryBinding] { terms.flatMap(\.bindings) }
}

private struct LimitClause {
  let maxLength: any QueryExpression<Int>
  let offset: (any QueryExpression<Int>)?
}
extension LimitClause: QueryExpression {
  typealias Value = Void
  var sql: String { "LIMIT \(maxLength.sql)\(offset.map { " OFFSET \($0.sql)" } ?? "")" }
  var bindings: [QueryBinding] { maxLength.bindings + (offset?.bindings ?? []) }
}
