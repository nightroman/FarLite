<#
.Synopsis
	Edits the current editor JSON line value.

.Description
	This command is called from the editor with a JSON file and the current
	line like `<key> : "<text>"`. The line may ends with a comma. The <text>
	is opened in another editor. After saved changes the current line is set
	to `<key> : "<new-text>"`, with a comma if it was there.
#>

function Edit-LiteJsonLine {
	trap {Write-Error -ErrorRecord $_}

	$Editor = $Far.Editor
	if (!$Editor) {
		throw "Invoke this command from the editor."
	}

	$text = $Editor.Line.Text.TrimEnd()
	$isComma = $text.EndsWith(',')
	if ($isComma) {
		$text = $text.Substring(0, $text.Length - 1)
	}
	$spaces = if ($text -match '^\s*') {$matches[0]}
	$text = $text.Trim()

	$json = "{$text}"
	try {
		$doc = [Ldbc.Dictionary]::FromJson($json)
	}
	catch {
		throw "Cannot parse JSON: $json"
	}
	$key = @($doc.Keys)[0]
	$value = @($doc.Values)[0]
	if ($value -isnot [string]) {
		throw "Value should be string."
	}

	$arg = New-Object FarNet.EditTextArgs -Property @{
		Title = "Edit string value '$key'"
		Extension = '.txt'
		Text = $value
	}
	$value2 = $Far.AnyEditor.EditText($arg)
	if ($value2 -ceq $value) {
		return
	}

	$doc[$key] = $value2
	$text = $spaces + ($doc.Print().Trim().TrimStart('{').TrimEnd('}').Trim())
	if ($isComma) {
		$text += ','
	}

	$Editor.Line.Text = $text
	$Editor.Redraw()
}
