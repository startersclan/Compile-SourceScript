[CmdletBinding()]
param()

$ErrorActionPreference = 'Continue'
$VerbosePreference = 'Continue'

$failedCount = 0

"Function: Compile-SourceScript" | Write-Host
$functionTestScriptBlock = {
    try {
        Compile-SourceScript @cmdArgs
    }catch {
        $_ | Write-Error
        $failedCount++
    }
}

#############
# SourceMod #
#############

"`n[sourcemod] Compile plugin via wrapper" | Write-Host
$cmdArgs = @{
    File = '..\test\mod\sourcemod\addons\sourcemod\scripting\plugin1.sp' | Convert-Path
    Force = $true
}
$cmdArgs | Out-String -Stream | ? { $_ } | Write-Verbose
1..2 | % { "Iteration: $_" | Write-Host; & $functionTestScriptBlock }


"`n[sourcemod] Compile plugin via compiler" | Write-Host
$cmdArgs = @{
    File = '..\test\mod\sourcemod\addons\sourcemod\scripting\plugin2.sp' | Convert-Path
    Force = $true
    SkipWrapper = $true
}
$cmdArgs | Out-String -Stream | ? { $_ } | Write-Verbose
1..2 | % { "Iteration: $_" | Write-Host; & $functionTestScriptBlock }


#############
# AMX Mod X #
#############

"`n[amxmodx] Compile plugin via wrapper" | Write-Host
# The following test should be run only for Windows, reason being that the non-Windows version:
# - Does not take in arguments, instead compiles all plugins within the scripting directory
# - Displays all the output using 'less' at the end of the compilation, thus is limited to interactive use
if ($env:OS) {
    $cmdArgs = @{
        File = '..\test\mod\amxmodx\addons\amxmodx\scripting\plugin1.sma' | Convert-Path
        Force = $true
    }
    $cmdArgs | Out-String -Stream | ? { $_ } | Write-Verbose
    1..2 | % { "Iteration: $_" | Write-Host; & $functionTestScriptBlock }
}else { "Skipping: Test only applicable to Windows." | Write-Host }

"`n[amxmodx] Compile plugin via compiler" | Write-Host
$cmdArgs = @{
    File = '..\test\mod\amxmodx\addons\amxmodx\scripting\plugin2.sma' | Convert-Path
    Force = $true
    SkipWrapper = $true
}
$cmdArgs | Out-String -Stream | ? { $_ } | Write-Verbose
1..2 | % { "Iteration: $_" | Write-Host; & $functionTestScriptBlock }


###########
# Results #
###########
if ($failedCount -gt 0) {
    "$failedCount tests failed." | Write-Warning
}
$failedCount
