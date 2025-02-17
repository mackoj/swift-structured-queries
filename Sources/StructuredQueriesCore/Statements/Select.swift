extension Table {
  public static func all() -> SelectOf<Self> {
    Select(from: Self.self)
  }

  public static func all(as alias: String) -> Select<AliasedColumns<Columns>, Self> {
    Select(from: Self.self, as: alias)
  }

  public static func select<each O: QueryExpression>(
    distinct isDistinct: Bool = false,
    _ selection: (Columns) -> (repeat each O)
  ) -> Select<Columns, (repeat (each O).QueryOutput)>
  where repeat (each O).QueryOutput: QueryDecodable {
    all().select(distinct: isDistinct, selection)
  }

  public static func select<O: QueryExpression>(
    distinct isDistinct: Bool = false,
    _ selection: (Columns) -> O
  ) -> Select<Columns, O.QueryOutput>
  where repeat O.QueryOutput: QueryDecodable {
    all().select(distinct: isDistinct, selection)
  }

  public static func join<OtherInput, OtherOutput>(
    _ other: some SelectProtocol<OtherInput, OtherOutput>,
    on constraint: ((Columns, OtherInput)) -> some QueryExpression<Bool>
  ) -> Select<(Columns, OtherInput), (Self, OtherOutput)> {
    all().join(other, on: constraint)
  }

  public static func leftJoin<OtherInput, OtherOutput>(
    _ other: some SelectProtocol<OtherInput, OtherOutput>,
    on constraint: ((Columns, OtherInput)) -> some QueryExpression<Bool>
  ) -> Select<(Columns, OtherInput), (Self, OtherOutput?)> {
    all().leftJoin(other, on: constraint)
  }

  public static func rightJoin<OtherInput, OtherOutput>(
    _ other: some SelectProtocol<OtherInput, OtherOutput>,
    on constraint: ((Columns, OtherInput)) -> some QueryExpression<Bool>
  ) -> Select<(Columns, OtherInput), (Self?, OtherOutput)> {
    all().rightJoin(other, on: constraint)
  }

  public static func fullJoin<OtherInput, OtherOutput>(
    _ other: some SelectProtocol<OtherInput, OtherOutput>,
    on constraint: ((Columns, OtherInput)) -> some QueryExpression<Bool>
  ) -> Select<(Columns, OtherInput), (Self?, OtherOutput?)> {
    all().fullJoin(other, on: constraint)
  }

  public static func group<each O: QueryExpression>(by grouping: (Columns) -> (repeat each O)) -> SelectOf<Self> {
    all().group(by: grouping)
  }

  public static func having(_ predicate: (Columns) -> some QueryExpression<Bool>) -> SelectOf<Self> {
    all().having(predicate)
  }

  public static func order<each O: _OrderingTerm>(by ordering: (Columns) -> (repeat each O)) -> SelectOf<Self> {
    all().order(by: ordering)
  }

  public static func order(
    @OrderingBuilder by ordering: (Columns) -> [OrderingTerm]
  ) -> SelectOf<Self> {
    all().order(by: ordering)
  }

  // TODO: write tests
  public static func limit(
    _ maxLength: (Columns) -> some QueryExpression<Int>,
    offset: ((Columns) -> some QueryExpression<Int>)? = nil
  ) -> SelectOf<Self> {
    all().limit(maxLength, offset: offset)
  }

  // TODO: write tests
  public static func limit(_ maxLength: Int, offset: Int? = nil) -> SelectOf<Self> {
    all().limit(maxLength, offset: offset)
  }

  public static func count() -> Select<Columns, Int> {
    all().count()
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
  public var queryFragment: QueryFragment {
    if let alias {
      "\(raw: alias.quoted()).\(raw: column.name.quoted())"
    } else {
      column.queryFragment
    }
  }
}

struct TableAlias: QueryExpression {
  typealias QueryOutput = Void

  var alias: String?
  let table: any Table.Type
  var queryFragment: QueryFragment {
    var sql = QueryFragment(table.name.quoted())
    if let alias {
      sql.append(" AS \(raw: alias.quoted())")
    }
    return sql
  }
}

public protocol SelectProtocol<Input, Output> {
  associatedtype Input: Sendable
  associatedtype Output

  func all() -> Select<Input, Output>
}

public struct Select<Input: Sendable, Output>: SelectProtocol {
  fileprivate var input: Input
  fileprivate var isDistinct = false
  fileprivate var selectedColumns: [any QueryExpression] = []
  fileprivate var from: TableAlias
  fileprivate var joins: [JoinClause] = []
  fileprivate var `where`: WhereClause?
  fileprivate var group: GroupClause?
  fileprivate var having: HavingClause?
  fileprivate var order: OrderClause?
  fileprivate var limit: LimitClause?

  public func all() -> Self {
    self
  }

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
      selectedColumns: select,
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
      selectedColumns: [selection(input)],
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
    _ other: some SelectProtocol<OtherInput, OtherOutput>,
    on constraint: ((Input, OtherInput)) -> some QueryExpression<Bool>
  ) -> Select<(Input, OtherInput), (Output, OtherOutput)> {
    _join(self, other.all(), on: constraint)
  }

  public func leftJoin<OtherInput, OtherOutput>(
    _ other: some SelectProtocol<OtherInput, OtherOutput>,
    on constraint: ((Input, OtherInput)) -> some QueryExpression<Bool>
  ) -> Select<(Input, OtherInput), (Output, OtherOutput?)> {
    _leftJoin(self, other.all(), on: constraint)
  }

  public func rightJoin<OtherInput, OtherOutput>(
    _ other: some SelectProtocol<OtherInput, OtherOutput>,
    on constraint: ((Input, OtherInput)) -> some QueryExpression<Bool>
  ) -> Select<(Input, OtherInput), (Output?, OtherOutput)> {
    _rightJoin(self, other.all(), on: constraint)
  }

  public func fullJoin<OtherInput, OtherOutput>(
    _ other: some SelectProtocol<OtherInput, OtherOutput>,
    on constraint: ((Input, OtherInput)) -> some QueryExpression<Bool>
  ) -> Select<(Input, OtherInput), (Output?, OtherOutput?)> {
    _fullJoin(self, other.all(), on: constraint)
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

  public func order<each O: _OrderingTerm>(by ordering: (Input) -> (repeat each O)) -> Self {
    var copy = self
    copy.order = OrderClause(repeat each ordering(input))
    return copy
  }

  public func order(
    @OrderingBuilder by ordering: (Input) -> [OrderingTerm]
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
  public var queryFragment: QueryFragment {
    var sql: QueryFragment = "SELECT"
    if isDistinct {
      sql.append(" DISTINCT")
    }
    let columns =
      selectedColumns.isEmpty
    ? ([from] + joins.map(\.right)).map { tableAlias in
      func open(_ columns: some Schema) -> QueryFragment {
        AliasedColumns(alias: tableAlias.alias, columns: columns).queryFragment
      }
      return open(tableAlias.table.columns)
    }
    : selectedColumns.map {
      return $0.queryFragment
    }
    sql.append(" \(columns.joined(separator: ", "))")
    sql.append(" FROM \(from.queryFragment)")
    for join in joins {
      sql.append(" \(join.queryFragment)")
    }
    if let `where` {
      sql.append(" \(`where`.queryFragment)")
    }
    if let group {
      sql.append(" \(group.queryFragment)")
    }
    if let having {
      sql.append(" \(having.queryFragment)")
    }
    if let order {
      sql.append(" \(order.queryFragment)")
    }
    if let limit {
      sql.append(" \(limit.queryFragment)")
    }
    return sql
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
    selectedColumns: lhs.selectedColumns + rhs.selectedColumns,
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
    selectedColumns: lhs.selectedColumns + rhs.selectedColumns,
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
    selectedColumns: lhs.selectedColumns + rhs.selectedColumns,
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
    selectedColumns: lhs.selectedColumns + rhs.selectedColumns,
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
  var queryFragment: QueryFragment {
    var sql = QueryFragment()
    if let `operator` {
      sql.append("\(raw: `operator`.rawValue) ")
    }
    sql.append("JOIN \(bind: right) ON \(bind: condition)")
    return sql
  }
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
  var queryFragment: QueryFragment {
    "GROUP BY \(terms.map(\.queryFragment).joined(separator: ", "))"
  }
}

private struct HavingClause {
  var predicate: any QueryExpression<Bool>
}
extension HavingClause: QueryExpression {
  typealias QueryOutput = Void
  var queryFragment: QueryFragment { "HAVING \(bind: predicate)" }
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
  var queryFragment: QueryFragment {
    "ORDER BY \(terms.map(\.queryFragment).joined(separator: ", "))"
  }
}

private struct LimitClause {
  let maxLength: any QueryExpression
  let offset: (any QueryExpression)?
}
extension LimitClause: QueryExpression {
  typealias QueryOutput = Void
  var queryFragment: QueryFragment {
    var sql: QueryFragment = "LIMIT \(bind: maxLength)"
    if let offset {
      sql.append(" OFFSET \(bind: offset)")
    }
    return sql
  }
}
