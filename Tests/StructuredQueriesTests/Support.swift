import StructuredQueriesCore
import SnapshotTesting
import Testing

@Suite(.snapshots(record: .failed)) struct SnapshotTests {}

extension Snapshotting where Value: QueryExpression {
  static var sql: Snapshotting<Value, String> {
    SimplySnapshotting.lines.pullback(\.queryFragment.debugDescription)
  }
}
