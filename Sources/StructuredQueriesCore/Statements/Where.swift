extension Table {
  /// Applies a filter to a statement using a `WHERE` clause.
  ///
  /// ```swift
  /// @Table
  /// struct User {
  ///   let id: Int
  ///   var email: String
  /// }
  ///
  /// User.where { $0.id == 1 }
  /// // WHERE ("users"."id" = 1)
  ///
  /// User.where { $0.like("%@pointfree.co") }
  /// // WHERE ("users"."email" LIKE '%@pointfree.co')
  /// ```
  ///
  /// If executed directly, `WHERE` is applied to an otherwise bare `SELECT` statement:
  ///
  /// ```swift
  /// try db.execute(User.where { $0.id == 1 })
  /// // SELECT "users"."id", "users"."email" FROM "users"
  /// // WHERE "users"."id" = 1
  /// ```
  ///
  /// - Parameter predicate: A predicate used to generate the `WHERE` clause.
  /// - Returns: A `WHERE` clause.
  public static func `where`(
    _ predicate: (TableColumns) -> some QueryExpression<Bool>
  ) -> Where<Self> {
    Where(predicates: [predicate(columns).queryFragment])
  }
}

/// A `WHERE` clause used to apply a filter to a statement.
///
/// See ``Table/where(_:)`` for how to create this type.
#if compiler(>=6.1)
  @dynamicMemberLookup
#endif
public struct Where<From: Table> {
  public static func + (lhs: Self, rhs: Self) -> Self {
    Where(predicates: lhs.predicates + rhs.predicates)
  }

  var predicates: [QueryFragment] = []

  #if compiler(>=6.1)
    public subscript<each C: QueryRepresentable, each J: Table>(
      dynamicMember keyPath: KeyPath<From.Type, Select<(repeat each C), From, (repeat each J)>>
    ) -> Select<(repeat each C), From, (repeat each J)> {
      self + From.self[keyPath: keyPath]
    }

    public subscript(dynamicMember keyPath: KeyPath<From.Type, Self>) -> Self {
      self + From.self[keyPath: keyPath]
    }
  #endif
}

extension Where: SelectStatement {
  public typealias QueryValue = ()

  public func all() -> Select<(), From, ()> {
    Select(where: predicates)
  }

  public func select<C: QueryExpression>(
    _ selection: KeyPath<From.TableColumns, C>
  ) -> Select<C.QueryValue, From, ()>
  where C.QueryValue: QueryRepresentable {
    all().select(selection)
  }

  public func select<C: QueryExpression>(
    _ selection: (From.TableColumns) -> C
  ) -> Select<C.QueryValue, From, ()>
  where C.QueryValue: QueryRepresentable {
    all().select(selection)
  }

  public func select<C1: QueryExpression, C2: QueryExpression, each C3: QueryExpression>(
    _ selection: (From.TableColumns) -> (C1, C2, repeat each C3)
  ) -> Select<(C1.QueryValue, C2.QueryValue, repeat (each C3).QueryValue), From, ()>
  where
    C1.QueryValue: QueryRepresentable,
    C2.QueryValue: QueryRepresentable,
    repeat (each C3).QueryValue: QueryRepresentable
  {
    all().select(selection)
  }

  public func distinct(_ isDistinct: Bool = true) -> Select<(), From, ()> {
    all().distinct(isDistinct)
  }

  public func join<each C: QueryDecodable, F: Table, each J: Table>(
    _ other: any SelectStatement<(repeat each C), F, (repeat each J)>,
    on constraint: (
      (From.TableColumns, F.TableColumns, repeat (each J).TableColumns)
    ) -> some QueryExpression<Bool>
  ) -> Select<(repeat each C), From, (F, repeat each J)> {
    all().join(other, on: constraint)
  }

  // NB: Optimization
  @_documentation(visibility: private)
  public func join<each C: QueryDecodable, F: Table>(
    _ other: any SelectStatement<(repeat each C), F, ()>,
    on constraint: ((From.TableColumns, F.TableColumns)) -> some QueryExpression<Bool>
  ) -> Select<(repeat each C), From, F> {
    all().join(other, on: constraint)
  }

  public func leftJoin<each C: QueryDecodable, F: Table, each J: Table>(
    _ other: any SelectStatement<(repeat each C), F, (repeat each J)>,
    on constraint: (
      (From.TableColumns, F.TableColumns, repeat (each J).TableColumns)
    ) -> some QueryExpression<Bool>
  ) -> Select<(repeat (each C)._Optionalized), From, (Outer<F>, repeat Outer<each J>)> {
    let joined = all().leftJoin(other, on: constraint)
    return joined
  }

  // NB: Optimization
  @_documentation(visibility: private)
  public func leftJoin<each C: QueryDecodable, F: Table>(
    _ other: any SelectStatement<(repeat each C), F, ()>,
    on constraint: ((From.TableColumns, F.TableColumns)) -> some QueryExpression<Bool>
  ) -> Select<(repeat (each C)._Optionalized), From, (Outer<F>)> {
    all().leftJoin(other, on: constraint)
  }

  public func rightJoin<each C: QueryDecodable, F: Table, each J: Table>(
    _ other: any SelectStatement<(repeat each C), F, (repeat each J)>,
    on constraint: (
      (From.TableColumns, F.TableColumns, repeat (each J).TableColumns)
    ) -> some QueryExpression<Bool>
  ) -> Select<(repeat each C), Outer<From>, (F, repeat each J)> {
    let joined = all().rightJoin(other, on: constraint)
    return joined
  }

  // NB: Optimization
  @_documentation(visibility: private)
  public func rightJoin<each C: QueryDecodable, F: Table>(
    _ other: any SelectStatement<(repeat each C), F, ()>,
    on constraint: ((From.TableColumns, F.TableColumns)) -> some QueryExpression<Bool>
  ) -> Select<(repeat each C), Outer<From>, F> {
    all().rightJoin(other, on: constraint)
  }

  public func fullJoin<each C: QueryDecodable, F: Table, each J: Table>(
    _ other: any SelectStatement<(repeat each C), F, (repeat each J)>,
    on constraint: (
      (From.TableColumns, F.TableColumns, repeat (each J).TableColumns)
    ) -> some QueryExpression<Bool>
  ) -> Select<(repeat (each C)._Optionalized), Outer<From>, (Outer<F>, repeat Outer<each J>)> {
    let joined = all().fullJoin(other, on: constraint)
    return joined
  }

  // NB: Optimization
  @_documentation(visibility: private)
  public func fullJoin<each C: QueryDecodable, F: Table>(
    _ other: any SelectStatement<(repeat each C), F, ()>,
    on constraint: ((From.TableColumns, F.TableColumns)) -> some QueryExpression<Bool>
  ) -> Select<(repeat (each C)._Optionalized), Outer<From>, Outer<F>> {
    all().fullJoin(other, on: constraint)
  }

  public func `where`(_ predicate: (From.TableColumns) -> some QueryExpression<Bool>) -> Self {
    var `where` = self
    `where`.predicates.append(predicate(From.columns).queryFragment)
    return `where`
  }

  public func group<C: QueryExpression>(by grouping: (From.TableColumns) -> C) -> Select<
    (), From, ()
  >
  where C.QueryValue: QueryDecodable {
    all().group(by: grouping)
  }

  public func group<C1: QueryExpression, C2: QueryExpression, each C3: QueryExpression>(
    by grouping: (From.TableColumns) -> (C1, C2, repeat each C3)
  ) -> Select<(), From, ()>
  where
    C1.QueryValue: QueryDecodable,
    C2.QueryValue: QueryDecodable,
    repeat (each C3).QueryValue: QueryDecodable
  {
    all().group(by: grouping)
  }

  public func having(
    _ predicate: (From.TableColumns) -> some QueryExpression<Bool>
  ) -> Select<(), From, ()> {
    all().having(predicate)
  }

  public func order(
    by ordering: KeyPath<From.TableColumns, some QueryExpression>
  ) -> Select<(), From, ()> {
    all().order(by: ordering)
  }

  public func order(
    @QueryFragmentBuilder
    by ordering: (From.TableColumns) -> [QueryFragment]
  ) -> Select<(), From, ()> {
    all().order(by: ordering)
  }

  public func limit(
    _ maxLength: (From.TableColumns) -> some QueryExpression<Int>,
    offset: ((From.TableColumns) -> some QueryExpression<Int>)? = nil
  ) -> Select<(), From, ()> {
    all().limit(maxLength, offset: offset)
  }

  public func limit(_ maxLength: Int, offset: Int? = nil) -> Select<(), From, ()> {
    all().limit(maxLength, offset: offset)
  }

  public func count() -> Select<Int, From, ()> {
    all().count()
  }

  public func delete() -> DeleteOf<From> {
    Delete(where: predicates)
  }

  public func update(
    or conflictResolution: ConflictResolution? = nil,
    set updates: (inout Record<From>) -> Void
  ) -> UpdateOf<From> {
    var record = Record<From>()
    updates(&record)
    return Update(conflictResolution: conflictResolution, record: record, where: predicates)
  }

  public var query: QueryFragment {
    all().query
  }
}
