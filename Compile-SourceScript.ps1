param(
    [Parameter(Mandatory=$False)]
    $File
,
    [Parameter(Mandatory=$False)]
    [switch]$Force
)

function Compile-SourceScript {
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
        $PLUGIN_EXTS = '.amxx', '.smx'
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

            Write-Host "Running compile wrapper" -ForegroundColor Cyan

            # Normalize paths
            $scriptingDir = $script.DirectoryName
            $compiledDir = Join-Path $scriptingDir $COMPILED_DIR_NAME
            $pluginsDir = Join-Path (Split-Path $scriptingDir -Parent) $PLUGINS_DIR_NAME

            # Validate compiler binary
            $compilerItem = Get-Item -Path (Join-Path $scriptingDir $COMPILE_WRAPPER_NAME)
            Write-Host "Compiler: $($compilerItem.FullName)"

            # Get all items in compiled folder before compilation by hash
            $compiledDirItemsPre = Get-ChildItem $compiledDir -Recurse -Force | ? { $_.Extension -in $PLUGIN_EXTS } | Select-Object *, @{name='md5'; expression={(Get-FileHash $_.Fullname -Algorithm MD5).hash}}

            # Run the compiler
            Write-Host "Compiling..." -ForegroundColor Cyan
            $epoch = [Math]::Floor([decimal](Get-Date(Get-Date).ToUniversalTime()-uformat "%s"))
            $stdInFile = New-Item -Path (Join-Path $scriptingDir ".$epoch") -ItemType File -Force
            '1' | Out-File -FilePath $stdInFile.FullName -Force -Encoding utf8
            Start-Process $compilerItem.FullName -ArgumentList $script.Name -WorkingDirectory $scriptingDir -RedirectStandardInput $stdInFile.FullName -Wait -NoNewWindow

            # Get all items in compiled folder after compilation by hash
            $compiledDirItemsPost = Get-ChildItem $compiledDir -Recurse -Force | ? { $_.Extension -in $PLUGIN_EXTS } | Select-Object *, @{name='md5'; expression={(Get-FileHash $_.FullName -Algorithm MD5).hash}}

            # Get items with differing hashes
            $compiledDirItemsDiff = if ($compiledDirItemsPost) {
                if ($compiledDirItemsPre) {
                    $hashesDiffObj = Compare-object -ReferenceObject $compiledDirItemsPre -DifferenceObject $compiledDirItemsPost -Property FullName, md5 | ? { $_.SideIndicator -eq '=>' }
                    $compiledDirItemsPost | ? { $_.md5 -in $hashesDiffObj.md5 }
                }else {
                    $compiledDirItemsPost
                }
            }

            # Copy items to plugins folder
            if ($compiledDirItemsDiff) {
                # List
                Write-Host "`nCompiled plugins:" -ForegroundColor Green
                $compiledDirItemsDiff | % {
                    $compiledPluginHash = (Get-FileHash $_.FullName -Algorithm MD5).Hash
                    Write-Host "    $($_.Name), $($_.LastWriteTime), $compiledPluginHash" -ForegroundColor Green
                }

                New-Item -Path $pluginsDir -ItemType Directory -Force | Out-Null
                $compiledDirItemsDiff | % {
                    if ($_.Basename -ne $script.Basename) {
                        Write-Host "`nThe scripts name does not match the compiled plugin's name." -ForegroundColor Magenta
                        return  # continue in %
                    }
                    $existingPlugin = Get-Item "$pluginsDir/$($_.Name)" -ErrorAction SilentlyContinue
                    if (!$existingPlugin) {
                        Write-Host "`nPlugin does not currently exist in the plugins directory." -ForegroundColor Yellow
                    }else {
                        $compiledPluginHash = (Get-FileHash $_.FullName -Algorithm MD5).Hash
                        $existingPluginHash = (Get-FileHash $existingPlugin -Algorithm MD5).Hash
                        Write-Host "`nExisting plugin:    $($existingPlugin.Name), $($existingPlugin.LastWriteTime), $existingPluginHash" -ForegroundColor Yellow
                        Write-Host "Compiled plugin:    $($_.Name), $($_.LastWriteTime), $compiledPluginHash" -ForegroundColor Green
                    }
                    Copy-Item -Path $_.FullName -Destination $pluginsDir -Recurse @copyParams
                    if ($LASTEXITCODE) { Write-Host 'Plugin copy error.' -ForegroundColor Magenta; return }
                    $updatedPlugin = Get-Item "$pluginsDir/$($_.Name)"
                    $updatedPluginHash = (Get-FileHash $updatedPlugin -Algorithm MD5).Hash
                    if ($updatedPluginHash -eq $compiledPluginHash) { Write-Host "Plugin successfully copied to $($_.Fullname)" -ForegroundColor Green }
                    else { Write-Host "Plugin has not been copied." -ForegroundColor Magenta; return }
                }
            }else {
                Write-Host `n"No new/updated plugins found. No operations were performed." -ForegroundColor Magenta
            }
        }catch {
            throw "Runtime error. `nException: $($_.Exception.Message) `nStacktrace: $($_.ScriptStackTrace)"
        }finally {
            # Cleanup
            if ($stdInFile) {
                Remove-Item $stdInFile -Force
            }
            Write-Host "End of compile wrapper." -ForegroundColor Cyan
        }
    }
}

$params = @{
    File = $File
    Force = $Force
}
Compile-SourceScript @params