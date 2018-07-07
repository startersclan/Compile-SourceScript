param(
    [Parameter(Mandatory=$False)]
    $File
)

function Compile-SourceScript {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$False)]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
        $File
    )

    # Process script
    $script = Get-Item -Path $File
    $script_exts = '.sp', '.sma'
    if ($script_exts -notcontains $script.Extension) {
        throw "File is not a .sp or .sma source file."
    }

    try {
        Write-Host "Running compile wrapper" -ForegroundColor Cyan

        # Define variables
        $scripting_dir = $script.DirectoryName
        $compile_bin_name = 'compile.exe'
        $compile_core_items_names = 'compile.exe','spcomp.exe','compile.dat','amxxpc','amxxpc.exe','amxxpc_osx','amxxpc32.dll','compile.sh'
        $compile_bin = Get-Item -Path (Join-Path $scripting_dir $compile_bin_name)
        $compiled_dir_name = 'compiled'
        $compiled_dir = Join-Path $scripting_dir $compiled_dir_name
        $temp_scripting_dir_name = 'scripting.tempmove'
        $temp_scripting_dir = Join-Path $scripting_dir $temp_scripting_dir_name
        $plugins_dir_name = 'plugins'
        $plugins_dir = Join-Path (Split-Path $scripting_dir -Parent) $plugins_dir_name

        #Write-Host "Directory: $scripting_dir" -ForegroundColor Yellow
        Write-Host "Compiler: $($compile_bin.FullName)" -ForegroundColor Yellow

        # Get and move all items except script and compile core items to temp scripting folder
        $items_excluded = Get-ChildItem -Path $scripting_dir -File | ? { $compile_core_items_names -notcontains $_.Name -And $script.Name -ne $_.Name }
        if ($items_excluded) {
            New-Item -Path $temp_scripting_dir -ItemType Directory -Force | Out-Null
            Move-Item -Path $items_excluded.FullName -Destination $temp_scripting_dir
        }

        # Get all items in compiled folder before compilation by hash
        $compiled_items_pre = Get-ChildItem $compiled_dir -Recurse -Force | select *, @{name='md5'; expression={(Get-FileHash $_.fullname -Algorithm MD5).hash}}

        # Run the compiler
        Write-Host "Compiling..." -ForegroundColor Cyan
        Start-Process -Wait $compile_bin.FullName -WorkingDirectory $scripting_dir

        # Move all other items back to scripting folder
        $items_excluded = Get-ChildItem -Path $temp_scripting_dir -File
        if ($items_excluded) {
            Move-Item -Path $items_excluded.FullName -Destination $scripting_dir
            Remove-Item -Path $temp_scripting_dir
        }

        # Get all items in compiled folder after compilation by hash
        $compiled_items_post = Get-ChildItem $compiled_dir -Recurse -Force | select *, @{name='md5'; expression={(Get-FileHash $_.fullname -Algorithm MD5).hash}}

        # Get items with differing hashes
        $hashes_diff_obj = Compare-object -ReferenceObject $compiled_items_pre.md5 -DifferenceObject $compiled_items_post.md5 #| % { $compiled_items_post | ? { $_.md }
        $compiled_items_diff = $compiled_items_post | ? { $hashes_diff_obj.inputobject -contains $_.md5 }

        if ($compiled_items_diff) {
            Write-Host "New/Updated plugins:" -ForegroundColor Green
            #$compiled_items_diff | select *
            $compiled_items_diff | Format-Table Name, LastWriteTime
            # Copy items to plugins folder
            New-Item -Path $plugins_dir -ItemType Directory -Force | Out-Null
            $compiled_items_diff | % { Copy-Item -Path $_.FullName -Destination $plugins_dir -Recurse -Confirm }
        }else {
            Write-Host "No new/updated plugins found. No items were copied." -ForegroundColor Magenta
        }
    }catch {
        throw "Runtime error. `nException: $($_.Exception.Message) `nStacktrace: $($_.ScriptStackTrace)"
    }finally {
        Write-Host "`nEnd of compile wrapper." -ForegroundColor Cyan
    }

}

Compile-SourceScript -File $File