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

