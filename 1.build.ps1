<#
.Synopsis
	Build script, https://github.com/nightroman/Invoke-Build
#>

Set-StrictMode -Version Latest
$ModuleName = 'FarLite'

# Synopsis: Remove temp files.
task clean {
	remove z
}

# Synopsis: Set $Script:Version.
task version {
	($Script:Version = Get-BuildVersion Release-Notes.md '##\s+v(\d+\.\d+\.\d+)')
}

# Synopsis: Make the package in z\$ModuleName.
task package version, {
	remove z
	$null = mkdir z\$ModuleName\Scripts

	Copy-Item -Destination z\$ModuleName\Scripts @(
		'Scripts\*'
	)

	Copy-Item -Destination z\$ModuleName @(
		"about_$ModuleName.help.txt"
		"$ModuleName.psd1"
		"$ModuleName.psm1"
		'LICENSE'
	)

	# set module version
	Import-Module PsdKit
	$xml = Import-PsdXml z\$ModuleName\$ModuleName.psd1
	Set-Psd $xml $Version 'Data/Table/Item[@Key="ModuleVersion"]'
	Export-PsdXml z\$ModuleName\$ModuleName.psd1 $xml
}

# Synopsis: Make and push the PSGallery package.
task pushPSGallery package, {
	$NuGetApiKey = Read-Host NuGetApiKey
	Publish-Module -Path z\$ModuleName -NuGetApiKey $NuGetApiKey
},
clean

task test {
	Start-Far "ps: Test-FarNet *" $env:FarNetCode\Test\Panels.Lite -Exit 999
}
