extension Table {
  public static func all() -> SelectOf<Self> {
    Select(from: Self.self)
  }

  public static func all(as alias: String) -> Select<AliasedColumns<Columns>, Self> {
    Select(from: Self.self, as: alias)
  }
}

extension Select {
  public init(from table: Output.Type = Output.self) where Output: Table, Input == Output.Columns {
    self.init(
      input: Output.columns,
      from: TableAlias(alias: nil, table: Output.self)
    )
  }

  public init(
    from table: Output.Type = Output.self,
    as alias: String
  ) where Output: Table, Input == AliasedColumns<Output.Columns> {
    self.init(
      input: AliasedColumns(alias: alias, columns: Output.columns),
      from: TableAlias(alias: alias, table: Output.self)
    )
  }
}

@dynamicMemberLookup
public struct AliasedColumns<Columns: Schema>: Schema {
  public typealias QueryOutput = Columns.QueryOutput
  let alias: String?
  let columns: Columns
  public subscript<Column>(dynamicMember keyPath: KeyPath<Columns, Column>) -> AliasedColumn<Column> {
    AliasedColumn(alias: alias, column: columns[keyPath: keyPath])
  }
  public var allColumns: [any ColumnExpression<Columns.QueryOutput>] {
    columns.allColumns.map { column in
      func open(_ column: some ColumnExpression<Columns.QueryOutput>) -> any ColumnExpression<Columns.QueryOutput> {
        AliasedColumn(alias: alias, column: column)
      }
      return open(column)
    }
  }
}
public struct AliasedColumn<Column: ColumnExpression>: ColumnExpression {

  public typealias Root = Column.Root
  public typealias QueryOutput = Column.QueryOutput

  let alias: String?
  let column: Column
  public var keyPath: PartialKeyPath<Column.Root> { column.keyPath }
  public var name: String { column.name }
  public var queryString: String {
    if let alias {
      "\(alias.quoted()).\(column.name.quoted())"
    } else {
      column.queryString
    }
  }
  public var queryBindings: [QueryBinding] { [] }
}

struct TableAlias: QueryExpression {
  typealias QueryOutput = Void

  var alias: String?
  let table: any Table.Type
  var queryString: String {
    if let alias {
      "\(table.name.quoted()) AS \(alias.quoted())"
    } else {
      table.name.quoted()
    }
  }
  var queryBindings: [QueryBinding] { [] }
}

public struct Select<Input: Sendable, Output> {
  fileprivate var input: Input
  fileprivate var isDistinct = false
  fileprivate var select: [any QueryExpression] = []
  fileprivate var from: TableAlias
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
  ) -> Select<Input, (repeat (each O).QueryOutput)>
  where repeat (each O).QueryOutput: QueryDecodable {
    var select: [any QueryExpression] = []
    for o in repeat each selection(input) {
      select.append(o)
    }
    return Select<Input, (repeat (each O).QueryOutput)>(
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

  public func select<O: QueryExpression>(
    distinct isDistinct: Bool = false,
    _ selection: (Input) -> O
  ) -> Select<Input, O.QueryOutput>
  where repeat O.QueryOutput: QueryDecodable {
    Select<Input, O.QueryOutput>(
      input: input,
      isDistinct: isDistinct,
      select: [selection(input)],
      from: from,
      joins: joins,
      where: `where`,
      group: group,
      having: having,
      order: order,
      limit: limit
    )
  }

  public func join<OtherInput, OtherOutput>(
    _ other: Select<OtherInput, OtherOutput>,
    on constraint: ((Input, OtherInput)) -> some QueryExpression<Bool>
  ) -> Select<(Input, OtherInput), (Output, OtherOutput)> {
    _join(self, other, on: constraint)
  }

  public func leftJoin<OtherInput, OtherOutput>(
    _ other: Select<OtherInput, OtherOutput>,
    on constraint: ((Input, OtherInput)) -> some QueryExpression<Bool>
  ) -> Select<(Input, OtherInput), (Output, OtherOutput?)> {
    _leftJoin(self, other, on: constraint)
  }

  public func rightJoin<OtherInput, OtherOutput>(
    _ other: Select<OtherInput, OtherOutput>,
    on constraint: ((Input, OtherInput)) -> some QueryExpression<Bool>
  ) -> Select<(Input, OtherInput), (Output?, OtherOutput)> {
    _rightJoin(self, other, on: constraint)
  }

  public func fullJoin<OtherInput, OtherOutput>(
    _ other: Select<OtherInput, OtherOutput>,
    on constraint: ((Input, OtherInput)) -> some QueryExpression<Bool>
  ) -> Select<(Input, OtherInput), (Output?, OtherOutput?)> {
    _fullJoin(self, other, on: constraint)
  }

  public func `where`(_ predicate: (Input) -> some QueryExpression<Bool>) -> Self {
    func open(_ `where`: some QueryExpression<Bool>) -> WhereClause {
      WhereClause(predicate: `where` && predicate(input))
    }
    var copy = self
    copy.`where` =
      if let `where` {
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
    copy.having =
      if let having {
        open(having.predicate)
      } else {
        HavingClause(predicate: predicate(input))
      }
    return copy
  }

  public func order<each O: _OrderingTerm>(_ ordering: (Input) -> (repeat each O)) -> Self {
    var copy = self
    copy.order = OrderClause(repeat each ordering(input))
    return copy
  }

  public func order(
    @OrderingBuilder _ ordering: (Input) -> [OrderingTerm]
  ) -> Self {
    var copy = self
    copy.order = OrderClause(terms: ordering(input))
    return copy
  }

  // TODO: write tests
  public func limit(
    _ maxLength: (Input) -> some QueryExpression<Int>,
    offset: ((Input) -> some QueryExpression<Int>)? = nil
  ) -> Self {
    var copy = self
    copy.limit = LimitClause(maxLength: maxLength(input), offset: offset?(input))
    return copy
  }

  // TODO: write tests
  public func limit(_ maxLength: Int, offset: Int? = nil) -> Self {
    limit(
      { _ in maxLength },
      offset: offset.map { offset in { _ in offset } }
    )
  }

  public func count() -> Select<Input, Int> {
    self.select { _ in .count() }
  }
}

public typealias SelectOf<each T: Table> = Select<(repeat (each T).Columns), (repeat each T)>

// Player.all().join(Team.self) { $0.teamID == $1.id }

extension Select: Statement {
  public typealias QueryOutput = [Output]
  public var queryString: String {
    var sql = "SELECT"
    if isDistinct {
      sql.append(" DISTINCT")
    }
    let columns =
      select.isEmpty
    ? ([from] + joins.map(\.right)).map { tableAlias in
      func open(_ columns: some Schema) -> String {
        AliasedColumns(alias: tableAlias.alias, columns: columns).queryString
      }
      return open(tableAlias.table.columns)
    }
    : select.map {
      print($0.queryString)
      return $0.queryString
    }
    sql.append(" \(columns.joined(separator: ", "))")
    sql.append(" FROM \(from.queryString)")
    for join in joins {
      sql.append(" \(join.queryString)")
    }
    if let `where` {
      sql.append(" \(`where`.queryString)")
    }
    if let group {
      sql.append(" \(group.queryString)")
    }
    if let having {
      sql.append(" \(having.queryString)")
    }
    if let order {
      sql.append(" \(order.queryString)")
    }
    if let limit {
      sql.append(" \(limit.queryString)")
    }
    return sql
  }
  public var queryBindings: [QueryBinding] {
    var bindings: [QueryBinding] = []
    for column in select {
      bindings.append(contentsOf: column.queryBindings)
    }
    for join in joins {
      bindings.append(contentsOf: join.queryBindings)
    }
    if let `where` {
      bindings.append(contentsOf: `where`.queryBindings)
    }
    if let group {
      bindings.append(contentsOf: group.queryBindings)
    }
    if let having {
      bindings.append(contentsOf: having.queryBindings)
    }
    if let order {
      bindings.append(contentsOf: order.queryBindings)
    }
    if let limit {
      bindings.append(contentsOf: limit.queryBindings)
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
  let `where` =
    if let lhsWhere = lhs.where, let rhsWhere = rhs.where {
      WhereClause(predicate: open(lhsWhere.predicate, rhsWhere.predicate))
    } else {
      lhs.where ?? rhs.where
    }
  let group =
    if let lhsGroup = lhs.group, let rhsGroup = rhs.group {
      GroupClause(terms: lhsGroup.terms + rhsGroup.terms)
    } else {
      lhs.group ?? rhs.group
    }
  let having =
    if let lhsHaving = lhs.having, let rhsHaving = rhs.having {
      HavingClause(predicate: open(lhsHaving.predicate, rhsHaving.predicate))
    } else {
      lhs.having ?? rhs.having
    }
  let order =
    if let lhsOrder = lhs.order, let rhsOrder = rhs.order {
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
  let `where` =
    if let lhsWhere = lhs.where, let rhsWhere = rhs.where {
      WhereClause(predicate: open(lhsWhere.predicate, rhsWhere.predicate))
    } else {
      lhs.where ?? rhs.where
    }
  let group =
    if let lhsGroup = lhs.group, let rhsGroup = rhs.group {
      GroupClause(terms: lhsGroup.terms + rhsGroup.terms)
    } else {
      lhs.group ?? rhs.group
    }
  let having =
    if let lhsHaving = lhs.having, let rhsHaving = rhs.having {
      HavingClause(predicate: open(lhsHaving.predicate, rhsHaving.predicate))
    } else {
      lhs.having ?? rhs.having
    }
  let order =
    if let lhsOrder = lhs.order, let rhsOrder = rhs.order {
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
  let `where` =
    if let lhsWhere = lhs.where, let rhsWhere = rhs.where {
      WhereClause(predicate: open(lhsWhere.predicate, rhsWhere.predicate))
    } else {
      lhs.where ?? rhs.where
    }
  let group =
    if let lhsGroup = lhs.group, let rhsGroup = rhs.group {
      GroupClause(terms: lhsGroup.terms + rhsGroup.terms)
    } else {
      lhs.group ?? rhs.group
    }
  let having =
    if let lhsHaving = lhs.having, let rhsHaving = rhs.having {
      HavingClause(predicate: open(lhsHaving.predicate, rhsHaving.predicate))
    } else {
      lhs.having ?? rhs.having
    }
  let order =
    if let lhsOrder = lhs.order, let rhsOrder = rhs.order {
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
  let `where` =
    if let lhsWhere = lhs.where, let rhsWhere = rhs.where {
      WhereClause(predicate: open(lhsWhere.predicate, rhsWhere.predicate))
    } else {
      lhs.where ?? rhs.where
    }
  let group =
    if let lhsGroup = lhs.group, let rhsGroup = rhs.group {
      GroupClause(terms: lhsGroup.terms + rhsGroup.terms)
    } else {
      lhs.group ?? rhs.group
    }
  let having =
    if let lhsHaving = lhs.having, let rhsHaving = rhs.having {
      HavingClause(predicate: open(lhsHaving.predicate, rhsHaving.predicate))
    } else {
      lhs.having ?? rhs.having
    }
  let order =
    if let lhsOrder = lhs.order, let rhsOrder = rhs.order {
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
  enum Operator: String {
    case full = "FULL"
    case inner = "INNER"
    case left = "LEFT"
    case right = "RIGHT"
  }
  let `operator`: Operator?
  let right: TableAlias
  let condition: any QueryExpression<Bool>
}
extension JoinClause: QueryExpression {
  typealias QueryOutput = Void
  var queryString: String {
    "\(`operator`.map { "\($0.rawValue) " } ?? "")JOIN \(right.queryString) ON \(condition.queryString)"
  }
  var queryBindings: [QueryBinding] { condition.queryBindings }
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
  typealias QueryOutput = Void
  var queryString: String { "GROUP BY \(terms.map(\.queryString).joined(separator: ", "))" }
  var queryBindings: [QueryBinding] { terms.flatMap(\.queryBindings) }
}

private struct HavingClause {
  var predicate: any QueryExpression<Bool>
}
extension HavingClause: QueryExpression {
  typealias QueryOutput = Void
  var queryString: String { "HAVING \(predicate.queryString)" }
  var queryBindings: [QueryBinding] { predicate.queryBindings }
}

private struct OrderClause {
  let terms: [OrderingTerm]
  init?(terms: [OrderingTerm]) {
    guard !terms.isEmpty else { return nil }
    self.terms = terms
  }
  init?<each O: _OrderingTerm>(_ terms: repeat each O) {
    var expressions: [OrderingTerm] = []
    for term in repeat each terms {
      expressions.append(term._orderingTerm)
    }
    self.init(terms: expressions)
  }
}
extension OrderClause: QueryExpression {
  typealias QueryOutput = Void
  var queryString: String { "ORDER BY \(terms.map(\.queryString).joined(separator: ", "))" }
  var queryBindings: [QueryBinding] { terms.flatMap(\.queryBindings) }
}

private struct LimitClause {
  let maxLength: any QueryExpression
  let offset: (any QueryExpression)?
}
extension LimitClause: QueryExpression {
  typealias QueryOutput = Void
  var queryString: String {
    "LIMIT \(maxLength.queryString)\(offset.map { " OFFSET \($0.queryString)" } ?? "")"
  }
  var queryBindings: [QueryBinding] { maxLength.queryBindings + (offset?.queryBindings ?? []) }
}
