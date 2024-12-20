// TODO: Should 'insert' really be a builder?
//       Pros:
//         - Can chain them together to build up a query:
//           ```
//           SyncUp
//             .insert { ($0.title, $0.isActive ) }
//             .values { ("Engineering", true) }
//             .values { ("Product", false) }
//
//       Cons:
//         - Can generate invalid queries:
//           ```
//           SyncUp
//             .insert()                            // DEFAULT VALUES
//             .onConflict { $0.title += " Copy" }  // Upsert not supported for DEFAULT VALUES

extension Table {
  public static func insert<each C: ColumnExpression>(
    or conflictResolution: ConflictResolution? = nil,
    _ columns: (Columns) -> (repeat each C)
  ) -> Insert<Self, (repeat each C), Void> {
    let input = columns(Self.columns)
    var columns: [any ColumnExpression] = []
    for column in repeat each input {
      columns.append(column)
    }
    return Insert(input: input, conflictResolution: conflictResolution, columns: columns)
  }

  // NB: Overload required to work around bug with parameter packs and result builders.
  public static func insert<C: ColumnExpression>(
    or conflictResolution: ConflictResolution? = nil,
    _ columns: (Columns) -> C
  ) -> Insert<Self, C, Void> {
    let input = columns(Self.columns)
    return Insert(input: input, conflictResolution: conflictResolution, columns: [input])
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

  public func values<each C: ColumnExpression>(
    @InsertValuesBuilder _ values: () -> [(repeat (each C).Value)] = { [] }
  ) -> Self
  where Input == (repeat each C), repeat (each C).Value: QueryExpression {
    var rows: [[any QueryExpression]] = []
    if case let .values(values) = form {
      rows = values
    }
    rows.append(
      contentsOf: values().map {
        var row: [any QueryExpression] = []
        for column in repeat each $0 {
          row.append(column)
        }
        return row
      }
    )
    return Self(
      input: input,
      conflictResolution: conflictResolution,
      columns: columns,
      form: .values(rows),
      record: record
    )
  }

  // NB: Overload required to work around bug with parameter packs and result builders.
  public func values(
    @InsertValuesBuilder _ values: () -> [Input.Value] = { [] }
  ) -> Self
  where Input: ColumnExpression, Input.Value: QueryExpression {
    var rows: [[any QueryExpression]] = []
    if case let .values(values) = form {
      rows = values
    }
    rows.append(
      contentsOf: values().map {
        var row: [any QueryExpression] = []
        row.append($0)
        return row
      }
    )
    return Self(
      input: input,
      conflictResolution: conflictResolution,
      columns: columns,
      form: .values(rows),
      record: record
    )
  }

  public func select<I, each C: ColumnExpression>(
    _ selection: Select<I, (repeat (each C).Value)>
  ) -> Self
  where Input == (repeat each C) {
    var copy = self
    copy.form = .select(selection)
    return copy
  }

  // NB: Overload required to work around bug with parameter packs and result builders.
  public func select<I>(
    _ selection: Select<I, Input.Value>
  ) -> Self where Input: ColumnExpression {
    var copy = self
    copy.form = .select(selection)
    return copy
  }

  public func onConflict(do updates: (inout Record<Base>) -> Void) -> Self {
    var record = Record<Base>()
    updates(&record)
    var copy = self
    copy.record = record
    return copy
  }

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
      return """
        VALUES \(rows.map { "(\($0.map(\.queryString).joined(separator: ", ")))" }.joined(separator: ", "))
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
public enum InsertValuesBuilder {
  public static func buildArray<Value>(_ components: [[Value]]) -> [Value] {
    components.flatMap(\.self)
  }

  public static func buildBlock<Value>(_ components: Value...) -> [Value] {
    components
  }

  public static func buildEither<Value>(first component: [Value]) -> [Value] {
    component
  }

  public static func buildEither<Value>(second component: [Value]) -> [Value] {
    component
  }

  public static func buildLimitedAvailability<Value>(_ component: [Value]) -> [Value] {
    component
  }

  public static func buildOptional<Value>(_ component: [Value]?) -> [Value] {
    component ?? []
  }
}
