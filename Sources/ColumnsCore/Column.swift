public enum QueryBinding: Codable, Hashable, Sendable {
  case blob([UInt8])
  case double(Double)
  case int(Int64)
  case null
  case text(String)
}

protocol ColumnExpression<Root, Value> {
  associatedtype Root
  associatedtype Value
  var name: String  { get }
  var keyPath: PartialKeyPath<Root> { get }
  func encode(value: Value) -> QueryBinding // maybe throws?
  func decode(binding: QueryBinding) -> Value // throws
}

// Column<User, Bind<Date>>

struct Column<Root, Value /* : BindingConvertible */>: ColumnExpression {
  let name: String
  let keyPath: PartialKeyPath<Root>
  let encode: (Value) -> QueryBinding
  let decode: (QueryBinding) -> Value

//  init(
//    name: String,
//    keyPath: PartialKeyPath<Root>
//  ) where /* Value: QueryBindable */ {
//    self.name = name
//    self.keyPath = keyPath
//    self.encode = { $0 }
//    self.decode = { $0 }
//  }
//  init(
//    name: String,
//    keyPath: PartialKeyPath<Root>,
//    encode: @escaping (Value) -> QueryBinding,
//    decode: @escaping (QueryBinding) -> Value
//  ) where {
//    self.name = name
//    self.keyPath = keyPath
//    self.encode = encode
//    self.decode = decode
//  }

  func encode(value: Value) -> QueryBinding {
    encode(value)
  }
  func decode(binding: QueryBinding) -> Value {
    decode(binding)
  }
}

struct AnyColumnExpression<Root>: ColumnExpression {
  let base: any ColumnExpression
  let _name: () -> String
  let _keyPath: () -> PartialKeyPath<Root>
  let _encode: (Any) -> QueryBinding
  let _decode: (QueryBinding) -> Any
  typealias Value = Any

  init<Value>(_ base: any ColumnExpression<Root, Value>) {
    self.base = base
    _name = { base.name }
    _keyPath = { base.keyPath }
    _encode = { base.encode(value: $0 as! Value) }
    _decode = { base.decode(binding: $0) }
  }

  var name: String {
    _name()
  }
  var keyPath: PartialKeyPath<Root> {
    _keyPath()
  }
  func encode(value: Value) -> QueryBinding {
    _encode(value)
  }
  func decode(binding: QueryBinding) -> Value {
    _decode(binding)
  }
}

// struct CustomColumn

// $0.savedAt  $0.deletedAt
// $0.data.max(…)
//  

import Foundation

// @Table
struct User {
  var name: String
  // @Column("savedAt", as: .iso8601)
  var savedAt: Date

  // $0.saved == $1.deleted

  struct Columns {
    let name = Column<User, String>(
      name: "name",
      keyPath: \User.name,
      encode: { .text($0) },
      decode: { binding in
        guard case .text(let text) = binding else { fatalError() }
        return text
      }
    )
    let savedAt = Column<User, Date>(
      name: "savedAt",
      keyPath: \User.savedAt,
      encode: { _ in .text("todo: format as date") },
      decode: { binding in
        guard case .text(let text) = binding else { fatalError() }
        return Date() // todo: do formatting
      }
    )
  }
}
