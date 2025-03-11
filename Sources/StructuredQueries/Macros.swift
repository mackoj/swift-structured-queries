@attached(
  extension,
  conformances: Table,
  PrimaryKeyedTable,
  names: named(Columns),
  named(Draft),
  named(columns),
  named(init(_:)),
  named(init(decoder:)),
  named(tableName)
)
@attached(
  memberAttribute
)
public macro Table(_ name: String? = nil) =
  #externalMacro(
    module: "StructuredQueriesMacros",
    type: "TableMacro"
  )

@attached(accessor, names: named(willSet))
public macro Column(
  _ name: String? = nil,
  as representableType: (any QueryRepresentable.Type)? = nil,
  primaryKey: Bool = false
) =
  #externalMacro(
    module: "StructuredQueriesMacros",
    type: "ColumnMacro"
  )

@attached(
  memberAttribute
)
@attached(
  extension,
  conformances: Table,
  names: named(Columns),
  named(columns),
  named(init(_:)),
  named(init(decoder:)),
  named(tableName)
)
public macro _Draft<T: Table>(_: T.Type) =
  #externalMacro(
    module: "StructuredQueriesMacros",
    type: "TableMacro"
  )



 import Foundation

 enum Priority: Int, QueryBindable {
   case high = 3
   case medium = 2
   case low = 1
 }

 @Table
 struct Reminder {
   let id: Int
   var title = ""
   @Column(as: Date.UnixTimeRepresentation?.self)
   var date: Date?
   var priority: Priority?
 }
