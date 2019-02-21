# Compile-SourceScript

`Compile-SourceScript` is a wrapper for compiling **AMX Mod X** ([`.sma`](https://wiki.alliedmods.net/Compiling_Plugins_(AMX_Mod_X))) and **SourceMod** ([`.sp`](https://wiki.alliedmods.net/Compiling_SourceMod_Plugins)) plugin source files for **GoldSource / Source** games.

The script works by getting the specified plugin's source file compiled, and upon successful compilation, populating the respective mod's `plugins` directory with the newly compiled plugin.

## Requirements

- **Windows** with [Powershell 4.0 or later](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-windows-powershell?view=powershell-5.1), or ***nix** with [Powershell Core](https://github.com/powershell/powershell).

## Examples

### via Command Line

Compiles the amxmodx plugin source file `plugin1.sma` with user confirmation for game Counter-Strike 1.6.

```powershell
./Compile-SourceScript.ps1 -File ~/servers/czero/addons/amxmodx/scripting/plugin1.sma
```

Compiles the sourcemod plugin source file `plugin2.sp` without user confirmation for the game Counter-Strike: Global Offensive.

```powershell
./Compile-SourceScript.ps1 -File ~/servers/csgo/addons/sourcemod/scripting/plugin2.sp -Force
```

### via VSCode

[Build Tasks](https://code.visualstudio.com/docs/editor/tasks#vscode) can be utilized to ease the development of plugins right from within the code editor.

```json
// In tasks.json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Compile-SourceScript",
            "type": "process",
            "command": "Powershell",
            "args": [
                "-File",
                "D:/git/compile-sourcescript/Compile-SourceScript.ps1",
                "-File",
                "${file}",
                "-Force"
            ]
        }
    ]
}
```