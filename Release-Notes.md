# FarLite Release Notes

## v0.0.4

Collections panel - use `[F7]` to create new collections.

`Edit-LiteJsonLine` - also edit dates (local time, friendly format).

## v0.0.3

`Open-LitePanel` - new parameter `Parameters`.

## v0.0.2

Requires Ldbc 0.4.2

`Open-LitePanel` supports queries in addition to collection names using the
same parameter `Query`. If queried documents contain `_id` keys then documents
are edited and deleted as usual. Paging is not supported for query results but
queries may use `LIMIT` and `OFFSET` themselves.

## v0.0.1

Requires Ldbc 0.4.1
