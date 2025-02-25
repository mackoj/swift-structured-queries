@attached(
  extension,
  conformances: Table,
  PrimaryKeyedTable,
  names: named(Columns),
  named(Draft),
  named(columns),
  named(queryFragment),
  named(init(decoder:)),
  named(init(_:)),
  named(name)
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
public macro Column(_ name: String? = nil, primaryKey: Bool = false) =
  #externalMacro(
    module: "StructuredQueriesMacros",
    type: "ColumnMacro"
  )

@attached(accessor, names: named(willSet))
public macro Column<Strategy: QueryBindingStrategy>(
  _ name: String? = nil,
  as strategy: Strategy,
  primaryKey: Bool = false
) =
  #externalMacro(
    module: "StructuredQueriesMacros",
    type: "ColumnMacro"
  )

@attached(
  extension,
  conformances: QueryDecodable,
  names: named(Columns),
  named(init(decoder:))
)
public macro Selection() =
  #externalMacro(
    module: "StructuredQueriesMacros",
    type: "SelectionMacro"
  )

// 0. Table.Draft.id: ID?
// 1. Table.Draft.init(_: Table)
// 2. Table.init?(_: Table.Draft)
// 3. Table.upsert(_: Table.Draft)

//@Table
//struct A {
//  let id: Int
//  var name: String
//}

//@Table
//struct A2B {
//  let aID: Int
//  let bID: Int
//}
//
//@Table
//struct B {
//  let id: Int
//}
//
//func f() {
//  let _: SelectOf<A, A2B?, B?> = A.all()
//    .leftJoin(A2B.all()) { $0.id == $1.aID }
//    .leftJoin(B.all()) { $1.bID == $2.id }
//
//  let _: Select<_, (A?, A2B?, B)> = A.all()
//    .rightJoin(A2B.all()) { $0.id == $1.aID }
//    .rightJoin(B.all()) { $1.bID == $2.id }
//
//  let _: Select<_, (A?, A2B?, B?)> = A.all()
//    .fullJoin(A2B.all()) { $0.id == $1.aID }
//    .fullJoin(B.all()) { $1.bID == $2.id }
//}
