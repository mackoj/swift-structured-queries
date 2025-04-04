# ``StructuredQueriesCore/Table``

## Topics

### Query building

- ``all``
- ``distinct(_:)``
- ``select(_:)->Select<(C1.QueryValue,C2.QueryValue,(C3).QueryValue),Self,()>``
- ``join(_:on:)``
- ``leftJoin(_:on:)``
- ``rightJoin(_:on:)``
- ``fullJoin(_:on:)``
- ``where(_:)``
- ``group(by:)-((TableColumns)->(C1,C2,C3))``
- ``having(_:)``
- ``limit(_:offset:)-9wzx0``
- ``count()``
- ``insert(or:_:values:onConflict:)-83cf5``
- ``update(or:set:)``
- ``delete()``

### Schema definition

- ``tableName``
- ``columns-swift.type.property``
- ``TableColumns``
- ``TableColumn``
- ``TableDefinition``

### Primary keys

- ``PrimaryKeyedTable``
- ``PrimaryKeyedTableDefinition``
