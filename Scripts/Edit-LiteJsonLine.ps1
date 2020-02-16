<#
.Synopsis
	Edits the current editor JSON line value.

.Description
	This command is called from JSON editors with the current line like:

		key : "<text>"
		key : {$date: "<text>"}
		key : {$guid: "<text>"}
		key : {$oid: "<text>"}

	The line may ends with a comma. The <text> is opened in another editor,
	dates are converted to local time and more friendly format. After saved
	changes the current line is updated, with a comma if it was there.

	On editing $date, if you remove the text and save the empty file, then the
	current date and time is inserted.

	On editing $guid and $oid a new generated value is inserted if you confirm.
#>

function Edit-LiteJsonLine {
	trap {Write-Error -ErrorRecord $_}

	$Editor = $Far.Editor
	if (!$Editor) {
		throw "Invoke this command from the editor."
	}

	# get line text
	$text = $Editor.Line.Text.TrimEnd()
	$isComma = $text.EndsWith(',')
	if ($isComma) {
		$text = $text.Substring(0, $text.Length - 1)
	}
	$spaces = if ($text -match '^\s*') {$matches[0]}
	$text = $text.Trim()

	# make json, get key and value
	$json = "{$text}"
	try {
		$doc = [Ldbc.Dictionary]::FromJson($json)
	}
	catch {
		throw "Cannot parse JSON: $json"
	}
	$key = @($doc.Keys)[0]
	$value = @($doc.Values)[0]

	# make text to edit
	if ($value -is [string]) {
		$text = $value
	}
	elseif ($value -is [datetime]) {
		$text = $value.ToString('yyyy-MM-dd HH:mm:ss')
	}
	elseif ($value -is [guid]) {
		if (Show-FarMessage 'Generate new Guid?' FarLite OkCancel) {
			return
		}
	}
	elseif ($value -is [LiteDB.ObjectId]) {
		if (Show-FarMessage 'Generate new ObjectId?' FarLite OkCancel) {
			return
		}
	}
	else {
		Show-FarMessage 'Edit this value directly.' FarLite
		return
	}

	# edit text
	if ($value -is [string] -or $value -is [datetime]) {
		$arg = New-Object FarNet.EditTextArgs -Property @{
			Title = "Edit string value '$key'"
			Extension = '.txt'
			Text = $text
		}
		$text2 = $Far.AnyEditor.EditText($arg)
		if ($text2 -ceq $text) {
			return
		}
	}

	# make new value
	if ($value -is [string]) {
		$value2 = $text2
	}
	elseif ($value -is [datetime]) {
		$text2 = $text2.Trim()
		if ($text2) {
			$value2 = [datetime]$text2
		}
		else {
			$value2 = [datetime]([datetime]::Now.ToString('yyyy-MM-dd hh:mm:ss'))
		}
	}
	elseif ($value -is [guid]) {
		$value2 = [guid]::NewGuid()
	}
	elseif ($value -is [LiteDB.ObjectId]) {
		$value2 = [LiteDB.ObjectId]::NewObjectId()
	}

	# make new line
	$doc[$key] = $value2
	$text = $spaces + ($doc.Print().Trim().TrimStart('{').TrimEnd('}').Trim())
	if ($isComma) {
		$text += ','
	}

	# set new line
	$Editor.Line.Text = $text
	$Editor.Redraw()
}
