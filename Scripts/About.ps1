$ErrorActionPreference = 1
Import-Module Ldbc

. $PSScriptRoot\Edit-LiteJsonLine.ps1
. $PSScriptRoot\New-FLCollectionExplorer.ps1
. $PSScriptRoot\New-FLDatabaseExplorer.ps1
. $PSScriptRoot\Open-LitePanel.ps1

function Get-FLSourceCollection($Collection) {
	$Database = $Collection.Database
	$views = Get-LdbcCollection system.views

	$r = Get-LdbcData @{_id = $Collection.CollectionNamespace.FullName} -Collection $views
	if ($r) {
		Get-LdbcCollection $r.viewOn
	}
	else {
		$Collection
	}
}
