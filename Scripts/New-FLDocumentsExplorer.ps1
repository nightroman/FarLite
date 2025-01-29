
function New-FLDocumentsExplorer($ConnectionString, $Query, $Parameters, $Columns) {
	$Query = $Query.Trim()
	if ($Query -match '^\S+$') {
		$CollectionName = $Query
		$Query = $null
	}
	else {
		$CollectionName = $null
	}

	$Explorer = [PowerShellFar.ObjectExplorer]::new()
	$Explorer.Data = @{
		FarLiteId = 'ecf6e905-fdee-4a3b-b82b-9d577233ee80'
		ConnectionString = $ConnectionString
		CollectionName = $CollectionName
		Query = $Query
		Parameters = $Parameters
		Columns = $Columns
	}
	$Explorer.FileComparer = [PowerShellFar.FileMetaComparer]::new('_id')
	$Explorer.AsAcceptFiles = ${function:FLDocumentsExplorer_AsAcceptFiles}
	$Explorer.AsCreateFile = ${function:FLDocumentsExplorer_AsCreateFile}
	$Explorer.AsCreatePanel = ${function:FLDocumentsExplorer_AsCreatePanel}
	$Explorer.AsDeleteFiles = ${function:FLDocumentsExplorer_AsDeleteFiles}
	$Explorer.AsGetContent = ${function:FLDocumentsExplorer_AsGetContent}
	$Explorer.AsGetData = ${function:FLDocumentsExplorer_AsGetData}
	$Explorer.AsSetText = ${function:FLDocumentsExplorer_AsSetText}
	$Explorer
}

function FLDocumentsExplorer_AsCreatePanel($Explorer) {
	$panel = [PowerShellFar.ObjectPanel]::new($Explorer)
	$panel.Columns = $Explorer.Data.Columns
	if ($Explorer.Data.Query) {
		$title = $Explorer.Data.Query
	}
	else {
		$title = $Explorer.Data.CollectionName
		$panel.PageLimit = 1000
	}
	$panel.Title = $title
	$Explorer.Data.Panel = $panel
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

function FLDocumentsExplorer_AsCreateFile($Explorer, $2) {
	# edit new json
	$json = ''
	for() {
		$arg = [FarNet.EditTextArgs]::new()
		$arg.Title = 'New document (JSON)'
		$arg.Extension = 'js'
		$arg.Text = $json
		$arg.EditorOpened = ${function:FLDocumentsExplorer_EditorOpened}
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
		Use-LiteDatabase $Explorer.Data.ConnectionString {
			$collection = Get-LiteCollection $Explorer.Data.CollectionName
			Add-LiteData $collection $new
		}
	}
	catch {
		Show-FarMessage $_
		return
	}

	# post dummy file with _id
	$2.PostFile = New-FarFile -Data ([PSCustomObject]@{_id = $new._id})
	$Explorer.Data.Panel.NeedsNewFiles = $true
}

function FLDocumentsExplorer_AsDeleteFiles($Explorer, $2) {
	# check _id
	try {
		foreach($doc in $2.FilesData) {
			if ($null -eq $doc._id) {
				throw 'Cannot delete documents without _id'
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
		Use-LiteDatabase $Explorer.Data.ConnectionString {
			$collection = Get-LiteCollection $Explorer.Data.CollectionName
			foreach($doc in $2.FilesData) {
				Remove-LiteData $collection -ById $doc._id
			}
		}
	}
	catch {
		$2.Result = 'Incomplete'
		if ($2.UI) {
			Show-FarMessage "$_"
		}
	}

	$Explorer.Data.Panel.NeedsNewFiles = $true
}

function FLDocumentsExplorer_AsGetContent($Explorer, $2) {
	$id = $2.File.Data._id
	if ($null -eq $id) {
		Show-FarMessage 'Cannot edit documents without _id'
		$2.Result = 'Ignore'
		return
	}

	$doc = Use-LiteDatabase $Explorer.Data.ConnectionString {
		$collection = Get-LiteCollection $Explorer.Data.CollectionName
		Get-LiteData $collection -ById $id
	}

	$2.UseText = $doc.Print()
	$2.UseFileExtension = 'js'
	$2.CanSet = $true
	$2.EditorOpened = ${function:FLDocumentsExplorer_EditorOpened}
}

function FLDocumentsExplorer_AsGetData($Explorer, $2) {
	if ($2.NewFiles -or !$Explorer.Cache) {
		Use-LiteDatabase $Explorer.Data.ConnectionString {
			if ($Explorer.Data.Query) {
				$collectionName = ''
				Invoke-LiteCommand $Explorer.Data.Query $Explorer.Data.Parameters -As PS -Collection ([ref]$collectionName)
				$Explorer.Data.CollectionName = $collectionName
			}
			else {
				$collection = Get-LiteCollection $Explorer.Data.CollectionName
				Get-LiteData $collection -First $2.Limit -Skip $2.Offset -As PS
			}
		}
	}
	else {
		, $Explorer.Cache
	}
}

function FLDocumentsExplorer_AsSetText($Explorer, $2) {
	$new = [Ldbc.Dictionary]::FromJson($2.Text)
	$new.EnsureId()

	try {
		Use-LiteDatabase $Explorer.Data.ConnectionString {
			$collection = Get-LiteCollection $Explorer.Data.CollectionName
			Set-LiteData $collection $new -Add
		}
	}
	catch {
		Show-FarMessage $_
		return
	}

	$Explorer.Cache.Clear()
	$Explorer.Data.Panel.Update($true)
}

function FLDocumentsExplorer_AsAcceptFiles($Explorer, $2) {
	# check same explorer
	if ($2.Explorer.Data.FarLiteId -ne $Explorer.Data.FarLiteId) {
		Show-FarMessage 'Cannot copy/move from unknown panel.' FarLite
		return
	}

	# confirm
	$text = '{0} {1} documents?' -f $(if ($2.Move) {'Move'} else {'Copy'}), $2.Files.Count
	if (Show-FarMessage $text FarLite -Buttons OkCancel) {
		return
	}

	# copy/move
	$2.ToDeleteFiles = $2.Move
	Use-LiteDatabase $Explorer.Data.ConnectionString {
		$collection = Get-LiteCollection $Explorer.Data.CollectionName
		foreach($d in $2.FilesData) {
			Set-LiteData $collection $d -Add
		}
	}

	# update
	$Explorer.Cache.Clear()
	$Explorer.Data.Panel.Update($true)
}
