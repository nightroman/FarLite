<#
.Synopsis
	Shows LiteDB collections and documents.

.Description
	This command opens a panel with LiteDB database collections and documents
	including nested documents and arrays. Root documents may be viewed and
	edited as JSON. Nested documents may not be edited directly.

	Paging. Large collections is not a problem. Documents are shown 1000/page.
	Press [PgDn]/[PgUp] at last/first panel items to show next/previous pages.

	KEYS AND ACTIONS

	[Del]
		Deletes selected documents and empty collections.
		For deleting not empty collections use [ShiftDel].

	[ShiftDel]
		Deletes selected collections and documents.

	[ShiftF6]
		Prompts for a new name and renames the current collection.

	[F4]
		Edits documents in the documents panel.
		It opens the editor with current document JSON.

	[F7]
		Creates new documents in the documents panel.
		It opens the modal editor for the new document JSON.

.Parameter ConnectionString
		Specifies the LiteDB connection string. If CollectionName is omitted
		then the panel shows collections.

.Parameter CollectionName
		Specifies the collection name and tells to show collection documents.

.Parameter System
		Tells to include system collections.

.Example
	># Browse all collections of "MyDatabase.LiteDB":
	Open-LitePanel MyDatabase.LiteDB -System

.Example
	># Browse documents of MyCollection of "MyDatabase.LiteDB":
	Open-LitePanel MyDatabase.LiteDB MyCollection
#>
function Open-LitePanel {
	[CmdletBinding()]
	param(
		[Parameter(Position=0, Mandatory=1)]
		[string]$ConnectionString
		,
		[Parameter(Position=1)]
		[string]$CollectionName
		,
		[switch]$System
	)

	trap {Write-Error -ErrorRecord $_}

	if ($CollectionName) {
		(New-FLCollectionExplorer $ConnectionString $CollectionName).OpenPanel()
	}
	else {
		(New-FLDatabaseExplorer $ConnectionString -System:$System).OpenPanel()
	}
}
