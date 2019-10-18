# Compile-SourceScript

[![badge-build-azuredevops-build-img][]][badge-build-azuredevops-build-src] [![badge-version-github-release-img][]][badge-version-github-release-src] [![badge-version-powershellgallery-releases-img][]][badge-version-powershellgallery-releases-src]

[badge-build-azuredevops-build-img]: https://img.shields.io/azure-devops/build/startersclan/Compile-SourceScript/4/master.svg?label=build&logo=azure-pipelines&style=flat-square
[badge-build-azuredevops-build-src]: https://dev.azure.com/startersclan/Compile-SourceScript/_build?definitionId=4
[badge-version-github-release-img]: https://img.shields.io/github/v/release/startersclan/Compile-SourceScript?style=flat-square
[badge-version-github-release-src]: https://github.com/startersclan/Compile-SourceScript/releases
[badge-version-powershellgallery-releases-img]: https://img.shields.io/powershellgallery/v/Compile-SourceScript?logo=powershell&logoColor=white&label=PSGallery&labelColor=&style=flat-square
[badge-version-powershellgallery-releases-src]: https://www.powershellgallery.com/packages/Compile-SourceScript/

A PowerShell module for compiling [**SourceMod**](https://www.sourcemod.net/) [`.sp`](https://wiki.alliedmods.net/Compiling_SourceMod_Plugins) and [**AMX Mod X**](https://www.amxmodx.org/) [`.sma`](https://wiki.alliedmods.net/Compiling_Plugins_(AMX_Mod_X)) plugin source files for [**Source**](https://developer.valvesoftware.com/wiki/Source) / [**Goldsource**](https://developer.valvesoftware.com/wiki/Goldsource) games.

## Introduction

`Compile-SourceScript` is a wrapper that eases development of each mod's plugins by first getting source files compiled into plugins, which, if found to be new or possess a differing hash, are then copied into the respective mod's `plugins` directory .

## Requirements

- **Windows** with [PowerShell 4.0 or later](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-windows-powershell?view=powershell-5.1), or ***nix** with [PowerShell Core](https://github.com/powershell/powershell).

## Usage

`Compile-SourceScript` may be used as a script or a module.

### Examples

Compiles the **SourceMod** plugin source file `plugin1.sp`, and installs the compiled plugin with user confirmation for the game Counter-Strike: Global Offensive.

```powershell
Compile-SourceScript -File ~/servers/csgo/addons/sourcemod/scripting/plugin1.sp
```

Compiles the **AMX Mod X** plugin source file `plugin2.sma` *without* using the mod's compiler wrapper, and installs the compiled plugin *without* user confirmation for the game Counter-Strike 1.6.

```powershell
Compile-SourceScript -File ~/servers/cstrike/addons/amxmodx/scripting/plugin2.sma -SkipWrapper -Force
```

### VSCode

[Build Tasks](https://code.visualstudio.com/docs/editor/tasks#vscode) can be utilized to ease development of plugins from within the code editor.

A sample tasks file can be found [here](docs/samples/.vscode/tasks.json.sample).

## Administration

### Versions

To list versions of the module on `PSGallery`:

```powershell
# Latest
Find-Module -Name Compile-SourceScript -Repository PSGallery -Verbose

# All versions
Find-Module -Name Compile-SourceScript -Repository PSGallery -AllVersions -Verbose
```

To update the module (**Existing versions are left intact**):

```powershell
# Latest
Update-Module -Name Compile-SourceScript -Verbose

# Specific version
Update-Module -Name Compile-SourceScript -RequiredVersion x.x.x -Verbose
```

To uninstall the module:

```powershell
# Latest
Uninstall-Module -Name Compile-SourceScript -Verbose

# All versions
Uninstall-Module -Name Compile-SourceScript -AllVersions -Verbose

# To uninstall all other versions other than x.x.x
Get-Module -Name Compile-SourceScript -ListAvailable | ? { $_.Version -ne 'x.x.x' } | % { Uninstall-Module -Name $_.Name -RequiredVersion $_.Version -Verbose }

# Tip: Simulate uninstalls with -WhatIf
```

### Repositories

To get all registered PowerShell repositories:

```powershell
Get-PSRepository -Verbose
```

To set the installation policy for the `PSGallery` repository:

```powershell
# PSGallery (trusted)
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -Verbose

# PSGallery (untrusted)
Set-PSRepository -Name PSGallery -InstallationPolicy Untrusted -Verbose
```

### Development

To import / re-import the module:

```powershell
# Installed version
Import-Module -Name Compile-SourceScript -Force -Verbose

# Project version
Import-Module .\src\Compile-SourceScript\Compile-SourceScript.psm1 -Force -Verbose
```

To remove imported functions of the module:

```powershell
Remove-Module -Name Compile-SourceScript -Verbose
```

To list imported versions of the module:

```powershell
Get-Module -Name Compile-SourceScript
```

To list all installed versions of the module available for import:

```powershell
Get-Module -Name Compile-SourceScript -ListAvailable -Verbose
```
