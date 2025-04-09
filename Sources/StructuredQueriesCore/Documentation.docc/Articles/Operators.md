# Operators

## Overview

TODO

## Topics

### Equality

- ``QueryExpression/==(_:_:)``
- ``QueryExpression/!=(_:_:)``
- ``QueryExpression/is(_:)``
- ``QueryExpression/isNot(_:)``

### Logic

- ``QueryExpression/&&(_:_:)``
- ``QueryExpression/||(_:_:)``
- ``QueryExpression/!(_:)``
- ``QueryExpression/and(_:)``
- ``QueryExpression/or(_:)``
- ``QueryExpression/not()``
- ``SQLQueryExpression/toggle()``

### Comparison

- ``QueryExpression/<(_:_:)``
- ``QueryExpression/>(_:_:)``
- ``QueryExpression/<=(_:_:)``
- ``QueryExpression/>=(_:_:)``
- ``QueryExpression/lt(_:)``
- ``QueryExpression/gt(_:)``
- ``QueryExpression/lte(_:)``
- ``QueryExpression/gte(_:)``

### Math

- ``QueryExpression/+(_:_:)``
- ``QueryExpression/-(_:_:)``
- ``QueryExpression/*(_:_:)``
- ``QueryExpression//(_:_:)``
- ``QueryExpression/+(_:)``
- ``QueryExpression/-(_:)``
- ``SQLQueryExpression/+=(_:_:)``
- ``SQLQueryExpression/-=(_:_:)``
- ``SQLQueryExpression/*=(_:_:)``
- ``SQLQueryExpression//=(_:_:)``
- ``SQLQueryExpression/negate()``

### Bitwise

- ``QueryExpression/%(_:_:)``
- ``QueryExpression/&(_:_:)``
- ``QueryExpression/|(_:_:)``
- ``QueryExpression/<<(_:_:)``
- ``QueryExpression/>>(_:_:)``
- ``QueryExpression/~(_:)``
- ``SQLQueryExpression/&=(_:_:)``
- ``SQLQueryExpression/|=(_:_:)``
- ``SQLQueryExpression/<<=(_:_:)``
- ``SQLQueryExpression/>>=(_:_:)``

### String

- ``Collation``
- ``QueryExpression/collate(_:)``
- ``QueryExpression/+(_:_:)->QueryExpression<String>``
- ``QueryExpression/like(_:escape:)``
- ``QueryExpression/glob(_:)``
- ``QueryExpression/match(_:)``
- ``QueryExpression/hasPrefix(_:)``
- ``QueryExpression/hasSuffix(_:)``
- ``QueryExpression/contains(_:)``
- ``SQLQueryExpression/+=(_:_:)-(_,QueryExpression<String>)``
- ``SQLQueryExpression/append(_:)``
- ``SQLQueryExpression/append(contentsOf:)``

### Collection

- ``QueryExpression/in(_:)``
- ``Statement/contains(_:)``
- ``Swift/Array``
- ``Swift/ClosedRange``

### Casting

- ``QueryExpression/cast(as:)``
- ``SQLiteType``
- ``SQLiteTypeAffinity``
