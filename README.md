# Compile-SourceScript

`Compile-SourceScript` is a wrapper for compiling **SourceMod** ([`.sp`](https://wiki.alliedmods.net/Compiling_SourceMod_Plugins)) and **AMX Mod X** ([`.sma`](https://wiki.alliedmods.net/Compiling_Plugins_(AMX_Mod_X))) plugin source files for **Source / GoldSource** games.

The script works by getting the specified plugin's source file compiled, and upon successful compilation, populating the respective mod's `plugins` directory with the newly compiled plugin.

## Requirements

- **Windows** with [Powershell 4.0 or later](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-windows-powershell?view=powershell-5.1), or ***nix** with [Powershell Core](https://github.com/powershell/powershell).

## Examples

### via Command Line

Compiles the SourceMod plugin source file `plugin1.sp` with user confirmation for the game Counter-Strike: Global Offensive.

```powershell
./Compile-SourceScript.ps1 -File ~/servers/csgo/addons/sourcemod/scripting/plugin1.sp
```

Compiles the AMX Mod X plugin source file `plugin2.sma` *without* user confirmation for the game Counter-Strike 1.6.

```powershell
./Compile-SourceScript.ps1 -File ~/servers/czero/addons/amxmodx/scripting/plugin2.sma -Force
```

### via VSCode

[Build Tasks](https://code.visualstudio.com/docs/editor/tasks#vscode) can be utilized to ease the development of plugins within the code editor.

```json
// In tasks.json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Compile-SourceScript (pwsh)",
            "type": "process",
            "command": "pwsh",
            "args": [
                "-File",
                "D:/Git/Compile-SourceScript/Compile-SourceScript.ps1",
                "-File",
                "${file}",
                "-Force"
            ],
            "group": {
                "kind": "build",
                "isDefault": true
            }
        },
        {
            "label": "Compile-SourceScript (powershell)",
            "type": "process",
            "command": "powershell",
            "args": [
                "-File",
                "D:/Git/Compile-SourceScript/Compile-SourceScript.ps1",
                "-File",
                "${file}",
                "-Force"
            ],
            "group": "build"
        }
    ]
}
```