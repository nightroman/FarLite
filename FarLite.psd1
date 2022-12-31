@{
	Author = 'Roman Kuzmin'
	ModuleVersion = '0.0.0'
	Description = 'LiteDB browser in Far Manager'
	CompanyName = 'https://github.com/nightroman'
	Copyright = 'Copyright (c) Roman Kuzmin'
	GUID = '1ffd1bff-2de5-42bf-a077-af9482d5d88f'

	RootModule = 'FarLite.psm1'
	RequiredModules = 'Ldbc'
	PowerShellVersion = '3.0'
	DotNetFrameworkVersion = '4.5'

	AliasesToExport = @()
	CmdletsToExport = @()
	VariablesToExport = @()
	FunctionsToExport = @(
		'Edit-LiteJsonLine'
		'Open-LitePanel'
	)

	PrivateData = @{
		PSData = @{
			Tags = 'FarManager', 'LiteDB', 'Database'
			ProjectUri = 'https://github.com/nightroman/FarLite'
			LicenseUri = 'http://www.apache.org/licenses/LICENSE-2.0'
			ReleaseNotes = 'https://github.com/nightroman/FarLite/blob/main/Release-Notes.md'
		}
	}
}
