function Compile-SourceScript {
    <#
    .SYNOPSIS
    Compile-SourceScript is a wrapper for compiling SourceMod (.sp) and AMX Mod X (.sma) plugin source files for Source / GoldSource games.

    .DESCRIPTION
    The script works by getting the specified plugin's source file compiled, and upon successful compilation, populating the respective mod's plugins directory with the newly compiled plugin.

    .PARAMETER File
    Path to the plugin's .sp or .sma file.

    .PARAMETER Force
    Copies the newly compiled plugin to the plugins directory without user confirmation.

    .EXAMPLE
    ./Compile-SourceScript.ps1 -File ~/servers/csgo/addons/sourcemod/scripting/plugin1.sp
    Compiles the SourceMod plugin source file 'plugin1.sp' with user confirmation for the game Counter-Strike: Global Offensive.

    .EXAMPLE
    ./Compile-SourceScript.ps1 -File ~/servers/cstrike/addons/amxmodx/scripting/plugin2.sma -Force
    Compiles the AMX Mod X plugin source file 'plugin2.sma' without user confirmation for the game Counter-Strike 1.6.

    .LINK
    https://github.com/theohbrothers/Compile-SourceScript
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$False)]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
        $File
    ,
        [Parameter(Mandatory=$False)]
        [switch]$Force
    )

    begin {
        $ErrorActionPreference = 'Stop'

        # Define variables
        $SCRIPT_EXTS = '.sp', '.sma'
        $PLUGIN_EXTS = '.smx', '.amxx'
        $COMPILE_WRAPPER_NAME = if ($IsWindows -Or $env:OS) { 'compile.exe' } else { 'compile.sh' }
        $COMPILED_DIR_NAME = 'compiled'
        $PLUGINS_DIR_NAME = 'plugins'

        # Copy-Item Cmlet parameters
        $copyParams = @{
            Confirm = !$Force
        }
    }
    process {
        try {
            # Process script
            $script = Get-Item -Path $File
            if ($script.Extension -notin $SCRIPT_EXTS) {
                throw "File is not a .sp or .sma source file."
            }

            "Running compile wrapper" | Write-Host -ForegroundColor Cyan

            # Normalize paths
            $scriptingDir = $script.DirectoryName
            $compiledDir = Join-Path $scriptingDir $COMPILED_DIR_NAME
            $pluginsDir = Join-Path (Split-Path $scriptingDir -Parent) $PLUGINS_DIR_NAME

            # Validate compiler binary
            $compilerItem = Get-Item -Path (Join-Path $scriptingDir $COMPILE_WRAPPER_NAME)
            "Compiler: $($compilerItem.FullName)" | Write-Host

            # Get all items in compiled folder before compilation by hash
            $compiledDirItemsPre = Get-ChildItem $compiledDir -Recurse -Force | ? { $_.Extension -in $PLUGIN_EXTS } | Select-Object *, @{name='md5'; expression={(Get-FileHash $_.Fullname -Algorithm MD5).Hash}}

            # Run the compiler
            "Compiling..." | Write-Host -ForegroundColor Cyan
            $epoch = [Math]::Floor([decimal](Get-Date(Get-Date).ToUniversalTime()-uformat "%s"))
            $stdInFile = New-Item -Path (Join-Path $scriptingDir ".$epoch") -ItemType File -Force
            '1' | Out-File -FilePath $stdInFile.FullName -Force -Encoding utf8
            Start-Process $compilerItem.FullName -ArgumentList $script.Name -WorkingDirectory $scriptingDir -RedirectStandardInput $stdInFile.FullName -Wait -NoNewWindow

            # Get all items in compiled folder after compilation by hash
            $compiledDirItemsPost = Get-ChildItem $compiledDir -Recurse -Force | ? { $_.Extension -in $PLUGIN_EXTS } | Select-Object *, @{name='md5'; expression={(Get-FileHash $_.FullName -Algorithm MD5).Hash}}

            # Get items with differing hashes
            $compiledDirItemsDiff = if ($compiledDirItemsPost) {
                if ($compiledDirItemsPre) {
                    $hashesDiffObj = Compare-object -ReferenceObject $compiledDirItemsPre -DifferenceObject $compiledDirItemsPost -Property FullName, md5 | ? { $_.SideIndicator -eq '=>' }
                    $compiledDirItemsPost | ? { $_.md5 -in $hashesDiffObj.md5 }
                }else {
                    $compiledDirItemsPost
                }
            }

            if ($compiledDirItemsDiff) {
                # List successfully compiled plugins
                "`nNewly compiled plugins:" | Write-Host -ForegroundColor Cyan
                $compiledDirItemsDiff | % {
                    $compiledPluginHash = (Get-FileHash $_.FullName -Algorithm MD5).Hash
                    "    $($_.Name), $($_.LastWriteTime), $compiledPluginHash" | Write-Host -ForegroundColor White
                }

                New-Item -Path $pluginsDir -ItemType Directory -Force | Out-Null
                $compiledDirItemsDiff | % {
                    "`n$($_.Name):" | Write-Host -ForegroundColor Green
                    if ($_.Basename -ne $script.Basename) {
                        "The plugin's name does not match the specified script's name." | Write-Host -ForegroundColor Magenta
                        return  # continue in %
                    }
                    $existingPlugin = Get-Item "$pluginsDir/$($_.Name)" -ErrorAction SilentlyContinue
                    if (!$existingPlugin) {
                        "    Plugin does not currently exist in the plugins directory." | Write-Host -ForegroundColor Yellow
                    }else {
                        $existingPluginHash = (Get-FileHash $existingPlugin -Algorithm MD5).Hash
                        "    Existing: $($existingPlugin.LastWriteTime), $existingPluginHash" | Write-Host -ForegroundColor Yellow
                    }
                    # Display the compiled and existing plugin's file info
                    $compiledPluginHash = (Get-FileHash $_.FullName -Algorithm MD5).Hash
                    "    Compiled: $($_.LastWriteTime), $compiledPluginHash" | Write-Host -ForegroundColor Green

                    # Attempt to copy the compiled plugin to the plugins folder
                    Copy-Item -Path $_.FullName -Destination $pluginsDir -Recurse @copyParams

                    if ($LASTEXITCODE) { "Plugin copy error." | Write-Host -ForegroundColor Magenta; return }
                    # Alert the user on the situation of the plugin
                    $updatedPlugin = Get-Item "$pluginsDir/$($_.Name)"
                    $updatedPluginHash = (Get-FileHash $updatedPlugin -Algorithm MD5).Hash
                    if ($updatedPluginHash -eq $compiledPluginHash) { "`nPlugin successfully copied to $($_.Fullname)" | Write-Host -ForegroundColor Green }
                    else { "`nPlugin not copied." | Write-Host -ForegroundColor Magenta; return }
                }
            }else {
               "`nNo newly compiled plugins found. No operations were performed." | Write-Host -ForegroundColor Magenta
            }
        }catch {
            throw "Runtime error. Exception: $($_.Exception.Message)"
        }finally {
            # Cleanup
            if ($stdInFile) {
                Remove-Item $stdInFile -Force
            }
            "End of compile wrapper." | Write-Host -ForegroundColor Cyan
        }
    }
}
