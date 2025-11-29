<#
.Synopsis
	Build script, https://github.com/nightroman/Invoke-Build
#>

Set-StrictMode -Version Latest
$_name = 'FarLite'

# Synopsis: Remove temp files.
task clean {
	remove z
}

# Synopsis: Set $Script:_version.
task version {
	($Script:_version = Get-BuildVersion Release-Notes.md '##\s+v(\d+\.\d+\.\d+)')
}

# Synopsis: Make the package in z\$_name.
task package version, {
	remove z
	$null = mkdir z\$_name\Scripts

	Copy-Item -Destination z\$_name\Scripts @(
		'Scripts\*'
	)

	Copy-Item -Destination z\$_name @(
		"about_$_name.help.txt"
		"$_name.psd1"
		"$_name.psm1"
		'LICENSE'
	)

	# set module version
	Import-Module PsdKit
	$xml = Import-PsdXml z\$_name\$_name.psd1
	Set-Psd $xml $_version 'Data/Table/Item[@Key="ModuleVersion"]'
	Export-PsdXml z\$_name\$_name.psd1 $xml
}

# Synopsis: Make and push the PSGallery package.
task pushPSGallery package, {
	$NuGetApiKey = Read-Host NuGetApiKey
	Publish-Module -Path z\$_name -NuGetApiKey $NuGetApiKey
},
clean

task test {
	exec { pwsf "$env:FarNetCode\Test\Panels.Lite" -nop -x 999 -c Test-FarNet.ps1 }
}
