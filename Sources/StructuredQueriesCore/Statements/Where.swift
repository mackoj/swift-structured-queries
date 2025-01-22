extension Table {
  public static func `where`(_ predicate: (Columns) -> some QueryExpression<Bool>) -> Where<Self> {
    Where(predicate: predicate(columns))
  }
}

public struct Where<Base: Table> {
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

  public func all(as alias: String) -> Select<AliasedColumns<Base.Columns>, Base> {
    func open(_ predicate: some QueryExpression<Bool>) -> Select<AliasedColumns<Base.Columns>, Base> {
      Base.all(as: alias).where { _ in predicate }
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

  // TODO: Should this be a single endpoint on 'QueryExpression' instead?
  public var queryString: String { all().queryString }
  public var queryBindings: [QueryBinding] { all().queryBindings }
}
