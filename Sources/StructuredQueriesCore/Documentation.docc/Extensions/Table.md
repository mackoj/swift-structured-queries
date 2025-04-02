# ``StructuredQueriesCore/Table``

## Topics

### Query building

- ``all``
- ``distinct(_:)``
- ``select(_:)->Select<(C1.QueryValue,C2.QueryValue,(C3).QueryValue),Self,()>``
- ``join(_:on:)-6kvjn``
- ``leftJoin(_:on:)-97x2``
- ``rightJoin(_:on:)-42a9h``
- ``fullJoin(_:on:)-1kjun``
- ``where(_:)``
- ``group(by:)-((Columns)->(C1,C2,C3))``
- ``having(_:)``
- ``limit(_:offset:)-9wzx0``
- ``count()``
- ``insert(or:_:values:onConflict:)-83cf5``
- ``update(or:set:)``
- ``delete()``

### Schema definition

- ``tableName``
- ``columns-swift.type.property``
- ``Columns``
- ``Column``
- ``Schema``

### Primary keys

- ``PrimaryKeyedTable``
- ``PrimaryKeyedSchema``
