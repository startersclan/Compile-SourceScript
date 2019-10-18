function Compile-SourceScript {
    <#
    .SYNOPSIS
    A wrapper for compiling SourceMod (.sp) and AMX Mod X (.sma) plugin source files for Source / GoldSource games.

    .DESCRIPTION
    Specified plugins are compiled and subsequently copied into the mod's plugins directory if found to be new or have been changed.

    .PARAMETER File
    Path to the plugin's source file (.sp or .sma).

    .PARAMETER SkipWrapper
    To directly run the mod's compiler instead of using provided wrappers (such as 'compile.exe' and 'compile.sh') in the compilation process.

    .PARAMETER Force
    Copies the newly compiled plugin to the mod's plugins directory without user confirmation.

    .EXAMPLE
    Compile-SourceScript -File ~/servers/csgo/addons/sourcemod/scripting/plugin1.sp
    Compiles the SourceMod plugin source file 'plugin1.sp', and installs the compiled plugin with user confirmation for the game Counter-Strike: Global Offensive.

    .EXAMPLE
    Compile-SourceScript -File ~/servers/cstrike/addons/amxmodx/scripting/plugin2.sma -SkipWrapper -Force
    Compiles the AMX Mod X plugin source file 'plugin2.sma' without using the mod's compiler wrapper, and installs the compiled plugin without user confirmation for the game Counter-Strike 1.6.

    .LINK
    https://github.com/startersclan/Compile-SourceScript
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$False)]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
        $File
        ,
        [Parameter(Mandatory=$False)]
        [switch]$SkipWrapper
        ,
        [Parameter(Mandatory=$False)]
        [switch]$Force
    )

    begin {
        "Starting Compile-SourceScript" | Write-Host -ForegroundColor Cyan
        $ErrorActionPreference = 'Stop'
        $MOD = @{
            sourcemod = @{
                script_ext = '.sp'
                plugin_ext = '.smx'
                compiled_dir_name = 'compiled'
                plugins_dir_name = 'plugins'
                compiler = @{
                    windows = @{
                        wrapper = 'compile.exe'
                        bin = 'spcomp.exe'
                    }
                    others = @{
                        wrapper = 'compile.sh'
                        bin = 'spcomp'
                    }
                }
            }
            amxmodx = @{
                script_ext = '.sma'
                plugin_ext = '.amxx'
                compiled_dir_name = 'compiled'
                plugins_dir_name = 'plugins'
                compiler = @{
                    windows = @{
                        wrapper = 'compile.exe'
                        bin = 'amxxpc.exe'
                    }
                    others = @{
                        wrapper = 'compile.sh'
                        bin = 'amxxpc'
                    }
                }
            }
        }
        $MOD_NAME = if ([System.IO.Path]::GetExtension($PSBoundParameters['File']) -eq '.sp') { 'sourcemod' }
                    elseif ([System.IO.Path]::GetExtension($PSBoundParameters['File']) -eq '.sma') { 'amxmodx' }
        if (!$MOD_NAME) {
            throw "File is not a .sp or .sma source file."
        }
        $COMPILER_NAME = if ($env:OS) {
            if ($PSBoundParameters['SkipWrapper']) { $MOD[$MOD_NAME]['compiler']['windows']['bin'] }
            else { $MOD[$MOD_NAME]['compiler']['windows']['wrapper'] }
        }else {
            if ($PSBoundParameters['SkipWrapper']) { $MOD[$MOD_NAME]['compiler']['others']['bin'] }
            else { $MOD[$MOD_NAME]['compiler']['others']['wrapper'] }
        }

        try {
            $sourceFile = Get-Item -Path $PSBoundParameters['File']

            # Normalize paths
            $SCRIPTING_DIR = $sourceFile.DirectoryName
            $COMPILED_DIR = Join-Path $SCRIPTING_DIR $MOD[$MOD_NAME]['compiled_dir_name']
            $PLUGINS_DIR = Join-Path (Split-Path $SCRIPTING_DIR -Parent) $MOD[$MOD_NAME]['plugins_dir_name']

             # Validate compiler binary
            $compiler = Get-Item -Path (Join-Path $SCRIPTING_DIR $COMPILER_NAME)
        }catch {
            throw
        }
    }process {
        try {
            "Compiler: '$($compiler.FullName)'" | Write-Host

            # Get all items in compiled directory before compilation by hash
            $compiledDirItemsPre = Get-ChildItem -Path $COMPILED_DIR -File -Recurse -Force | ? { $_.Extension -eq $MOD[$MOD_NAME]['plugin_ext'] } | Select-Object *, @{name='md5'; expression={(Get-FileHash -Path $_.Fullname -Algorithm MD5).Hash}}

            # Prepare for compilation
            "Compiling..." | Write-Host -ForegroundColor Cyan
            $epoch = [Math]::Floor([decimal](Get-Date(Get-Date).ToUniversalTime()-uformat "%s"))
            $stdInFile = New-Item -Path (Join-Path $SCRIPTING_DIR ".$epoch") -ItemType File -Force
            '1' | Out-File -FilePath $stdInFile.FullName -Force -Encoding utf8
            $processArgs = @{
                FilePath = $compiler.FullName
                WorkingDirectory = $SCRIPTING_DIR
                RedirectStandardInput = $stdInFile.FullName
                Wait = $true
                NoNewWindow = $true
            }
            if ($PSBoundParameters['SkipWrapper']) {
                $processArgs['ArgumentList'] = @(
                    $sourceFile.Name
                    "-o$($MOD[$MOD_NAME]['compiled_dir_name'])/$($sourceFile.Basename)$($MOD[$MOD_NAME]['plugin_ext'])"
                )
            }else {
                $processArgs['ArgumentList'] = @(
                    $sourceFile.Name
                )
            }
            New-Item -Path $COMPILED_DIR -ItemType Directory -Force | Out-Null
            # Begin compilation
            if ($PSBoundParameters['SkipWrapper']) { "Compiling $($sourceFile.Name)..." | Write-Host -ForegroundColor Yellow }
            Start-Process @processArgs
            if ($PSBoundParameters['SkipWrapper']) { "End of compilation." | Write-Host -ForegroundColor Yellow }

            # Get all items in compiled directory after compilation by hash
            $compiledDirItemsPost = Get-ChildItem -Path $COMPILED_DIR -File -Recurse -Force | ? { $_.Extension -eq $MOD[$MOD_NAME]['plugin_ext'] } | Select-Object *, @{name='md5'; expression={(Get-FileHash -Path $_.FullName -Algorithm MD5).Hash}}

            # Get items with differing hashes
            $compiledDirItemsDiff = if ($compiledDirItemsPost) {
                                        if ($compiledDirItemsPre) {
                                            $hashesDiffObj = Compare-object -ReferenceObject $compiledDirItemsPre -DifferenceObject $compiledDirItemsPost -Property FullName, md5 | ? { $_.SideIndicator -eq '=>' }
                                            if ($hashesDiffObj) {
                                                $compiledDirItemsPost | ? { $_.md5 -in $hashesDiffObj.md5 }
                                            }
                                        }else {
                                            $compiledDirItemsPost
                                        }
                                    }

            if ($compiledDirItemsDiff) {
                # List successfully compiled plugins
                "`nNewly compiled plugins:" | Write-Host -ForegroundColor Cyan
                $compiledDirItemsDiff | % {
                    $compiledPluginHash = (Get-FileHash -Path $_.FullName -Algorithm MD5).Hash
                    "    $($_.Name), $($_.LastWriteTime), $compiledPluginHash" | Write-Host -ForegroundColor White
                }

                New-Item -Path $PLUGINS_DIR -ItemType Directory -Force | Out-Null
                $installationFailure = $false
                $compiledDirItemsDiff | % {
                    "`n$($_.Name):" | Write-Host -ForegroundColor Green
                    if ($_.Basename -ne $sourceFile.Basename) {
                        "    The plugin's name does not match the specified script's name. The plugin will not copied to the plugins directory." | Write-Host -ForegroundColor Yellow
                        return  # continue in %
                    }
                    $existingPlugin = Get-Item -Path "$PLUGINS_DIR/$($_.Name)" -ErrorAction SilentlyContinue
                    if (!$existingPlugin) {
                        "    Plugin does not currently exist in the plugins directory." | Write-Host -ForegroundColor Yellow
                    }else {
                        $existingPluginHash = (Get-FileHash -Path $existingPlugin -Algorithm MD5).Hash
                        "    Existing: $($existingPlugin.LastWriteTime), $existingPluginHash" | Write-Host -ForegroundColor Yellow
                    }
                    # Display the compiled and existing plugin's file info
                    $compiledPluginHash = (Get-FileHash -Path $_.FullName -Algorithm MD5).Hash
                    "    Compiled: $($_.LastWriteTime), $compiledPluginHash" | Write-Host -ForegroundColor Green

                    # Attempt to copy the compiled plugin to the plugins directory
                    try {
                        Copy-Item -Path $_.FullName -Destination $PLUGINS_DIR -Confirm:$(!$PSBoundParameters['Force'])
                    }catch {
                        "    Plugin copy error." | Write-Host -ForegroundColor Magenta
                        $installationFailure = $true
                        return  # continue in %
                    }

                    # Alert the user on the situation of the plugin
                    $updatedPlugin = Get-Item -Path "$PLUGINS_DIR/$($_.Name)"
                    $updatedPluginHash = (Get-FileHash -Path $updatedPlugin -Algorithm MD5).Hash
                    if ($updatedPluginHash -eq $compiledPluginHash) { "`n    Plugin successfully copied to '$($_.Fullname)'" | Write-Host -ForegroundColor Green }
                    else { "`n    Failed to copy to the plugins directory." | Write-Host -ForegroundColor Magenta; return }
                }
                if ($installationFailure) {
                    throw "Failed to install one or more plugins."
                }
            }else {
               "`nNo changes to plugins were found. No operations were performed." | Write-Host -ForegroundColor Magenta
            }
        }catch {
            throw
        }finally {
            # Cleanup
            if ($stdInFile) {
                Remove-Item -Path $stdInFile -Force
            }
            "End of Compile-SourceScript." | Write-Host -ForegroundColor Cyan
        }
    }
}
