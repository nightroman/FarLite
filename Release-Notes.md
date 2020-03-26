# FarLite Release Notes

## v0.0.8

Recommended: use the latest Ldbc 0.7.2. It includes LiteDB 5.0.5 with corrected
non-Latin characters in JSON, e.g. important for representing Cyrillic strings.

Minor fixes of UI element texts.

## v0.0.7

`Open-LitePanel` - new parameter `Columns`.

## v0.0.6

Requires Ldbc 0.6.1

- Copy / Move documents from another FarLite panel.
- Edit `$date`, `$guid`, `$oid`.
- Amend create new collection.

## v0.0.5

Fix edit dates in `Edit-LiteJsonLine`.

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
