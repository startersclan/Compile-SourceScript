# Compile-SourceScript

[![azuredevops-build](https://img.shields.io/azure-devops/build/startersclan/Compile-SourceScript/4/master.svg?label=build&logo=azure-pipelines&style=flat-square)](https://dev.azure.com/startersclan/Compile-SourceScript/_build?definitionId=4)
[![github-release](https://img.shields.io/github/v/release/startersclan/Compile-SourceScript?style=flat-square)](https://github.com/startersclan/Compile-SourceScript/releases)
[![powershellgallery-version](https://img.shields.io/powershellgallery/v/Compile-SourceScript?logo=powershell&logoColor=white&label=PSGallery&labelColor=&style=flat-square)](https://www.powershellgallery.com/packages/Compile-SourceScript)

A PowerShell module for compiling [**SourceMod**](https://www.sourcemod.net/) ([`.sp`](https://wiki.alliedmods.net/Compiling_SourceMod_Plugins)) and [**AMX Mod X**](https://www.amxmodx.org/) ([`.sma`](https://wiki.alliedmods.net/Compiling_Plugins_(AMX_Mod_X))) plugin source files for [**Source**](https://developer.valvesoftware.com/wiki/Source) / [**Goldsource**](https://developer.valvesoftware.com/wiki/Goldsource) games.

## Introduction

`Compile-SourceScript` is a wrapper to ease development of each of the mod's plugins. Specified plugins are compiled and subsequently copied into the mod's `plugins` directory if found to be new or have been changed.

## Requirements

- **Windows** with [PowerShell 4.0 or later](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-windows-powershell), or ***nix** with [PowerShell Core](https://github.com/powershell/powershell#-powershell).

## Installation

The module can either be [*installed*](#via-install), or [*imported*](#via-import) from a local copy of this git repository.

### via Install

```powershell
# Latest version
Install-Module -Name Compile-SourceScript -Repository PSGallery -Scope CurrentUser -Verbose

# Or, for specific version
Install-Module -Name Compile-SourceScript -Repository PSGallery -RequiredVersion x.x.x -Scope CurrentUser -Verbose
```

If prompted to trust the repository, type `Y` and `enter`.

### via Import

```powershell
# Clone the git repository
git clone https://github.com/startersclan/Compile-SourceScript.git
cd Compile-SourceScript/

# Checkout version to use
git checkout vx.x.x

# Import the module
Import-Module ./src/Compile-SourceScript/Compile-SourceScript.psm1 -Force -Verbose
```

The module is now ready for use.

## Usage

### Functions

```powershell
Compile-SourceScript [-File] <String> [-SkipWrapper] [-Force] [<CommonParameters>]
```

#### Example 1

Compiles the *SourceMod* plugin source file `plugin1.sp`, and installs the compiled plugin *with* user confirmation for the game *Counter-Strike: Global Offensive*.

```powershell
Compile-SourceScript -File ~/server/csgo/addons/sourcemod/scripting/plugin1.sp
```

#### Example 2

Compiles the *AMX Mod X* plugin source file `plugin2.sma` *without* using the mod's compiler wrapper, and installs the compiled plugin *without* user confirmation for the game *Counter-Strike 1.6*.

```powershell
Compile-SourceScript -File ~/server/cstrike/addons/amxmodx/scripting/plugin2.sma -SkipWrapper -Force
```

### VSCode

`Compile-SourceScript` can be invoked via [*Build Tasks*](https://code.visualstudio.com/docs/editor/tasks) in [VSCode](https://code.visualstudio.com/).

Sample tasks files can be found [here](docs/samples/.vscode).

## Common issues

### Compiler errors

- `bash: /path/to/scripting/amxxpc: No such file or directory`

    Install [dependencies](test/scripts/dep/linux/sourcepawn-dependencies.sh) for the compiler.

- `compiler failed to instantiate: amxxpc32.so: cannot open shared object file: No such file or directory`

    Invoke the compiler from within the directory where the compiler is located:

    ```sh
    cd /path/to/scripting
    ./amxxpc
    ```

    See [here](https://forums.alliedmods.net/showthread.php?p=154320) for more details.
