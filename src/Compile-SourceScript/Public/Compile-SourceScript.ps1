function Compile-SourceScript {
    <#
    .SYNOPSIS
    A wrapper for compiling SourceMod (.sp) and AMX Mod X (.sma) plugin source files for Source / Goldsource games.

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
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$File
        ,
        [Parameter(Mandatory=$False)]
        [switch]$SkipWrapper
        ,
        [Parameter(Mandatory=$False)]
        [switch]$Force
    )

    begin {
        try {
            $ErrorActionPreference = 'Stop'
            "Starting Compile-SourceScript" | Write-Host -ForegroundColor Cyan

            # Verify the specified item's type and extension
            $sourceFile = Get-Item -Path $PSBoundParameters['File']
            if (!(Test-Path -Path $sourceFile.FullName -PathType Leaf)) {
                throw "The item is not a file."
            }
            $MOD_NAME = if ($sourceFile.Extension -eq '.sp') { 'sourcemod' }
                        elseif ($sourceFile.Extension -eq '.sma') { 'amxmodx' }
            if (!$MOD_NAME) {
                throw "File is not a '.sp' or '.sma' source file."
            }
            if (!($sourceFile.DirectoryName | Split-Path)) {
                throw "The directory 'addons/$MOD_NAME/' cannot exist relative to the specified plugin source file '$($sourceFile.FullName)'."
            }

            # Initialize variables
            $MOD = @{
                # The sourcemod compiler returns exits code correctly.
                # The sourcemod compiler wrapper returns the exit code of the lastmost executed shell statement. This is particularly bad when the compiler exits with '0' from a successful finalmost shell statement, even when one or more prior shell statements exited with non-zero exit codes.
                # Hence, knowing that exit codes are not a reliable way to determine whether one or more compilation statements failed, we are going to use a regex on the stdout as a more reliable way to detect compilation errors, regardless of whether compilation was performed via the compiler binary or via the compiler wrapper.
                sourcemod = @{
                    script_ext = '.sp'
                    plugin_ext = '.smx'
                    compiled_dir_name = 'compiled'
                    plugins_dir_name = 'plugins'
                    compiler = @{
                        windows = @{
                            wrapper = 'compile.exe'
                            bin = 'spcomp.exe'
                            error_regex = '^Compilation aborted|^\d+\s+Errors?|.*\.sp\(\d+\)\s*:\s*(?:fatal)? error (\d+)'
                        }
                        others = @{
                            wrapper = 'compile.sh'
                            bin = 'spcomp'
                            error_regex = '^Compilation aborted|^\d+\s+Errors?|.*\.sp\(\d+\)\s*:\s*(?:fatal)? error (\d+)'
                        }
                    }
                }
                # The amxmodx compiler binary always exits with exit code 0.
                # The amxmodx compiler wrapper always exits with exit code 0.
                # Hence, knowing that exit codes are not a reliable way to determine whether one or more compilation statements failed, we are going to use a regex on the stdout as a more reliable way to detect compilation errors, regardless of whether compilation was performed via the compiler binary or via the compiler wrapper.
                amxmodx = @{
                    script_ext = '.sma'
                    plugin_ext = '.amxx'
                    compiled_dir_name = 'compiled'
                    plugins_dir_name = 'plugins'
                    compiler = @{
                        windows = @{
                            wrapper = 'compile.exe'
                            bin = 'amxxpc.exe'
                            error_regex = '^\d+\s+Errors?|compile failed|^.*\.sma\(\d+\)\s*:\s*error (\d+)'
                        }
                        others = @{
                            wrapper = 'compile.sh'
                            bin = 'amxxpc'
                            error_regex = '^\d+\s+Errors?|compile failed|^.*\.sma\(\d+\)\s*:\s*error (\d+)'
                        }
                    }
                }
            }
            $OS = if ($env:OS -eq 'Windows_NT') { 'windows' } else { 'others' }
            $COMPILER_NAME = if ($PSBoundParameters['SkipWrapper']) { $MOD[$MOD_NAME]['compiler'][$OS]['bin'] } else { $MOD[$MOD_NAME]['compiler'][$OS]['wrapper'] }
            $SCRIPTING_DIR = $sourceFile.DirectoryName
            $COMPILED_DIR = Join-Path $SCRIPTING_DIR $MOD[$MOD_NAME]['compiled_dir_name']
            $COMPILER_PATH = Join-Path $SCRIPTING_DIR $COMPILER_NAME
            $PLUGINS_DIR = Join-Path (Split-Path $SCRIPTING_DIR -Parent) $MOD[$MOD_NAME]['plugins_dir_name']

            # Verify the presence of the compiler item
            $compiler = Get-Item -Path $COMPILER_PATH -ErrorAction SilentlyContinue
            if (!$compiler) {
                throw "Cannot find the plugin compiler at the path '$COMPILER_PATH'."
            }

        }catch {
            Write-Error -Exception $_.Exception -Message $_.Exception.Message -Category $_.CategoryInfo.Category -TargetObject $_.TargetObject
        }

    }process {
        try {
            "Compiler: '$($compiler.FullName)'" | Write-Host

            # Get all items in compiled directory before compilation by hash
            $compiledDirItemsPre = Get-ChildItem -Path $COMPILED_DIR -File -Recurse -Force | ? { $_.Extension -eq $MOD[$MOD_NAME]['plugin_ext'] } | Select-Object *, @{name='md5'; expression={(Get-FileHash -Path $_.Fullname -Algorithm MD5).Hash}}

            # Generate command line arguments
            $epoch = [Math]::Floor([decimal](Get-Date(Get-Date).ToUniversalTime()-uformat "%s"))
            $stdInFile = Join-Path $SCRIPTING_DIR ".$epoch"
            $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) (New-Guid).Guid
            $stdoutFile = Join-Path $tempDir 'stdout'
            $stderrFile = Join-Path $tempDir 'stderr'
            $processArgs = @{
                FilePath = $compiler.FullName
                ArgumentList = @(
                    if ($PSBoundParameters['SkipWrapper']) {
                        $sourceFile.Name
                        "-o$($MOD[$MOD_NAME]['compiled_dir_name'])/$($sourceFile.Basename)$($MOD[$MOD_NAME]['plugin_ext'])"
                    }else {
                        $sourceFile.Name
                    }
                )
                WorkingDirectory = $SCRIPTING_DIR
                RedirectStandardInput = $stdInFile
                RedirectStandardOutput = $stdoutFile
                RedirectStandardError = $stderrFile
                Wait = $true
                NoNewWindow = $true
                PassThru = $true
            }

            # Prepare compilation environment
            if ($item = New-Item -Path $stdInFile -ItemType File -Force) {
                # This dummy input bypasses the 'Press any key to continue' prompt of the compiler
                '1' | Out-File -FilePath $item.FullName -Force -Encoding utf8
            }
            New-Item $tempDir -ItemType Directory -Force > $null
            New-Item -Path $COMPILED_DIR -ItemType Directory -Force | Out-Null

            # Begin compilation
            "Compiling..." | Write-Host -ForegroundColor Cyan
            if ($PSBoundParameters['SkipWrapper']) { "Compiling $($sourceFile.Name)..." | Write-Host -ForegroundColor Yellow }

            # Compile
            $global:LASTEXITCODE = 0
            $p = Start-Process @processArgs
            $stdout = Get-Content $stdoutFile
            $stdout | Write-Host
            $stderr = Get-Content $stderrFile
            $stderr | Write-Host
            foreach ($line in $stdout) {
                if ($line -match $MOD[$MOD_NAME]['compiler'][$OS]['error_regex']) {
                    $global:LASTEXITCODE = 1
                    break
                }
            }

            # Cleanup
            Remove-Item $stdInFile -Force
            Remove-Item $tempDir -Recurse -Force

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

            # Return if no items in the compiled directory have changed
            if (!$compiledDirItemsDiff) {
                "`nNo changes to plugins were found. No operations were performed." | Write-Host -ForegroundColor Magenta
                return

            }else {
                # List successfully compiled plugins
                "`nNewly compiled plugins:" | Write-Host -ForegroundColor Cyan
                $compiledDirItemsDiff | % {
                    $compiledPluginHash = (Get-FileHash -Path $_.FullName -Algorithm MD5).Hash
                    "    $($_.Name), $($_.LastWriteTime), $compiledPluginHash" | Write-Host -ForegroundColor White
                }

                # Prepare to install the plugin
                New-Item -Path $PLUGINS_DIR -ItemType Directory -Force | Out-Null
                $installationFailure = $false

                $compiledDirItemsDiff | % {
                    # Display info for the compiled plugin
                    "`n$($_.Name):" | Write-Host -ForegroundColor Green
                    if ($_.Basename -ne $sourceFile.Basename) {
                        "    The plugin's name does not match the specified script's name. The plugin will not copied to the plugins directory." | Write-Host -ForegroundColor Yellow
                        return  # continue in %
                    }

                    # Check for an existing plugin
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
                    $updatedPlugin = Get-Item -Path "$PLUGINS_DIR/$($_.Name)" -ErrorAction SilentlyContinue
                    if (!$updatedPlugin) { "`n    Plugin does not exist in the plugins directory." | Write-Host -ForegroundColor Magenta; return }
                    $updatedPluginHash = (Get-FileHash -Path $updatedPlugin -Algorithm MD5).Hash
                    if ($updatedPluginHash -eq $compiledPluginHash) { "`n    Plugin successfully copied to '$($updatedPlugin.FullName)'" | Write-Host -ForegroundColor Green }
                    else { "`n    Failed to update existing plugin in the plugins directory." | Write-Host -ForegroundColor Magenta; return }
                }

                # Throw an error if the copying process failed
                if ($installationFailure) {
                    throw "Failed to install the specified plugin."
                }
            }

        }catch {
            Write-Error -Exception $_.Exception -Message $_.Exception.Message -Category $_.CategoryInfo.Category -TargetObject $_.TargetObject
        }finally {
            "End of Compile-SourceScript." | Write-Host -ForegroundColor Cyan
        }
    }

}
