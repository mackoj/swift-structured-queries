@attached(
  extension,
  conformances: Table, PrimaryKeyedTable,
  names: named(Columns), named(Draft), named(columns), named(init(decoder:)), named(name)
)
@attached(
  memberAttribute
)
public macro Table(_ name: String? = nil) =
  #externalMacro(
    module: "StructuredQueriesMacros", type: "TableMacro"
  )

@attached(accessor, names: named(willSet))
public macro Column(_ name: String? = nil, primaryKey: Bool = false) =
  #externalMacro(
    module: "StructuredQueriesMacros", type: "ColumnMacro"
  )

@attached(accessor, names: named(willSet))
public macro Column<Strategy: QueryBindingStrategy>(
  _ name: String? = nil,
  as strategy: Strategy,
  primaryKey: Bool = false
) =
  #externalMacro(
    module: "StructuredQueriesMacros", type: "ColumnMacro"
  )

@attached(
  extension,
  conformances: QueryDecodable,
  names: named(Columns),
  named(init(decoder:))
)
public macro Selection() =
#externalMacro(
  module: "StructuredQueriesMacros", type: "SelectionMacro"
)
