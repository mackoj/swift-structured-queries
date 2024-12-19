extension Table {
  public static func insert<each C: ColumnExpression>(
    or strategy: InsertionStrategy? = nil,
    _ columns: (Columns) -> (repeat each C)
  ) -> Insert<Self, (repeat each C), Void> {
    let input = columns(Self.columns)
    var columns: [any ColumnExpression] = []
    for column in repeat each input {
      columns.append(column)
    }
    return Insert(input: input, strategy: strategy, columns: columns)
  }

  public static func insert(
    or strategy: InsertionStrategy? = nil
  ) -> Insert<Self, Void, Void> {
    Insert(input: (), strategy: strategy)
  }
}

public struct Insert<Base: Table, Input: Sendable, Output> {
  fileprivate var input: Input
  fileprivate var strategy: InsertionStrategy?
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
      strategy: strategy,
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
      strategy: strategy,
      columns: columns,
      form: form,
      record: record,
      returning: ReturningClause(repeat each selection(Base.columns))
    )
  }
}

extension Insert: Statement {
  public typealias Value = [Output]
  public var sql: String {
    var sql = "INSERT"
    if let strategy {
      sql.append(" OR \(strategy.rawValue)")
    }
    sql.append(" INTO \(Base.name.quoted())")
    if !columns.isEmpty {
      sql.append(" (\(columns.map { $0.name.quoted() }.joined(separator: ", ")))")
    }
    sql.append(" \(form.sql)")
    if let record {
      sql.append(" ON CONFLICT DO \(record.updates.isEmpty ? "NOTHING" : "UPDATE \(record.sql)")")
    }
    if let returning {
      sql.append(" \(returning.sql)")
    }
    return sql
  }
  public var bindings: [QueryBinding] {
    var bindings = columns.flatMap(\.bindings)
    bindings.append(contentsOf: form.bindings)
    if let record {
      bindings.append(contentsOf: record.bindings)
    }
    if let returning {
      bindings.append(contentsOf: returning.bindings)
    }
    return bindings
  }
}

public enum InsertionStrategy: Sendable {
  case abort
  case fail
  case ignore
  case replace
  case rollback

  fileprivate var rawValue: String {
    switch self {
    case .abort: return "ABORT"
    case .fail: return "FAIL"
    case .ignore: return "IGNORE"
    case .replace: return "REPLACE"
    case .rollback: return "ROLLBACK"
    }
  }
}

private enum InsertionForm: QueryExpression {
  case defaultValues
  case values([[any QueryExpression]])
  case select(any Statement)

  typealias Value = Void
  var sql: String {
    switch self {
    case .defaultValues:
      return "DEFAULT VALUES"
    case let .values(rows):
      return """
        VALUES \(rows.map { "(\($0.map(\.sql).joined(separator: ", ")))" }.joined(separator: ", "))
        """
    case let .select(statement):
      return statement.sql
    }
  }
  var bindings: [QueryBinding] {
    switch self {
    case .defaultValues:
      return []
    case let .values(rows):
      return rows.flatMap { $0.flatMap(\.bindings) }
    case let .select(statement):
      return statement.bindings
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
