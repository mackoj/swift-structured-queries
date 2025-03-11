extension PrimaryKeyedTable {
  public static func upsert(
    _ row: Draft
  ) -> Insert<Self, ()> {
    insert(
      row,
      onConflict: { record in
        for column in Draft.columns.allColumns where column.name != columns.primaryKey.name {
          record.updates.append((column.name, "excluded.\(raw: column.name.quoted())"))
        }
      }
    )
  }
}
