# FarLite

PowerShell module with LiteDB browser in Far Manager

Requires Far Manager with FarNet.PowerShellFar and [Ldbc](https://github.com/nightroman/Ldbc)

## How to start

Install Ldbc and FarLite modules from the PowerShell gallery by these commands:

```powershell
Install-Module Ldbc
Save-Module FarLite -Path $env:FARHOME\FarNet\Modules\PowerShellFar\Modules
```

You can use the usual `Install-Module FarLite` command, too.
But the module works only in Far Manager with PowerShellFar.

Import the module and get help:

```powershell
Import-Module FarLite
help about_FarLite
```

## Examples

Browse "Test.LiteDB" collections.

```powershell
Open-LitePanel Test.LiteDB
```

Browse all documents from "Log".

```powershell
Open-LitePanel Test.LiteDB Log
```

Browse filtered "Log" documents ordered by descending time.

```powershell
Open-LitePanel Test.LiteDB 'SELECT $ FROM Log WHERE $.date > @0 ORDER BY $.date DESC' ([DateTime]::Today)
```

## See also

- [FarLite Release Notes](https://github.com/nightroman/FarLite/blob/master/Release-Notes.md)
- [about_FarLite.help.txt](https://github.com/nightroman/FarLite/blob/master/about_FarLite.help.txt)
- [FarMongo, similar project for MongoDB](https://github.com/nightroman/FarMongo)
