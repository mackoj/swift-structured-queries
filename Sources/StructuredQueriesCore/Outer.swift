@dynamicMemberLookup
public struct Outer<Base>: _OptionalPromotable, _OptionalProtocol {
  let base: Base?  // TODO: Should this be 'Base._Optionalized'?

  public subscript<Member>(dynamicMember keyPath: KeyPath<Base, Member>) -> Outer<Member> {
    guard let base else { return Outer<Member>(base: nil) }
    return Outer<Member>(base: base[keyPath: keyPath])
  }

  fileprivate subscript<Member: QueryRepresentable>(
    member _: KeyPath<Member, Member> & Sendable,
    column keyPath: KeyPath<Base, Member.QueryOutput> & Sendable
  ) -> Outer<Member>.QueryOutput {
    guard let base else { return nil }
    return base[keyPath: keyPath]
  }

  public var _wrapped: Base? { base }
}

extension Outer: QueryExpression where Base: QueryExpression {
  public typealias QueryValue = Base.QueryValue?

  public var queryFragment: QueryFragment {
    base?.queryFragment ?? QueryFragment("?", [.null])
  }
}

extension Outer: QueryBindable where Base: QueryBindable {
  public var queryBinding: QueryBinding {
    base?.queryBinding ?? .null
  }
}

extension Outer: QueryDecodable where Base: QueryDecodable {
  public init(decoder: some QueryDecoder) throws {
    self.init(base: try decoder.decode(Base?.self))
  }
}

extension Outer: QueryRepresentable where Base: QueryRepresentable {
  public typealias QueryOutput = Base.QueryOutput?

  public init(queryOutput: Base.QueryOutput?) {
    self.init(base: queryOutput.map(Base.init(queryOutput:)))
  }

  public var queryOutput: Base.QueryOutput? {
    base?.queryOutput
  }
}

extension Outer: Sendable where Base: Sendable {}

extension Outer: Table where Base: Table {
  public static var tableName: String {
    Base.tableName
  }

  public static var columns: Columns {
    Columns()
  }

  @dynamicMemberLookup
  public struct Columns: Schema {
    public var allColumns: [any ColumnExpression] {
      Base.columns.allColumns
    }

    public typealias QueryValue = Outer

    public subscript<Member>(
      dynamicMember keyPath: KeyPath<Base.Columns, Column<Base, Member>>
    ) -> Column<Outer<Base>, Outer<Member>> {
      let column = Base.columns[keyPath: keyPath]
      return Column(
        column.name,
        keyPath: \Outer<Base>.[member: \Member.self, column: column._keyPath]
      )
    }
  }
}
