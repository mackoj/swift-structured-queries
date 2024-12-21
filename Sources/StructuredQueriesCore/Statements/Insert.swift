extension Table {
  public static func insert<each C: ColumnExpression>(
    or conflictResolution: ConflictResolution? = nil,
    _ columns: (Columns) -> (repeat each C),
    @InsertValuesBuilder<(repeat (each C).Value)> values: () -> [(repeat (each C).Value)],
    onConflict updates: ((inout Record<Self>) -> Void)? = nil
  ) -> Insert<Self, (repeat each C), Void>
  where repeat (each C).Value: QueryExpression {
    let input = columns(Self.columns)
    var columns: [any ColumnExpression] = []
    for column in repeat each input {
      columns.append(column)
    }
    let values: [[any QueryExpression]] = values().map {
      var row: [any QueryExpression] = []
      for value in repeat each $0 {
        row.append(value)
      }
      return row
    }
    let record = updates.map { updates in
      var record = Record<Self>()
      updates(&record)
      return record
    }
    return Insert(
      input: input,
      conflictResolution: conflictResolution,
      columns: columns,
      form: .values(values),
      record: record
    )
  }

  // NB: Overload required to work around bug with parameter packs and result builders.
  public static func insert<C: ColumnExpression>(
    or conflictResolution: ConflictResolution? = nil,
    _ columns: (Columns) -> C,
    @InsertValuesBuilder<C.Value> values: () -> [C.Value],
    onConflict updates: ((inout Record<Self>) -> Void)? = nil
  ) -> Insert<Self, C, Void>
  where C.Value: QueryExpression {
    let input = columns(Self.columns)
    let values: [[any QueryExpression]] = values().map { [$0] }
    let record = updates.map { updates in
      var record = Record<Self>()
      updates(&record)
      return record
    }
    return Insert(
      input: input,
      conflictResolution: conflictResolution,
      columns: [input],
      form: .values(values),
      record: record
    )
  }

  public static func insert<I, each C: ColumnExpression>(
    or conflictResolution: ConflictResolution? = nil,
    _ columns: (Columns) -> (repeat each C),
    select selection: () -> Select<I, (repeat (each C).Value)>,
    onConflict updates: ((inout Record<Self>) -> Void)? = nil
  ) -> Insert<Self, (repeat each C), Void>
  where repeat (each C).Value: QueryExpression {
    let input = columns(Self.columns)
    var columns: [any ColumnExpression] = []
    for column in repeat each input {
      columns.append(column)
    }
    let record = updates.map { updates in
      var record = Record<Self>()
      updates(&record)
      return record
    }
    return Insert(
      input: input,
      conflictResolution: conflictResolution,
      columns: columns,
      form: .select(selection()),
      record: record
    )
  }

  // NB: Overload required to work around bug with parameter packs and result builders.
  public static func insert<I, C: ColumnExpression>(
    or conflictResolution: ConflictResolution? = nil,
    _ columns: (Columns) -> C,
    select selection: () -> Select<I, C.Value>,
    onConflict updates: ((inout Record<Self>) -> Void)? = nil
  ) -> Insert<Self, C, Void>
  where C.Value: QueryExpression {
    let input = columns(Self.columns)
    let record = updates.map { updates in
      var record = Record<Self>()
      updates(&record)
      return record
    }
    return Insert(
      input: input,
      conflictResolution: conflictResolution,
      columns: [input],
      form: .select(selection()),
      record: record
    )
  }

  public static func insert(
    or conflictResolution: ConflictResolution? = nil
  ) -> Insert<Self, Void, Void> {
    Insert(input: (), conflictResolution: conflictResolution)
  }
}

public struct Insert<Base: Table, Input: Sendable, Output> {
  fileprivate var input: Input
  fileprivate var conflictResolution: ConflictResolution?
  fileprivate var columns: [any ColumnExpression] = []
  fileprivate var form: InsertionForm = .defaultValues
  fileprivate var record: Record<Base>?
  fileprivate var returning: ReturningClause?

  public func returning<each O: QueryExpression>(
    _ selection: (Base.Columns) -> (repeat each O)
  ) -> Insert<Base, Input, (repeat (each O).Value)>
  where repeat (each O).Value: QueryDecodable {
    Insert<Base, Input, (repeat (each O).Value)>(
      input: input,
      conflictResolution: conflictResolution,
      columns: columns,
      form: form,
      record: record,
      returning: ReturningClause(repeat each selection(Base.columns))
    )
  }
}

extension Insert: Statement {
  public typealias Value = [Output]
  public var queryString: String {
    var sql = "INSERT"
    if let conflictResolution {
      sql.append(" OR \(conflictResolution.queryString)")
    }
    sql.append(" INTO \(Base.name.quoted())")
    if !columns.isEmpty {
      sql.append(" (\(columns.map { $0.name.quoted() }.joined(separator: ", ")))")
    }
    sql.append(" \(form.queryString)")
    if let record {
      sql.append(
        " ON CONFLICT DO \(record.updates.isEmpty ? "NOTHING" : "UPDATE \(record.queryString)")")
    }
    if let returning {
      sql.append(" \(returning.queryString)")
    }
    return sql
  }
  public var queryBindings: [QueryBinding] {
    var bindings = columns.flatMap(\.queryBindings)
    bindings.append(contentsOf: form.queryBindings)
    if let record {
      bindings.append(contentsOf: record.queryBindings)
    }
    if let returning {
      bindings.append(contentsOf: returning.queryBindings)
    }
    return bindings
  }
}

private enum InsertionForm: QueryExpression {
  case defaultValues
  case values([[any QueryExpression]])
  case select(any Statement)

  typealias Value = Void
  var queryString: String {
    switch self {
    case .defaultValues:
      return "DEFAULT VALUES"
    case let .values(rows):
      let values =
        rows
        .map { "(\($0.map(\.queryString).joined(separator: ", ")))" }
        .joined(separator: ", ")
      return """
        VALUES \(values)
        """
    case let .select(statement):
      return statement.queryString
    }
  }
  var queryBindings: [QueryBinding] {
    switch self {
    case .defaultValues:
      return []
    case let .values(rows):
      return rows.flatMap { $0.flatMap(\.queryBindings) }
    case let .select(statement):
      return statement.queryBindings
    }
  }
}

@resultBuilder
public enum InsertValuesBuilder<Value> {
  public static func buildArray(_ components: [[Value]]) -> [Value] {
    components.flatMap(\.self)
  }

  public static func buildBlock(_ components: [Value]) -> [Value] {
    components
  }

  public static func buildEither(first component: [Value]) -> [Value] {
    component
  }

  public static func buildEither(second component: [Value]) -> [Value] {
    component
  }

  public static func buildExpression(_ expression: Value) -> [Value] {
    [expression]
  }

  public static func buildExpression(_ expression: [Value]) -> [Value] {
    expression
  }

  public static func buildLimitedAvailability(_ component: [Value]) -> [Value] {
    component
  }

  public static func buildOptional(_ component: [Value]?) -> [Value] {
    component ?? []
  }

  public static func buildPartialBlock(first: [Value]) -> [Value] {
    first
  }

  public static func buildPartialBlock(accumulated: [Value], next: [Value]) -> [Value] {
    accumulated + next
  }
}
