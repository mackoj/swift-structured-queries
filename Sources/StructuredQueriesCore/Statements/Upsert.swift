extension PrimaryKeyedTable {
  public static func upsert(
    _ row: Draft
  ) -> Insert<Self, ()> {
    insert(
      row,
      onConflict: { record in
        for column in Draft.TableColumns.allColumns where column.name != columns.primaryKey.name {
          record.updates.append((column.name, #""excluded".\#(quote: column.name)"#))
        }
      }
    )
  }
}
