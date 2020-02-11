
function New-FLDatabaseExplorer($ConnectionString, [switch]$System) {
	New-Object PowerShellFar.PowerExplorer 2c77b1ed-c496-4823-9792-2e417a8c83a9 -Property @{
		Data = @{
			ConnectionString = $ConnectionString
			System = $System
		}
		Functions = 'DeleteFiles, RenameFile'
		AsCreatePanel = {FLDatabaseExplorer_AsCreatePanel @args}
		AsDeleteFiles = {FLDatabaseExplorer_AsDeleteFiles @args}
		AsExploreDirectory = {FLDatabaseExplorer_AsExploreDirectory @args}
		AsGetFiles = {FLDatabaseExplorer_AsGetFiles @args}
		AsRenameFile = {FLDatabaseExplorer_AsRenameFile @args}
	}
}

function FLDatabaseExplorer_AsCreatePanel {
	param($1)
	$panel = [FarNet.Panel]$1
	$panel.Title = 'Collections'
	$panel.ViewMode = 0
	$panel.SetPlan(0, (New-Object FarNet.PanelPlan))
	$panel
}

function FLDatabaseExplorer_AsGetFiles($1) {
	Use-LiteDatabase $1.Data.ConnectionString {
		if ($1.Data.System) {
			foreach($r in Invoke-LiteCommand 'SELECT $.name FROM $cols') {
				New-FarFile -Name $r.name -Attributes Directory
			}
		}
		else {
			foreach($name in $Database.GetCollectionNames()) {
				New-FarFile -Name $name -Attributes Directory
			}
		}
	}
}

function FLDatabaseExplorer_AsExploreDirectory($1, $2) {
	New-FLCollectionExplorer $1.Data.ConnectionString $2.File.Name
}

function FLDatabaseExplorer_AsRenameFile($1, $2) {
	$newName = ([string]$Far.Input('New name', $null, 'Rename', $2.File.Name)).Trim()
	if (!$newName) {return}
	Use-LiteDatabase $1.Data.ConnectionString {
		$Database.RenameCollection($2.File.Name, $newName)
	}
	$2.PostName = $newName
}

function FLDatabaseExplorer_AsDeleteFiles($1, $2) {
	# ask
	if ($2.UI) {
		$text = @"
$($2.Files.Count) collection(s):
$($2.Files[0..9] -join "`n")
"@
		if (Show-FarMessage $text Delete YesNo -LeftAligned) {return}
	}
	# drop
	Use-LiteDatabase $1.Data.ConnectionString {
		foreach($file in $2.Files) {
			try {
				if (!$2.Force) {
					$collection = Get-LiteCollection $file.Name
					if ($collection.Count()) {
						throw "Collection '$($file.Name)' is not empty."
					}
				}
				$null = $Database.DropCollection($file.Name)
			}
			catch {
				$2.Result = 'Incomplete'
				$2.FilesToStay.Add($file)
				if ($2.UI) {Show-FarMessage "$_"}
			}
		}
	}
}
