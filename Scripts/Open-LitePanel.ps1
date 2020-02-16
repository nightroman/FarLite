<#
.Synopsis
	Shows LiteDB collections and documents.

.Description
	This command opens a panel with LiteDB database collections or documents.
	Root documents may be viewed and edited as JSON if they have the _id key.
	Nested documents are not edited directly.

	Paging. Large collections is not a problem. Documents are shown 1000/page.
	Press [PgDn]/[PgUp] at last/first panel items to show next/previous pages.
	Paging is not used with queries, they may use LIMIT and OFFSET themselves.

	KEYS AND ACTIONS

	[Del]
		Deletes selected documents and empty collections.
		For deleting not empty collections use [ShiftDel].

	[ShiftDel]
		Deletes selected collections and documents.

	[ShiftF6]
		Prompts for a new name and renames the current collection.

	[F4]
		Edits the current document JSON and updates the document.

	[F7]
		Collections:
			Prompts for a collection name and creates a collection.
		Documents:
			Opens the editor for the new document JSON.

.Parameter ConnectionString
		Specifies the LiteDB connection string. If Query is omitted then the
		panel shows database collections. Use System in order to include the
		system collections.

.Parameter Query
		Specifies either the collection name or SQL SELECT command and tells to
		show collection or queried documents. Note that SELECT should use _id
		or $ in order to modify or delete result documents in the panel.

.Parameter Parameters
		Specifies query parameters, same as Parameters of Invoke-LiteCommand.

.Example
		>

# Browse "Test.LiteDB" collections
Open-LitePanel Test.LiteDB

# Browse all documents from "Log"
Open-LitePanel Test.LiteDB Log

# Browse filtered "Log" documents ordered by descending time
Open-LitePanel Test.LiteDB 'SELECT $ FROM Log WHERE $.date > @0 ORDER BY $.date DESC' ([DateTime]::Today)

.Link
	https://www.litedb.org/api/query/
#>

function Open-LitePanel {
	[CmdletBinding(DefaultParameterSetName='Database')]
	param(
		[Parameter(Position=0, Mandatory=1)]
		[string]$ConnectionString
		,
		[Parameter(ParameterSetName='Query', Position=1, Mandatory=1)]
		[string]$Query
		,
		[Parameter(ParameterSetName='Query', Position=2)]
		[object]$Parameters
		,
		[Parameter(ParameterSetName='Database')]
		[switch]$System
	)

	trap {Write-Error -ErrorRecord $_}

	if ($Query) {
		(New-FLDocumentsExplorer $ConnectionString $Query $Parameters).OpenPanel()
	}
	else {
		(New-FLCollectionsExplorer $ConnectionString -System:$System).OpenPanel()
	}
}
