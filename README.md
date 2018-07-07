# Compile-SourceScript

Compiles the specified hlds & source script, and populates the relative plugins folder with the newly compiled plugin on user confirmation.


#### Instructions
Adding a debug configuration in `User Settings` or `Workspace Settings` will allow you to quickly compile the `.sp` or `.sma` source file simply by *selecting* the debug configuration and pushing **F5**.

A global debug configuration can be set up as follows:

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
                "args": ["${file}"],
                "cwd": "${file}"
            }
        ]
    }
}
```

For more information, see <a href="https://code.visualstudio.com/docs/editor/debugging#_global-launch-configuration" target="_blank" title="Debugging">here</a>.