import SnapshotTesting
import StructuredQueries
import Testing

@MainActor @Suite(.serialized, .snapshots(record: .failed)) struct SnapshotTests {}

extension Snapshotting where Value: Statement {
  static var sql: Snapshotting<Value, String> {
    SimplySnapshotting.lines.pullback(\.query.debugDescription)
  }
}

extension Snapshotting where Value: QueryExpression {
  static var sql: Snapshotting<Value, String> {
    SimplySnapshotting.lines.pullback(\.queryFragment.debugDescription)
  }
}
