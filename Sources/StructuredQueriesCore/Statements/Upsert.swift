extension Table {
  public static func upsert(
    _ draft: Self.Draft
  ) -> Insert<Self, Self.Draft, Void, Void> where Self: PrimaryKeyedTable {
    var record = Record<Self>()
    for column in Self.Draft.columns.allColumns where column.name != columns.primaryKey.name {
      record.updates.append((column, draft[keyPath: column.keyPath] as! any QueryExpression))
    }
    return Insert<Self, Self.Draft, Void, Void>(
      input: (),
      conflictResolution: nil,
      columns: columns.allColumns,
      form: .drafts([draft]),
      record: record
    )
  }
}
