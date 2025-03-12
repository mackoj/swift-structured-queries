import Observation

extension Table {
  public static func all() -> Select<(), Self, ()> {
    Select()
  }

  public static func select<ResultColumn: QueryExpression>(
    _ selection: (Columns) -> ResultColumn
  ) -> Select<ResultColumn.QueryValue, Self, ()>
  where ResultColumn.QueryValue: QueryRepresentable {
    all().select(selection)
  }

  public static func select<
    C1: QueryExpression,
    C2: QueryExpression,
    each C3: QueryExpression
  >(
    _ selection: (Columns) -> (C1, C2, repeat each C3)
  ) -> Select<(C1.QueryValue, C2.QueryValue, repeat (each C3).QueryValue), Self, ()>
  where
    C1.QueryValue: QueryRepresentable,
    C2.QueryValue: QueryRepresentable,
    repeat (each C3).QueryValue: QueryRepresentable
  {
    all().select(selection)
  }

  public static func distinct(_ isDistinct: Bool = true) -> Select<(), Self, ()> {
    all().distinct(isDistinct)
  }

  public static func join<
    each C: QueryDecodable,
    F: Table,
    each J: Table
  >(
    _ other: Select<(repeat each C), F, (repeat each J)>,
    on constraint: (
      (Columns, F.Columns, repeat (each J).Columns)
    ) -> some QueryExpression<Bool>
  ) -> Select<(repeat each C), Self, (F, repeat each J)> {
    all().join(other, on: constraint)
  }

  // NB: Optimization
  @_documentation(visibility: private)
  public static func join<each C: QueryDecodable, F: Table>(
    _ other: Select<(repeat each C), F, ()>,
    on constraint: (
      (Columns, F.Columns)
    ) -> some QueryExpression<Bool>
  ) -> Select<(repeat each C), Self, F> {
    all().join(other, on: constraint)
  }

  public static func leftJoin<
    each C: QueryDecodable,
    F: Table,
    each J: Table
  >(
    _ other: Select<(repeat each C), F, (repeat each J)>,
    on constraint: (
      (Columns, F.Columns, repeat (each J).Columns)
    ) -> some QueryExpression<Bool>
  ) -> Select<(repeat (each C)._Optionalized), Self, (Outer<F>, repeat Outer<each J>)> {
    let select = all().leftJoin(other, on: constraint)
    return select
  }

  // NB: Optimization
  @_documentation(visibility: private)
  public static func leftJoin<each C: QueryDecodable, F: Table>(
    _ other: Select<(repeat each C), F, ()>,
    on constraint: (
      (Columns, F.Columns)
    ) -> some QueryExpression<Bool>
  ) -> Select<(repeat (each C)._Optionalized), Self, Outer<F>> {
    let select = all().leftJoin(other, on: constraint)
    return select
  }

  public static func rightJoin<
    each C: QueryDecodable,
    F: Table,
    each J: Table
  >(
    _ other: Select<(repeat each C), F, (repeat each J)>,
    on constraint: (
      (Columns, F.Columns, repeat (each J).Columns)
    ) -> some QueryExpression<Bool>
  ) -> Select<(repeat each C), Outer<Self>, (F, repeat each J)> {
    let select = all().rightJoin(other, on: constraint)
    return select
  }

  // NB: Optimization
  @_documentation(visibility: private)
  public static func rightJoin<each C: QueryDecodable, F: Table>(
    _ other: Select<(repeat each C), F, ()>,
    on constraint: (
      (Columns, F.Columns)
    ) -> some QueryExpression<Bool>
  ) -> Select<(repeat each C), Outer<Self>, F> {
    let select = all().rightJoin(other, on: constraint)
    return select
  }

  public static func fullJoin<
    each C: QueryDecodable,
    F: Table,
    each J: Table
  >(
    _ other: Select<(repeat each C), F, (repeat each J)>,
    on constraint: (
      (Columns, F.Columns, repeat (each J).Columns)
    ) -> some QueryExpression<Bool>
  ) -> Select<
    (repeat (each C)._Optionalized),
    Outer<Self>,
    (Outer<F>, repeat Outer<each J>)
  > {
    let select = all().fullJoin(other, on: constraint)
    return select
  }

  // NB: Optimization
  @_documentation(visibility: private)
  public static func fullJoin<each C: QueryDecodable, F: Table>(
    _ other: Select<(repeat each C), F, ()>,
    on constraint: (
      (Columns, F.Columns)
    ) -> some QueryExpression<Bool>
  ) -> Select<(repeat (each C)._Optionalized), Outer<Self>, Outer<F>> {
    let select = all().fullJoin(other, on: constraint)
    return select
  }

  public static func group<C: QueryExpression>(
    by grouping: (Columns) -> C
  ) -> Select<(), Self, ()> where C.QueryValue: QueryDecodable {
    all().group(by: grouping)
  }

  public static func group<
    C1: QueryExpression,
    C2: QueryExpression,
    each C3: QueryExpression
  >(
    by grouping: (Columns) -> (C1, C2, repeat each C3)
  ) -> Select<(), Self, ()>
  where
    C1.QueryValue: QueryDecodable,
    C2.QueryValue: QueryDecodable,
    repeat (each C3).QueryValue: QueryDecodable
  {
    all().group(by: grouping)
  }

  public static func having(
    _ predicate: (Columns) -> some QueryExpression<Bool>
  ) -> Select<(), Self, ()> {
    all().having(predicate)
  }

  public static func order(
    by ordering: KeyPath<Columns, some QueryExpression>
  ) -> Select<(), Self, ()> {
    all().order(by: ordering)
  }

  public static func order(
    @AnyQueryExpressionBuilder
    by ordering: (Columns) -> [any QueryExpression]
  ) -> Select<(), Self, ()> {
    all().order(by: ordering)
  }

  public static func limit(
    _ maxLength: (Columns) -> some QueryExpression<Int>,
    offset: ((Columns) -> some QueryExpression<Int>)? = nil
  ) -> Select<(), Self, ()> {
    all().limit(maxLength, offset: offset)
  }

  public static func limit(_ maxLength: Int, offset: Int? = nil) -> Select<(), Self, ()> {
    all().limit(maxLength, offset: offset)
  }

  public static func count() -> Select<Int, Self, ()> {
    all().count()
  }
}

#if compiler(>=6.1)
  @dynamicMemberLookup
#endif
public struct Select<Columns, From: Table, Joins> {
  // NB: A parameter pack compiler crash forces us to heap-allocate this storage.
  private struct Clauses {
    var distinct = false
    var columns: [any QueryExpression] = []
    var joins: [JoinClause] = []
    var `where`: [any QueryExpression] = []
    var group: [any QueryExpression] = []
    var having: [any QueryExpression] = []
    var order: [any QueryExpression] = []
    var limit: LimitClause?
  }
  @CopyOnWrite private var clauses = Clauses()

  fileprivate var distinct: Bool {
    get { clauses.distinct }
    set { clauses.distinct = newValue }
    _modify { yield &clauses.distinct }
  }
  fileprivate var columns: [any QueryExpression] {
    get { clauses.columns }
    set { clauses.columns = newValue }
    _modify { yield &clauses.columns }
  }
  fileprivate var joins: [JoinClause] {
    get { clauses.joins }
    set { clauses.joins = newValue }
    _modify { yield &clauses.joins }
  }
  fileprivate var `where`: [any QueryExpression] {
    get { clauses.where }
    set { clauses.where = newValue }
    _modify { yield &clauses.where }
  }
  fileprivate var group: [any QueryExpression] {
    get { clauses.group }
    set { clauses.group = newValue }
    _modify { yield &clauses.group }
  }
  fileprivate var having: [any QueryExpression] {
    get { clauses.having }
    set { clauses.having = newValue }
    _modify { yield &clauses.having }
  }
  fileprivate var order: [any QueryExpression] {
    get { clauses.order }
    set { clauses.order = newValue }
    _modify { yield &clauses.order }
  }
  fileprivate var limit: LimitClause? {
    get { clauses.limit }
    set { clauses.limit = newValue }
    _modify { yield &clauses.limit }
  }

  fileprivate init(
    distinct: Bool,
    columns: [any QueryExpression],
    joins: [JoinClause],
    where: [any QueryExpression],
    group: [any QueryExpression],
    having: [any QueryExpression],
    order: [any QueryExpression],
    limit: LimitClause?
  ) {
    self.columns = columns
    self.joins = joins
    self.where = `where`
    self.group = group
    self.having = having
    self.order = order
    self.limit = limit
  }
}

extension Select {
  init(where: [any QueryExpression] = []) {
    self.where = `where`
  }

  #if compiler(>=6.1)
    // NB: This can cause 'EXC_BAD_ACCESS' when 'C2' or 'J2' contain parameters.
    // TODO: Report issue to Swift team.
    @available(
      *,
      unavailable,
      message: """
        No overload is available for this many columns/joins. To request more overloads, please file a GitHub issue that describes your use case: https://github.com/pointfreeco/swift-structured/queries
        """
    )
    public subscript<
      each C1: QueryRepresentable,
      each C2: QueryRepresentable,
      each J1: Table,
      each J2: Table
    >(
      dynamicMember keyPath: KeyPath<From.Type, Select<(repeat each C2), From, (repeat each J2)>>
    ) -> Select<(repeat each C1, repeat each C2), From, (repeat each J1, repeat each J2)>
    where Columns == (repeat each C1), Joins == (repeat each J1) {
      self + From.self[keyPath: keyPath]
    }
  #endif

  public func select<each C1: QueryRepresentable, C2: QueryExpression>(
    _ selection: (From.Columns) -> C2
  ) -> Select<(repeat each C1, C2.QueryValue), From, ()>
  where Columns == (repeat each C1), C2.QueryValue: QueryRepresentable, Joins == () {
    _select(selection)
  }

  public func select<each C1: QueryRepresentable, C2: QueryExpression, each J: Table>(
    _ selection: ((From.Columns, repeat (each J).Columns)) -> C2
  ) -> Select<(repeat each C1, C2.QueryValue), From, (repeat each J)>
  where Columns == (repeat each C1), C2.QueryValue: QueryRepresentable, Joins == (repeat each J) {
    _select(selection)
  }

  @_disfavoredOverload
  public func select<each C1: QueryRepresentable, C2: QueryExpression, each J: Table>(
    _ selection: (From.Columns, repeat (each J).Columns) -> C2
  ) -> Select<(repeat each C1, C2.QueryValue), From, (repeat each J)>
  where Columns == (repeat each C1), C2.QueryValue: QueryRepresentable, Joins == (repeat each J) {
    _select(selection)
  }

  public func select<
    each C1: QueryRepresentable,
    C2: QueryExpression,
    C3: QueryExpression,
    each C4: QueryExpression,
    each J: Table
  >(
    _ selection: ((From.Columns, repeat (each J).Columns)) -> (C2, C3, repeat each C4)
  ) -> Select<
    (repeat each C1, C2.QueryValue, C3.QueryValue, repeat (each C4).QueryValue),
    From,
    (repeat each J)
  >
  where
    Columns == (repeat each C1),
    C2.QueryValue: QueryRepresentable,
    C3.QueryValue: QueryRepresentable,
    repeat (each C4).QueryValue: QueryRepresentable,
    Joins == (repeat each J)
  {
    _select(selection)
  }

  @_disfavoredOverload
  public func select<
    each C1: QueryRepresentable,
    C2: QueryExpression,
    C3: QueryExpression,
    each C4: QueryExpression,
    each J: Table
  >(
    _ selection: (From.Columns, repeat (each J).Columns) -> (C2, C3, repeat each C4)
  ) -> Select<
    (repeat each C1, C2.QueryValue, C3.QueryValue, repeat (each C4).QueryValue),
    From,
    (repeat each J)
  >
  where
    Columns == (repeat each C1),
    C2.QueryValue: QueryRepresentable,
    C3.QueryValue: QueryRepresentable,
    repeat (each C4).QueryValue: QueryRepresentable,
    Joins == (repeat each J)
  {
    _select(selection)
  }

  private func _select<
    each C1: QueryRepresentable,
    each C2: QueryExpression,
    each J: Table
  >(
    _ selection: ((From.Columns, repeat (each J).Columns)) -> (repeat each C2)
  ) -> Select<(repeat each C1, repeat (each C2).QueryValue), From, (repeat each J)>
  where
    Columns == (repeat each C1),
    repeat (each C2).QueryValue: QueryRepresentable,
    Joins == (repeat each J)
  {
    Select<(repeat each C1, repeat (each C2).QueryValue), From, (repeat each J)>(
      distinct: distinct,
      columns: columns + Array(repeat each selection((From.columns, repeat (each J).columns))),
      joins: joins,
      where: `where`,
      group: group,
      having: having,
      order: order,
      limit: limit
    )
  }

  public func distinct(_ isDistinct: Bool = true) -> Self {
    var select = self
    select.distinct = distinct
    return select
  }

  public func join<
    each C1: QueryDecodable,
    each C2: QueryDecodable,
    F: Table,
    each J1: Table,
    each J2: Table
  >(
    // TODO: Report issue to Swift team. Using 'some' crashes the compiler.
    _ other: any SelectStatement<(repeat each C2), F, (repeat each J2)>,
    on constraint: (
      (From.Columns, repeat (each J1).Columns, F.Columns, repeat (each J2).Columns)
    ) -> some QueryExpression<Bool>
  ) -> Select<(repeat each C1, repeat each C2), From, (repeat each J1, F, repeat each J2)>
  where Columns == (repeat each C1), Joins == (repeat each J1) {
    let other = other.all()
    let join = JoinClause(
      operator: nil,
      table: F.self,
      constraint: constraint(
        (From.columns, repeat (each J1).columns, F.columns, repeat (each J2).columns)
      )
    )
    return Select<(repeat each C1, repeat each C2), From, (repeat each J1, F, repeat each J2)>(
      distinct: distinct || other.distinct,
      columns: columns + other.columns,
      joins: joins + [join] + other.joins,
      where: `where` + other.where,
      group: group + other.group,
      having: having + other.having,
      order: order + other.order,
      limit: other.limit ?? limit
    )
  }

  // NB: Optimization
  @_documentation(visibility: private)
  public func join<each C1: QueryDecodable, each C2: QueryDecodable, F: Table, each J: Table>(
    // TODO: Report issue to Swift team. Using 'some' crashes the compiler.
    _ other: any SelectStatement<(repeat each C2), F, ()>,
    on constraint: (
      (From.Columns, repeat (each J).Columns, F.Columns)
    ) -> some QueryExpression<Bool>
  ) -> Select<(repeat each C1, repeat each C2), From, (repeat each J, F)>
  where Columns == (repeat each C1), Joins == (repeat each J) {
    let other = other.all()
    let join = JoinClause(
      operator: nil,
      table: F.self,
      constraint: constraint(
        (From.columns, repeat (each J).columns, F.columns)
      )
    )
    return Select<(repeat each C1, repeat each C2), From, (repeat each J, F)>(
      distinct: distinct || other.distinct,
      columns: columns + other.columns,
      joins: joins + [join] + other.joins,
      where: `where` + other.where,
      group: group + other.group,
      having: having + other.having,
      order: order + other.order,
      limit: other.limit ?? limit
    )
  }

  public func leftJoin<
    each C1: QueryDecodable,
    each C2: QueryDecodable,
    F: Table,
    each J1: Table,
    each J2: Table
  >(
    // TODO: Report issue to Swift team. Using 'some' crashes the compiler.
    _ other: any SelectStatement<(repeat each C2), F, (repeat each J2)>,
    on constraint: (
      (From.Columns, repeat (each J1).Columns, F.Columns, repeat (each J2).Columns)
    ) -> some QueryExpression<Bool>
  ) -> Select<
    (repeat each C1, repeat (each C2)._Optionalized),
    From,
    (repeat each J1, Outer<F>, repeat Outer<each J2>)
  >
  where Columns == (repeat each C1), Joins == (repeat each J1) {
    let other = other.all()
    let join = JoinClause(
      operator: .left,
      table: F.self,
      constraint: constraint(
        (From.columns, repeat (each J1).columns, F.columns, repeat (each J2).columns)
      )
    )
    return Select<
      (repeat each C1, repeat (each C2)._Optionalized),
      From,
      (repeat each J1, Outer<F>, repeat Outer<(each J2)>)
    >(
      distinct: distinct || other.distinct,
      columns: columns + other.columns,
      joins: joins + [join] + other.joins,
      where: `where` + other.where,
      group: group + other.group,
      having: having + other.having,
      order: order + other.order,
      limit: other.limit ?? limit
    )
  }

  // NB: Optimization
  @_documentation(visibility: private)
  public func leftJoin<each C1: QueryDecodable, each C2: QueryDecodable, F: Table, each J: Table>(
    // TODO: Report issue to Swift team. Using 'some' crashes the compiler.
    _ other: any SelectStatement<(repeat each C2), F, ()>,
    on constraint: (
      (From.Columns, repeat (each J).Columns, F.Columns)
    ) -> some QueryExpression<Bool>
  ) -> Select<
    (repeat each C1, repeat (each C2)._Optionalized),
    From,
    (repeat each J, Outer<F>)
  >
  where Columns == (repeat each C1), Joins == (repeat each J) {
    let other = other.all()
    let join = JoinClause(
      operator: .left,
      table: F.self,
      constraint: constraint(
        (From.columns, repeat (each J).columns, F.columns)
      )
    )
    return Select<
      (repeat each C1, repeat (each C2)._Optionalized),
      From,
      (repeat each J, Outer<F>)
    >(
      distinct: distinct || other.distinct,
      columns: columns + other.columns,
      joins: joins + [join] + other.joins,
      where: `where` + other.where,
      group: group + other.group,
      having: having + other.having,
      order: order + other.order,
      limit: other.limit ?? limit
    )
  }

  public func rightJoin<
    each C1: QueryDecodable,
    each C2: QueryDecodable,
    F: Table,
    each J1: Table,
    each J2: Table
  >(
    // TODO: Report issue to Swift team. Using 'some' crashes the compiler.
    _ other: any SelectStatement<(repeat each C2), F, (repeat each J2)>,
    on constraint: (
      (From.Columns, repeat (each J1).Columns, F.Columns, repeat (each J2).Columns)
    ) -> some QueryExpression<Bool>
  ) -> Select<
    (repeat (each C1)._Optionalized, repeat each C2),
    Outer<From>,
    (repeat Outer<each J1>, F, repeat each J2)
  >
  where Columns == (repeat each C1), Joins == (repeat each J1) {
    let other = other.all()
    let join = JoinClause(
      operator: .right,
      table: F.self,
      constraint: constraint(
        (From.columns, repeat (each J1).columns, F.columns, repeat (each J2).columns)
      )
    )
    return Select<
      (repeat (each C1)._Optionalized, repeat each C2),
      Outer<From>,
      (repeat Outer<each J1>, F, repeat each J2)
    >(
      distinct: distinct || other.distinct,
      columns: columns + other.columns,
      joins: joins + [join] + other.joins,
      where: `where` + other.where,
      group: group + other.group,
      having: having + other.having,
      order: order + other.order,
      limit: other.limit ?? limit
    )
  }

  // NB: Optimization
  @_documentation(visibility: private)
  public func rightJoin<each C1: QueryDecodable, each C2: QueryDecodable, F: Table, each J: Table>(
    // TODO: Report issue to Swift team. Using 'some' crashes the compiler.
    _ other: any SelectStatement<(repeat each C2), F, ()>,
    on constraint: (
      (From.Columns, repeat (each J).Columns, F.Columns)
    ) -> some QueryExpression<Bool>
  ) -> Select<
    (repeat (each C1)._Optionalized, repeat each C2),
    Outer<From>,
    (repeat Outer<each J>, F)
  >
  where Columns == (repeat each C1), Joins == (repeat each J) {
    let other = other.all()
    let join = JoinClause(
      operator: .right,
      table: F.self,
      constraint: constraint(
        (From.columns, repeat (each J).columns, F.columns)
      )
    )
    return Select<
      (repeat (each C1)._Optionalized, repeat each C2),
      Outer<From>,
      (repeat Outer<each J>, F)
    >(
      distinct: distinct || other.distinct,
      columns: columns + other.columns,
      joins: joins + [join] + other.joins,
      where: `where` + other.where,
      group: group + other.group,
      having: having + other.having,
      order: order + other.order,
      limit: other.limit ?? limit
    )
  }

  public func fullJoin<
    each C1: QueryDecodable,
    each C2: QueryDecodable,
    F: Table,
    each J1: Table,
    each J2: Table
  >(
    // TODO: Report issue to Swift team. Using 'some' crashes the compiler.
    _ other: any SelectStatement<(repeat each C2), F, (repeat each J2)>,
    on constraint: (
      (From.Columns, repeat (each J1).Columns, F.Columns, repeat (each J2).Columns)
    ) -> some QueryExpression<Bool>
  ) -> Select<
    (repeat (each C1)._Optionalized, repeat (each C2)._Optionalized),
    Outer<From>,
    (repeat Outer<each J1>, Outer<F>, repeat Outer<each J2>)
  >
  where Columns == (repeat each C1), Joins == (repeat each J1) {
    let other = other.all()
    let join = JoinClause(
      operator: .full,
      table: F.self,
      constraint: constraint(
        (From.columns, repeat (each J1).columns, F.columns, repeat (each J2).columns)
      )
    )
    return Select<
      (repeat (each C1)._Optionalized, repeat (each C2)._Optionalized),
      Outer<From>,
      (repeat Outer<each J1>, Outer<F>, repeat Outer<each J2>)
    >(
      distinct: distinct || other.distinct,
      columns: columns + other.columns,
      joins: joins + [join] + other.joins,
      where: `where` + other.where,
      group: group + other.group,
      having: having + other.having,
      order: order + other.order,
      limit: other.limit ?? limit
    )
  }

  // NB: Optimization
  @_documentation(visibility: private)
  public func fullJoin<each C1: QueryDecodable, each C2: QueryDecodable, F: Table, each J: Table>(
    // TODO: Report issue to Swift team. Using 'some' crashes the compiler.
    _ other: any SelectStatement<(repeat each C2), F, ()>,
    on constraint: (
      (From.Columns, repeat (each J).Columns, F.Columns)
    ) -> some QueryExpression<Bool>
  ) -> Select<
    (repeat (each C1)._Optionalized, repeat (each C2)._Optionalized),
    Outer<From>,
    (repeat Outer<each J>, Outer<F>)
  >
  where Columns == (repeat each C1), Joins == (repeat each J) {
    let other = other.all()
    let join = JoinClause(
      operator: .full,
      table: F.self,
      constraint: constraint(
        (From.columns, repeat (each J).columns, F.columns)
      )
    )
    return Select<
      (repeat (each C1)._Optionalized, repeat (each C2)._Optionalized),
      Outer<From>,
      (repeat Outer<each J>, Outer<F>)
    >(
      distinct: distinct || other.distinct,
      columns: columns + other.columns,
      joins: joins + [join] + other.joins,
      where: `where` + other.where,
      group: group + other.group,
      having: having + other.having,
      order: order + other.order,
      limit: other.limit ?? limit
    )
  }

  public func `where`<each J: Table>(
    _ predicate: (From.Columns, repeat (each J).Columns) -> some QueryExpression<Bool>
  ) -> Self
  where Joins == (repeat each J) {
    var select = self
    select.where.append(predicate(From.columns, repeat (each J).columns))
    return select
  }

  public func group<C: QueryExpression, each J: Table>(
    by grouping: (From.Columns, repeat (each J).Columns) -> C
  ) -> Self
  where C.QueryValue: QueryDecodable, Joins == (repeat each J) {
    _group(by: grouping)
  }

  public func group<
    C1: QueryExpression,
    C2: QueryExpression,
    each C3: QueryExpression,
    each J: Table
  >(
    by grouping: (From.Columns, repeat (each J).Columns) -> (C1, C2, repeat each C3)
  ) -> Self
  where
    C1.QueryValue: QueryDecodable,
    C2.QueryValue: QueryDecodable,
    repeat (each C3).QueryValue: QueryDecodable,
    Joins == (repeat each J)
  {
    _group(by: grouping)
  }

  private func _group<
    each C: QueryExpression,
    each J: Table
  >(
    by grouping: (From.Columns, repeat (each J).Columns) -> (repeat each C)
  ) -> Self
  where
    repeat (each C).QueryValue: QueryDecodable,
    Joins == (repeat each J)
  {
    var select = self
    select.group
      .append(
        contentsOf: Array(repeat each grouping(From.columns, repeat (each J).columns))
      )
    return select
  }

  public func having<each J: Table>(
    _ predicate: (From.Columns, repeat (each J).Columns) -> some QueryExpression<Bool>
  ) -> Self
  where Joins == (repeat each J) {
    var select = self
    select.having.append(predicate(From.columns, repeat (each J).columns))
    return select
  }

  public func order(by ordering: KeyPath<From.Columns, some QueryExpression>) -> Self {
    var select = self
    select.order.append(From.columns[keyPath: ordering])
    return select
  }

  public func order<each J: Table>(
    @AnyQueryExpressionBuilder
    by ordering: (From.Columns, repeat (each J).Columns) -> [any QueryExpression]
  ) -> Self
  where Joins == (repeat each J) {
    var select = self
    select.order.append(contentsOf: ordering(From.columns, repeat (each J).columns))
    return select
  }

  public func limit<each J: Table>(
    _ maxLength: (From.Columns, repeat (each J).Columns) -> some QueryExpression<Int>,
    offset: ((From.Columns, repeat (each J).Columns) -> some QueryExpression<Int>)? = nil
  ) -> Self
  where Joins == (repeat each J) {
    var select = self
    select.limit = LimitClause(
      maxLength: maxLength(From.columns, repeat (each J).columns),
      offset: offset?(From.columns, repeat (each J).columns)
    )
    return select
  }

  public func limit<each J: Table>(_ maxLength: Int, offset: Int? = nil) -> Self
  where Joins == (repeat each J) {
    var select = self
    select.limit = LimitClause(maxLength: maxLength, offset: offset)
    return select
  }

  public func count<each C: QueryRepresentable, each J: Table>() -> Select<
    (repeat each C, Int), From, (repeat each J)
  >
  where Columns == (repeat each C), Joins == (repeat each J) {
    select { _ in .count() }
  }
}

public func + <
  each C1: QueryRepresentable,
  each C2: QueryRepresentable,
  From: Table,
  each J1: Table,
  each J2: Table
>(
  // TODO: Report issue to Swift team. Using 'some' crashes the compiler.
  lhs: any SelectStatement<(repeat each C1), From, (repeat each J1)>,
  rhs: any SelectStatement<(repeat each C2), From, (repeat each J2)>
) -> Select<
  (repeat each C1, repeat each C2), From, (repeat each J1, repeat each J2)
> {
  let lhs = lhs.all()
  let rhs = rhs.all()
  return Select<
    (repeat each C1, repeat each C2), From, (repeat each J1, repeat each J2)
  >(
    distinct: lhs.distinct || rhs.distinct,
    columns: lhs.columns + rhs.columns,
    joins: lhs.joins + rhs.joins,
    where: lhs.where + rhs.where,
    group: lhs.group + rhs.group,
    having: lhs.having + rhs.having,
    order: lhs.order + rhs.order,
    limit: rhs.limit ?? lhs.limit
  )
}

extension Select: SelectStatement {
  public typealias QueryValue = Columns

  public func all() -> Self {
    self
  }

  public var query: QueryFragment {
    let columns =
      columns.isEmpty
      ? (From.columns.allColumns + joins.flatMap { $0.table.columns.allColumns })
      : columns
    var query: QueryFragment = "SELECT"
    if distinct {
      query.append(" DISTINCT")
    }
    query.append(" \(columns.map(\.queryFragment).joined(separator: ", "))")
    query.append(" FROM \(raw: From.tableName.quoted())")
    for join in joins {
      query.append(" \(join)")
    }
    if !`where`.isEmpty {
      query.append(" WHERE \(`where`.map(\.queryFragment).joined(separator: " AND "))")
    }
    if !group.isEmpty {
      query.append(" GROUP BY \(group.map(\.queryFragment).joined(separator: ", "))")
    }
    if !having.isEmpty {
      query.append(" HAVING \(having.map(\.queryFragment).joined(separator: " AND "))")
    }
    if !order.isEmpty {
      query.append(" ORDER BY \(order.map(\.queryFragment).joined(separator: ", "))")
    }
    if let limit {
      query.append(" \(limit)")
    }
    return query
  }
}

public typealias SelectOf<From: Table, each Join: Table> =
  Select<(), From, (repeat each Join)>

private struct JoinClause: QueryExpression {
  typealias QueryValue = Void

  enum Operator: String {
    case full = "FULL"
    case inner = "INNER"
    case left = "LEFT"
    case right = "RIGHT"
  }

  let `operator`: Operator?
  let table: any Table.Type
  let constraint: any QueryExpression<Bool>

  var queryFragment: QueryFragment {
    var query: QueryFragment = ""
    if let `operator` {
      query.append("\(raw: `operator`.rawValue) ")
    }
    query.append("JOIN \(raw: table.tableName.quoted()) ON \(constraint)")
    return query
  }
}

private struct LimitClause: QueryExpression {
  typealias QueryValue = Void

  let maxLength: any QueryExpression
  let offset: (any QueryExpression)?

  var queryFragment: QueryFragment {
    var query: QueryFragment = "LIMIT \(maxLength)"
    if let offset {
      query.append(" OFFSET \(offset)")
    }
    return query
  }
}

@propertyWrapper
private struct CopyOnWrite<Value> {
  final class Storage {
    var value: Value
    init(value: Value) {
      self.value = value
    }
  }
  var storage: Storage
  init(wrappedValue: Value) {
    self.storage = Storage(value: wrappedValue)
  }
  var wrappedValue: Value {
    get { storage.value }
    set {
      if isKnownUniquelyReferenced(&storage) {
        storage.value = newValue
      } else {
        storage = Storage(value: newValue)
      }
    }
  }
}

extension CopyOnWrite: Sendable where Value: Sendable {}

extension CopyOnWrite.Storage: @unchecked Sendable where Value: Sendable {}
