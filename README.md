# FarLite

PowerShell module with LiteDB browser in Far Manager

For the requirements and details, see [about_FarLite.help.txt](https://github.com/nightroman/FarLite/blob/master/about_FarLite.help.txt)

**How to start**

Install the module from the PowerShell gallery by this command:

```powershell
Save-Module FarLite -Path $env:FARHOME\FarNet\Modules\PowerShellFar\Modules
```

You can use the usual `Install-Module FarLite` command, too, it's fine.
But the module works only with Far Manager, FarNet, and PowerShellFar.
PowerShellFar has its own special directory for PowerShell modules.

Import the module and get help:

```powershell
Import-Module FarLite
help about_FarLite
```

**See also**

- [FarLite Release Notes](https://github.com/nightroman/FarLite/blob/master/Release-Notes.md)
- [FarMongo, similar project for MongoDB](https://github.com/nightroman/FarMongo)
