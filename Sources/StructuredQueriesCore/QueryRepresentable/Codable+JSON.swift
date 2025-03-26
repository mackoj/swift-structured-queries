import Foundation

public protocol StaticCodable: Codable, Sendable {
  static var jsonDecoder: JSONDecoder { get }
  static var jsonEncoder: JSONEncoder { get }
}

extension StaticCodable {
  public static var jsonDecoder: JSONDecoder { JSONDecoder() }
  public static var jsonEncoder: JSONEncoder { JSONEncoder() }
}

// TODO: Figure out 'JSONBRepresentation'?

public struct JSONRepresentation<QueryOutput: StaticCodable>: QueryRepresentable {
  public var queryOutput: QueryOutput

  public init(queryOutput: QueryOutput) {
    self.queryOutput = queryOutput
  }

  public init(decoder: inout some QueryDecoder) throws {
    self.init(
      queryOutput: try QueryOutput.jsonDecoder.decode(
        QueryOutput.self,
        from: Data(String(decoder: &decoder).utf8)
      )
    )
  }
}

extension JSONRepresentation: QueryBindable {
  public var queryBinding: QueryBinding {
    do {
      return try .text(String(decoding: QueryOutput.jsonEncoder.encode(queryOutput), as: UTF8.self))
    } catch {
      return .invalid(error)
    }
  }
}

extension JSONRepresentation: SQLiteType {
  public static var typeAffinity: SQLiteTypeAffinity {
    String.typeAffinity
  }
}
