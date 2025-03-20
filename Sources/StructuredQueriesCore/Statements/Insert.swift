extension Table {
  public static func insert(
    or conflictResolution: ConflictResolution? = nil,
    _ row: Self,
    onConflict updates: ((inout Record<Self>) -> Void)? = nil
  ) -> Insert<Self, ()> {
    insert(or: conflictResolution, [row], onConflict: updates)
  }

  public static func insert(
    or conflictResolution: ConflictResolution? = nil,
    _ rows: [Self],
    onConflict updates: ((inout Record<Self>) -> Void)? = nil
  ) -> Insert<Self, ()> {
    insert(
      or: conflictResolution,
      values: {
        for row in rows {
          row
        }
      },
      onConflict: updates
    )
  }

  public static func insert(
    or conflictResolution: ConflictResolution? = nil,
    _ columns: (TableColumns) -> (TableColumns) = { $0 },
    @InsertValuesBuilder<Self>
    values rows: () -> [Self],
    onConflict updates: ((inout Record<Self>) -> Void)? = nil
  ) -> Insert<Self, ()> {
    var columnNames: [String] = []
    for column in Self.columns.allColumns {
      columnNames.append(column.name)
    }
    var values: [[QueryFragment]] = []
    for row in rows() {
      var value: [QueryFragment] = []
      for column in Self.columns.allColumns {
        func open<Root, Value>(_ column: some TableColumnExpression<Root, Value>) -> QueryFragment {
          Value(queryOutput: (row as! Root)[keyPath: column.keyPath]).queryFragment
        }
        value.append(open(column))
      }
      values.append(value)
    }
    let record = updates.map { updates in
      var record = Record<Self>()
      updates(&record)
      return record
    }
    return Insert(
      conflictResolution: conflictResolution,
      columnNames: columnNames,
      values: .values(values),
      record: record,
      returning: []
    )
  }

  public static func insert<V1: QueryBindable, each V2: QueryBindable>(
    or conflictResolution: ConflictResolution? = nil,
    _ columns: (TableColumns) -> (TableColumn<Self, V1>, repeat TableColumn<Self, each V2>),
    @InsertValuesBuilder<(V1.QueryOutput, repeat (each V2).QueryOutput)>
    values rows: () -> [(V1.QueryOutput, repeat (each V2).QueryOutput)],
    onConflict updates: ((inout Record<Self>) -> Void)? = nil
  ) -> Insert<Self, ()> {
    _insert(
      or: conflictResolution,
      columns,
      values: rows,
      onConflict: updates
    )
  }

  private static func _insert<each Value: QueryBindable>(
    or conflictResolution: ConflictResolution? = nil,
    _ columns: (TableColumns) -> (repeat TableColumn<Self, each Value>),
    @InsertValuesBuilder<(repeat (each Value).QueryOutput)>
    values rows: () -> [(repeat (each Value).QueryOutput)],
    onConflict updates: ((inout Record<Self>) -> Void)? = nil
  ) -> Insert<Self, ()> {
    var columnNames: [String] = []
    for column in repeat each columns(Self.columns) {
      columnNames.append(column.name)
    }
    var values: [[QueryFragment]] = []
    for row in rows() {
      var value: [QueryFragment] = []
      for (columnType, column) in repeat ((each Value).self, each row) {
        value.append("\(columnType.init(queryOutput: column).queryFragment)")
      }
      values.append(value)
    }
    let record = updates.map { updates in
      var record = Record<Self>()
      updates(&record)
      return record
    }
    return Insert(
      conflictResolution: conflictResolution,
      columnNames: columnNames,
      values: .values(values),
      record: record,
      returning: []
    )
  }

  public static func insert<
    V1: QueryBindable,
    each V2: QueryBindable,
    C1: QueryExpression<V1>,
    each C2: QueryExpression,
    From,
    Joins
  >(
    or conflictResolution: ConflictResolution? = nil,
    _ columns: (TableColumns) -> (TableColumn<Self, V1>, repeat TableColumn<Self, each V2>),
    select selection: () -> Select<(C1, repeat each C2), From, Joins>,
    onConflict updates: ((inout Record<Self>) -> Void)? = nil
  ) -> Insert<Self, ()>
  where (repeat (each C2).QueryValue) == (repeat each V2) {
    _insert(
      or: conflictResolution,
      columns,
      select: selection,
      onConflict: updates
    )
  }

  private static func _insert<
    each Value: QueryBindable,
    each ResultColumn: QueryExpression,
    From,
    Joins
  >(
    or conflictResolution: ConflictResolution? = nil,
    _ columns: (TableColumns) -> (repeat TableColumn<Self, each Value>),
    select selection: () -> Select<(repeat each ResultColumn), From, Joins>,
    onConflict updates: ((inout Record<Self>) -> Void)? = nil
  ) -> Insert<Self, ()>
  where (repeat (each ResultColumn).QueryValue) == (repeat each Value) {
    var columnNames: [String] = []
    for column in repeat each columns(Self.columns) {
      columnNames.append(column.name)
    }
    let record = updates.map { updates in
      var record = Record<Self>()
      updates(&record)
      return record
    }
    return Insert(
      conflictResolution: conflictResolution,
      columnNames: columnNames,
      values: .select(selection().queryFragment),
      record: record,
      returning: []
    )
  }

  public static func insert(
    or conflictResolution: ConflictResolution? = nil,
    onConflict updates: ((inout Record<Self>) -> Void)? = nil
  ) -> Insert<Self, ()> {
    let record = updates.map { updates in
      var record = Record<Self>()
      updates(&record)
      return record
    }
    return Insert(
      conflictResolution: conflictResolution,
      columnNames: [],
      values: .default,
      record: record,
      returning: []
    )
  }
}

extension PrimaryKeyedTable {
  public static func insert(
    or conflictResolution: ConflictResolution? = nil,
    _ row: Draft,
    onConflict updates: ((inout Record<Self>) -> Void)? = nil
  ) -> Insert<Self, ()> {
    Self.insert(
      or: conflictResolution,
      [row],
      onConflict: updates
    )
  }

  public static func insert(
    or conflictResolution: ConflictResolution? = nil,
    _ rows: [Draft],
    onConflict updates: ((inout Record<Self>) -> Void)? = nil
  ) -> Insert<Self, ()> {
    Self.insert(
      or: conflictResolution,
      values: {
        for row in rows {
          row
        }
      },
      onConflict: updates
    )
  }

  public static func insert(
    or conflictResolution: ConflictResolution? = nil,
    _ columns: (Draft.TableColumns) -> (Draft.TableColumns) = { $0 },
    @InsertValuesBuilder<Draft>
    values rows: () -> [Draft],
    onConflict updates: ((inout Record<Self>) -> Void)? = nil
  ) -> Insert<Self, ()> {
    var columnNames: [String] = []
    for column in Draft.columns.allColumns {
      columnNames.append(column.name)
    }
    var values: [[QueryFragment]] = []
    for row in rows() {
      var value: [QueryFragment] = []
      for column in Draft.columns.allColumns {
        func open<Root, Value>(_ column: some TableColumnExpression<Root, Value>) -> QueryFragment {
          Value(queryOutput: (row as! Root)[keyPath: column.keyPath]).queryFragment
        }
        value.append(open(column))
      }
      values.append(value)
    }
    let record = updates.map { updates in
      var record = Record<Self>()
      updates(&record)
      return record
    }
    return Insert(
      conflictResolution: conflictResolution,
      columnNames: columnNames,
      values: .values(values),
      record: record,
      returning: []
    )
  }
}

public struct Insert<Into: Table, Returning> {
  var conflictResolution: ConflictResolution?
  var columnNames: [String] = []
  var values: Values
  var record: Record<Into>?
  var returning: [QueryFragment] = []

  public func returning<each ResultColumn: QueryExpression>(
    _ selection: (Into.TableColumns) -> (repeat each ResultColumn)
  ) -> Insert<Into, (repeat (each ResultColumn).QueryValue)>
  where repeat (each ResultColumn).QueryValue: QueryDecodable {
    Insert<Into, (repeat (each ResultColumn).QueryValue)>(
      conflictResolution: conflictResolution,
      columnNames: columnNames,
      values: values,
      record: record,
      returning: Array(repeat each selection(Into.columns))
    )
  }
}

enum Values {
  case `default`
  case values([[QueryFragment]])
  case select(QueryFragment)
}

extension Insert: Statement {
  public typealias QueryValue = Returning
  public typealias From = Into

  public var query: QueryFragment {
    var query: QueryFragment = "INSERT"
    if let conflictResolution {
      query.append(" OR \(raw: conflictResolution.rawValue)")
    }
    query.append(" INTO \(Into.self)")
    if !columnNames.isEmpty {
      query.append(" (\(columnNames.map { "\(quote: $0)" }.joined(separator: ", ")))")
    }
    switch values {
    case .default:
      query.append(" DEFAULT VALUES")

    case let .select(select):
      query.append(" \(select)")

    case .values(let values):
      guard !values.isEmpty else { return "" }
      query.append(" VALUES ")
      let values: [QueryFragment] = values.map {
        var value: QueryFragment = "("
        value.append($0.joined(separator: ", "))
        value.append(")")
        return value
      }
      query.append(values.joined(separator: ", "))
    }

    if let record {
      query.append(
        " ON CONFLICT DO \(record.updates.isEmpty ? "NOTHING" : "UPDATE \(bind: record)")"
      )
    }
    if !returning.isEmpty {
      query.append(" RETURNING \(returning.joined(separator: ", "))")
    }
    return query
  }
}

public typealias InsertOf<Into: Table> = Insert<Into, ()>

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
