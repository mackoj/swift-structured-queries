@attached(
  extension,
  conformances: Table,
  names: named(Columns),
  named(columns),
  named(name),
  named(init(decoder:))
)
@attached(
  memberAttribute
)
public macro Table(_ name: String? = nil) =
  #externalMacro(
    module: "StructuredQueriesMacros", type: "TableMacro"
  )

@attached(accessor, names: named(willSet))
public macro Column(_ name: String? = nil) =
  #externalMacro(
    module: "StructuredQueriesMacros", type: "ColumnMacro"
  )

@attached(accessor, names: named(willSet))
public macro Column<Strategy: QueryBindingStrategy>(_ name: String? = nil, as strategy: Strategy) =
  #externalMacro(
    module: "StructuredQueriesMacros", type: "ColumnMacro"
  )
