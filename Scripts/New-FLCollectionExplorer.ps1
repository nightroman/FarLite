
function New-FLCollectionExplorer($ConnectionString, $CollectionName) {
	New-Object PowerShellFar.ObjectExplorer -Property @{
		Data = @{
			ConnectionString = $ConnectionString
			CollectionName = $CollectionName
		}
		FileComparer = [PowerShellFar.FileMetaComparer]'_id'
		AsCreateFile = {FLCollectionExplorer_AsCreateFile @args}
		AsCreatePanel = {FLCollectionExplorer_AsCreatePanel @args}
		AsDeleteFiles = {FLCollectionExplorer_AsDeleteFiles @args}
		AsGetContent = {FLCollectionExplorer_AsGetContent @args}
		AsGetData = {FLCollectionExplorer_AsGetData @args}
		AsSetText = {FLCollectionExplorer_AsSetText @args}
	}
}

function FLCollectionExplorer_AsCreatePanel($1) {
	$panel = [PowerShellFar.ObjectPanel]$1
	$title = $1.Data.CollectionName

	$panel.Title = $title
	$panel.PageLimit = 1000

	$1.Data.Panel = $panel
	$panel
}

function FLCollectionExplorer_EditorOpened {
	$this.add_KeyDown({
		if ($_.Key.KeyDown -and $_.Key.Is([FarNet.KeyCode]::F4)) {
			$_.Ignore = $true
			Edit-LiteJsonLine
		}
	})
}

function FLCollectionExplorer_AsCreateFile($1, $2) {
	# edit new json
	$json = ''
	for() {
		$arg = New-Object FarNet.EditTextArgs -Property @{
			Title = 'New document (JSON)'
			Extension = 'js'
			Text = $json
			EditorOpened = {FLCollectionExplorer_EditorOpened}
		}
		$json = $Far.AnyEditor.EditText($arg)
		if (!$json) {
			return
		}
		try {
			$new = [Ldbc.Dictionary]::FromJson($json)
			break
		}
		catch {
			Show-FarMessage $_
		}
	}

	# _id to post
	$new.EnsureId()

	# add document
	try {
		Use-LiteDatabase $1.Data.ConnectionString {
			$collection = Get-LiteCollection $1.Data.CollectionName
			Add-LiteData $collection $new
		}
	}
	catch {
		Show-FarMessage $_
		return
	}

	# post dummy file with _id
	$2.PostFile = New-FarFile -Data ([PSCustomObject]@{_id = $new._id})
	$1.Data.Panel.NeedsNewFiles = $true
}

function FLCollectionExplorer_AsDeleteFiles($1, $2) {
	# ask
	if ($2.UI) {
		$text = "$($2.Files.Count) documents(s)"
		if (Show-FarMessage $text Delete YesNo) {return}
	}
	# remove
	try {
		Use-LiteDatabase $1.Data.ConnectionString {
			$collection = Get-LiteCollection $1.Data.CollectionName
			foreach($doc in $2.FilesData) {
				Remove-LiteData $collection '$._id = @_id', @{_id = $doc._id}
			}
		}
	}
	catch {
		$2.Result = 'Incomplete'
		if ($2.UI) {Show-FarMessage "$_"}
	}
	$1.Data.Panel.NeedsNewFiles = $true
}

function FLCollectionExplorer_AsGetContent($1, $2) {
	$id = $2.File.Data._id
	$doc = Use-LiteDatabase $1.Data.ConnectionString {
		$collection = Get-LiteCollection $1.Data.CollectionName
		Get-LiteData $collection '$._id = @_id', @{_id = $id}
	}

	$2.UseText = $doc.Print()
	$2.UseFileExtension = 'js'
	$2.CanSet = $true
	$2.EditorOpened = {FLCollectionExplorer_EditorOpened}
}

function FLCollectionExplorer_AsGetData($1, $2) {
	if ($2.NewFiles -or !$1.Cache) {
		Use-LiteDatabase $1.Data.ConnectionString {
			$collection = Get-LiteCollection $1.Data.CollectionName
			Get-LiteData $collection -First $2.Limit -Skip $2.Offset -As PS
		}
	}
	else {
		, $1.Cache
	}
}

function FLCollectionExplorer_AsSetText($1, $2) {
	$new = [Ldbc.Dictionary]::FromJson($2.Text)
	$new.EnsureId()

	try {
		Use-LiteDatabase $1.Data.ConnectionString {
			$collection = Get-LiteCollection $1.Data.CollectionName
			Set-LiteData $collection $new -Add
		}
	}
	catch {
		Show-FarMessage $_
		return
	}

	$1.Cache.Clear()
	$Far.Panel.Update($true)
}
