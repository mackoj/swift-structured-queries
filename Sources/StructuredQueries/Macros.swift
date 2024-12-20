@attached(
  extension,
  conformances: Table,
  names: named(Columns),
  named(columns),
  named(name),
  named(init(decoder:))
)
public macro Table() =
  #externalMacro(
    module: "StructuredQueriesMacros", type: "TableMacro"
  )

@Table
private struct SyncUp: Equatable {
  var id: Int
  var isActive: Bool
  var title: String
}

@Table
private struct Attendee: Equatable {
  var id: Int
  var name: String
  var syncUpID: Int
}
