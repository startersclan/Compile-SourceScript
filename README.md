# Compile-SourceScript

Compiles the specified `hlds` or `srcds` script, and populates the relative plugins folder with the newly compiled plugin upon user confirmation.


#### Instructions
Add a debug configuration in `User Settings` or `Workspace Settings` to quickly compile the `.sp` or `.sma` source file by **selecting** the debug configuration and pushing **F5**.

Example of a global debug configuration:

```json
// In User Settings
{
    "launch": {
        "version": "0.2.0",
        "configurations": [
            {
                //.. Some other configuration
            },
            {
                "type": "PowerShell",
                "request": "launch",
                "name": "Compile hlds/srcds script",
                "script": "C:\\Path\\to\\script\\Compile-SourceScript.ps1",
                "args": ["${file}", "-Force"],
                "cwd": "${file}"
            }
        ]
    }
}
```

For more information, see <a href="https://code.visualstudio.com/docs/editor/debugging#_global-launch-configuration" target="_blank" title="Debugging">here</a>.