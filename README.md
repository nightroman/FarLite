# FarLite

[LiteDB]: https://www.litedb.org/
[Far Manager]: https://en.wikipedia.org/wiki/Far_Manager
[FarNet.PowerShellFar]: https://github.com/nightroman/FarNet/wiki
[Ldbc]: https://github.com/nightroman/Ldbc

PowerShell module with [LiteDB] browser in [Far Manager]

Requires Far Manager with [FarNet.PowerShellFar] and [Ldbc]

## How to start

Install Ldbc and FarLite modules from the PowerShell gallery by these commands:

```powershell
Install-Module Ldbc
Save-Module FarLite -Path $env:FARHOME\FarNet\Modules\PowerShellFar\Modules
```

You can use the usual `Install-Module FarLite` command, too.
But the module works only in PowerShellFar.

In Far Manager, import the module and get help:

```powershell
ps: Import-Module FarLite
ps: help about_FarLite
```

## Examples

```powershell
# Browse "Test.LiteDB" collections
Open-LitePanel Test.LiteDB

# Browse all documents from "Log"
Open-LitePanel Test.LiteDB Log

# Browse "Log" documents using specified columns
Open-LitePanel Test.LiteDB Log -Columns Message, @{e='Date'; k='DM'}, @{e='Type', w=7}

# Browse filtered "Log" documents ordered by descending time
Open-LitePanel Test.LiteDB 'SELECT $ FROM Log WHERE Date > @0 ORDER BY Date DESC' ([DateTime]::Today)
```

## See also

- [FarLite Release Notes](https://github.com/nightroman/FarLite/blob/master/Release-Notes.md)
- [about_FarLite.help.txt](https://github.com/nightroman/FarLite/blob/master/about_FarLite.help.txt)
- [FarMongo, similar project for MongoDB](https://github.com/nightroman/FarMongo)
