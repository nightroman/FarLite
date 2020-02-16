
function New-FLDocumentsExplorer($ConnectionString, $Query, $Parameters) {
	$Query = $Query.Trim()
	if ($Query -match '^\S+$') {
		$CollectionName = $Query
		$Query = $null
	}
	else {
		$CollectionName = $null
	}
	New-Object PowerShellFar.ObjectExplorer -Property @{
		Data = @{
			ConnectionString = $ConnectionString
			CollectionName = $CollectionName
			Query = $Query
			Parameters = $Parameters
		}
		FileComparer = [PowerShellFar.FileMetaComparer]'_id'
		AsCreateFile = {FLDocumentsExplorer_AsCreateFile @args}
		AsCreatePanel = {FLDocumentsExplorer_AsCreatePanel @args}
		AsDeleteFiles = {FLDocumentsExplorer_AsDeleteFiles @args}
		AsGetContent = {FLDocumentsExplorer_AsGetContent @args}
		AsGetData = {FLDocumentsExplorer_AsGetData @args}
		AsSetText = {FLDocumentsExplorer_AsSetText @args}
	}
}

function FLDocumentsExplorer_AsCreatePanel($1) {
	$panel = [PowerShellFar.ObjectPanel]$1
	if ($1.Data.Query) {
		$title = $1.Data.Query
	}
	else {
		$title = $1.Data.CollectionName
		$panel.PageLimit = 1000
	}
	$panel.Title = $title
	$1.Data.Panel = $panel
	$panel
}

function FLDocumentsExplorer_EditorOpened {
	$this.add_KeyDown({
		if ($_.Key.KeyDown -and $_.Key.Is([FarNet.KeyCode]::F4)) {
			$_.Ignore = $true
			try {
				Edit-LiteJsonLine
			}
			catch {
				Show-FarMessage $_ FarLite
			}
		}
	})
}

function FLDocumentsExplorer_AsCreateFile($1, $2) {
	# edit new json
	$json = ''
	for() {
		$arg = New-Object FarNet.EditTextArgs -Property @{
			Title = 'New document (JSON)'
			Extension = 'js'
			Text = $json
			EditorOpened = {FLDocumentsExplorer_EditorOpened}
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

function FLDocumentsExplorer_AsDeleteFiles($1, $2) {
	# check _id
	try {
		foreach($doc in $2.FilesData) {
			if ($null -eq $doc._id) {
				throw 'Cannot edit documents without _id'
			}
		}
	}
	catch {
		if ($2.UI) {
			Show-FarMessage $_
		}
		return
	}

	# confirm
	if ($2.UI) {
		$text = "$($2.Files.Count) documents(s)"
		if (Show-FarMessage $text Delete YesNo) {
			return
		}
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
		if ($2.UI) {
			Show-FarMessage "$_"
		}
	}

	$1.Data.Panel.NeedsNewFiles = $true
}

function FLDocumentsExplorer_AsGetContent($1, $2) {
	$id = $2.File.Data._id
	if ($null -eq $id) {
		Show-FarMessage 'Cannot edit documents without _id'
		$2.Result = 'Ignore'
		return
	}

	$doc = Use-LiteDatabase $1.Data.ConnectionString {
		$collection = Get-LiteCollection $1.Data.CollectionName
		Get-LiteData $collection '$._id = @_id', @{_id = $id}
	}

	$2.UseText = $doc.Print()
	$2.UseFileExtension = 'js'
	$2.CanSet = $true
	$2.EditorOpened = {FLDocumentsExplorer_EditorOpened}
}

function FLDocumentsExplorer_AsGetData($1, $2) {
	if ($2.NewFiles -or !$1.Cache) {
		Use-LiteDatabase $1.Data.ConnectionString {
			if ($1.Data.Query) {
				$collectionName = ''
				Invoke-LiteCommand $1.Data.Query $1.Data.Parameters -As PS -Collection ([ref]$collectionName)
				$1.Data.CollectionName = $collectionName
			}
			else {
				$collection = Get-LiteCollection $1.Data.CollectionName
				Get-LiteData $collection -First $2.Limit -Skip $2.Offset -As PS
			}
		}
	}
	else {
		, $1.Cache
	}
}

function FLDocumentsExplorer_AsSetText($1, $2) {
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
