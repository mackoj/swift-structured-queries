extension Table {
  public static func insert<each C: ColumnExpression>(
    or conflictResolution: ConflictResolution? = nil,
    _ columns: (Columns) -> (repeat each C),
    @InsertValuesBuilder<(repeat (each C).QueryOutput)> values: () -> [(repeat (each C).QueryOutput)],
    onConflict updates: ((inout Record<Self>) -> Void)? = nil
  ) -> Insert<Self, Never, (repeat each C), Void>
  where repeat (each C).QueryOutput: QueryExpression {
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
    @InsertValuesBuilder<C.QueryOutput> values: () -> [C.QueryOutput],
    onConflict updates: ((inout Record<Self>) -> Void)? = nil
  ) -> Insert<Self, Never, C, Void>
  where C.QueryOutput: QueryExpression {
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
    select selection: () -> Select<I, (repeat (each C).QueryOutput)>,
    onConflict updates: ((inout Record<Self>) -> Void)? = nil
  ) -> Insert<Self, Never, (repeat each C), Void>
  where repeat (each C).QueryOutput: QueryExpression {
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
    select selection: () -> Select<I, C.QueryOutput>,
    onConflict updates: ((inout Record<Self>) -> Void)? = nil
  ) -> Insert<Self, Never, C, Void>
  where C.QueryOutput: QueryExpression {
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
    or conflictResolution: ConflictResolution? = nil,
    _ records: [Self]
  ) -> Insert<Self, Never, Void, Void> {
    Insert(
      input: (),
      conflictResolution: conflictResolution,
      columns: columns.allColumns,
      form: .records(records)
    )
  }

  public static func insert(
    or conflictResolution: ConflictResolution? = nil
  ) -> Insert<Self, Never, Void, Void> {
    Insert(input: (), conflictResolution: conflictResolution)
  }

  @_disfavoredOverload
  public static func insert(
    or conflictResolution: ConflictResolution? = nil,
    _ drafts: [Self.Draft]
  ) -> Insert<Self, Self.Draft, Void, Void> where Self: PrimaryKeyedTable {
    Insert(
      input: (),
      conflictResolution: conflictResolution,
      columns: Self.Draft.columns.allColumns,
      form: .drafts(drafts)
    )
  }
}

public struct Insert<Base: Table, Draft: StructuredQueriesCore.Draft, Input: Sendable, Output> {
  fileprivate var input: Input
  fileprivate var conflictResolution: ConflictResolution?
  fileprivate var columns: [any ColumnExpression] = []
  fileprivate var form: InsertionForm<Base, Draft> = .defaultValues
  fileprivate var record: Record<Base>?
  fileprivate var returning: ReturningClause?

  public func returning<each O: QueryExpression>(
    _ selection: (Base.Columns) -> (repeat each O)
  ) -> Insert<Base, Draft, Input, (repeat (each O).QueryOutput)>
  where repeat (each O).QueryOutput: QueryDecodable {
    Insert<Base, Draft, Input, (repeat (each O).QueryOutput)>(
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
  public typealias QueryOutput = [Output]
  public var queryFragment: QueryFragment {
    let form = form.queryFragment
    guard !form.isEmpty else { return "" }
    var sql: QueryFragment = "INSERT"
    if let conflictResolution {
      sql.append(" OR \(bind: conflictResolution)")
    }
    sql.append(" INTO \(raw: Base.name.quoted())")
    if !columns.isEmpty {
      sql.append(" (\(columns.map { "\(raw: $0.name.quoted())" }.joined(separator: ", ")))")
    }
    sql.append(" \(form)")
    if let record {
      sql.append(
        " ON CONFLICT DO \(record.updates.isEmpty ? "NOTHING" : "UPDATE \(bind: record)")")
    }
    if let returning {
      sql.append(" \(bind: returning)")
    }
    return sql
  }
}

private enum InsertionForm<Base: Table, Draft: StructuredQueriesCore.Draft>: QueryExpression {
  case defaultValues
  case values([[any QueryExpression]])
  case select(any Statement)
  case records([Base])
  case drafts([Draft])

  typealias QueryOutput = Void
  var queryFragment: QueryFragment {
    switch self {
    case .defaultValues:
      return "DEFAULT VALUES"
    case let .values(rows):
      let values: QueryFragment =
        rows
        .map { "(\($0.map(\.queryFragment).joined(separator: ", ")))" }
        .joined(separator: ", ")
      return """
        VALUES \(values)
        """
    case let .select(statement):
      return statement.queryFragment
    case let .records(records):
      guard !records.isEmpty else { return "" }
      let values: QueryFragment = records
        .map { record in
          let row = Base.columns.allColumns.map { column in
            (record[keyPath: column.keyPath] as! any QueryBindable).queryFragment
          }
          .joined(separator: ", ")
          return "(\(row))"
        }
        .joined(separator: ", ")
      return """
        VALUES \(values)
        """
    case let .drafts(records):
      guard !records.isEmpty else { return "" }
      let values: QueryFragment = records
        .map { record in
          let row = Draft.columns.allColumns.map { column in
            (record[keyPath: column.keyPath] as! any QueryBindable).queryFragment
          }
          .joined(separator: ", ")
          return "(\(row))"
        }
        .joined(separator: ", ")
      return """
        VALUES \(values)
        """
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
