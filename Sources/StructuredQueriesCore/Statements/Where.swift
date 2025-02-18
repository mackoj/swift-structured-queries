extension Table {
  public static func `where`(_ predicate: (Columns) -> some QueryExpression<Bool>) -> Where<Self> {
    Where(predicate: predicate(columns))
  }
}

#if compiler(>=6.1)
  @dynamicMemberLookup
#endif
public struct Where<Base: Table>: SelectProtocol {
  let predicate: any QueryExpression<Bool>

  public func `where`(_ predicate: (Base.Columns) -> some QueryExpression<Bool>) -> Self {
    func open(_ expression: some QueryExpression<Bool>) -> Self {
      Self(predicate: expression && predicate(Base.columns))
    }
    return open(self.predicate)
  }

  public func all() -> SelectOf<Base> {
    func open(_ predicate: some QueryExpression<Bool>) -> SelectOf<Base> {
      Base.all().where { _ in predicate }
    }
    return open(predicate)
  }

  public func delete() -> DeleteOf<Base> {
    func open(_ predicate: some QueryExpression<Bool>) -> Delete<Base, Void> {
      Base.delete().where { _ in predicate }
    }
    return open(predicate)
  }

  public func update(
    or conflictResolution: ConflictResolution? = nil,
    set updates: (inout Record<Base>) -> Void
  ) -> UpdateOf<Base> {
    func open(_ predicate: some QueryExpression<Bool>) -> Update<Base, Void> {
      Base.update(or: conflictResolution, set: updates).where { _ in predicate }
    }
    return open(predicate)
  }
}

extension Where: Statement {
  public typealias QueryOutput = [Base]

  public var queryFragment: QueryFragment { all().queryFragment }
}

extension Where {
  public func select<each O: QueryExpression>(
    distinct isDistinct: Bool = false,
    _ selection: (Base.Columns) -> (repeat each O)
  ) -> Select<Base.Columns, (repeat (each O).QueryOutput)>
  where repeat (each O).QueryOutput: QueryDecodable {
    all().select(distinct: isDistinct, selection)
  }

  public func select<O: QueryExpression>(
    distinct isDistinct: Bool = false,
    _ selection: (Base.Columns) -> O
  ) -> Select<Base.Columns, O.QueryOutput>
  where repeat O.QueryOutput: QueryDecodable {
    all().select(distinct: isDistinct, selection)
  }

  public func join<OtherInput, OtherOutput>(
    _ other: some SelectProtocol<OtherInput, OtherOutput>,
    on constraint: ((Base.Columns, OtherInput)) -> some QueryExpression<Bool>
  ) -> Select<(Base.Columns, OtherInput), (Base, OtherOutput)> {
    all().join(other, on: constraint)
  }

  public func leftJoin<OtherInput, OtherOutput>(
    _ other: some SelectProtocol<OtherInput, OtherOutput>,
    on constraint: ((Base.Columns, OtherInput)) -> some QueryExpression<Bool>
  ) -> Select<(Base.Columns, OtherInput), (Base, OtherOutput?)> {
    all().leftJoin(other, on: constraint)
  }

  public func rightJoin<OtherInput, OtherOutput>(
    _ other: some SelectProtocol<OtherInput, OtherOutput>,
    on constraint: ((Base.Columns, OtherInput)) -> some QueryExpression<Bool>
  ) -> Select<(Base.Columns, OtherInput), (Base?, OtherOutput)> {
    all().rightJoin(other, on: constraint)
  }

  public func fullJoin<OtherInput, OtherOutput>(
    _ other: some SelectProtocol<OtherInput, OtherOutput>,
    on constraint: ((Base.Columns, OtherInput)) -> some QueryExpression<Bool>
  ) -> Select<(Base.Columns, OtherInput), (Base?, OtherOutput?)> {
    all().fullJoin(other, on: constraint)
  }

  public func group<each O: QueryExpression>(
    by grouping: (Base.Columns) -> (repeat each O)
  ) -> SelectOf<Base> {
    all().group(by: grouping)
  }

  public func having(_ predicate: (Base.Columns) -> some QueryExpression<Bool>) -> SelectOf<Base> {
    all().having(predicate)
  }

  public func order<each O: _OrderingTerm>(
    by ordering: (Base.Columns) -> (repeat each O)
  ) -> SelectOf<Base> {
    all().order(by: ordering)
  }

  public func order(
    @OrderingBuilder by ordering: (Base.Columns) -> [OrderingTerm]
  ) -> SelectOf<Base> {
    all().order(by: ordering)
  }

  public func limit(
    _ maxLength: (Base.Columns) -> some QueryExpression<Int>,
    offset: ((Base.Columns) -> some QueryExpression<Int>)? = nil
  ) -> SelectOf<Base> {
    all().limit(maxLength, offset: offset)
  }

  public func limit(_ maxLength: Int, offset: Int? = nil) -> SelectOf<Base> {
    all().limit(maxLength, offset: offset)
  }

  public func count() -> Select<Base.Columns, Int> {
    all().count()
  }
}
