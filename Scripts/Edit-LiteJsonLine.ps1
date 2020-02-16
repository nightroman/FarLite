<#
.Synopsis
	Edits the current editor JSON line value.

.Description
	This command is called from JSON editors with the current line like:

		key : "<text>"
		key : {$date: "<text>"}

	The line may ends with a comma. The <text> is opened in another editor,
	dates are converted to local time and more friendly format. After saved
	changes the current line is updated, with a comma if it was there.
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
	else {
		throw "Value should be string or date."
	}

	# edit text
	$arg = New-Object FarNet.EditTextArgs -Property @{
		Title = "Edit string value '$key'"
		Extension = '.txt'
		Text = $text
	}
	$text2 = $Far.AnyEditor.EditText($arg)
	if ($text2 -ceq $text) {
		return
	}

	# make new value
	if ($value -is [string]) {
		$value2 = $text2
	}
	else {
		$value2 = [datetime]$text
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
