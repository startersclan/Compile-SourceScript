[CmdletBinding()]
param()

$ErrorActionPreference = 'Continue'
$VerbosePreference = 'Continue'

$failedCount = 0

$functionTestScriptBlock = {
    try {
        "Command: $script:cmd" | Write-Verbose
        "Args:" | Write-Verbose
        $script:cmdArgs | Out-String -Stream | % { $_.Trim() } | ? { $_ } | Write-Verbose
        for ($i=0; $i -le $script:iterations-1; $i++) {
            "Iteration: $($i+1)" | Write-Host
            & $script:cmd @script:cmdArgs
            if ($global:LASTEXITCODE -ne $script:expectedExitCode) {
                throw "Expected exit code $script:expectedExitCode but got exit code $global:LASTEXITCODE"
            }
            "Expected exit code: $script:expectedExitCode, Exit code: $global:LASTEXITCODE" | Write-Host -ForegroundColor Yellow
        }
    }catch {
        $_ | Write-Error
        $script:failedCount++
    }
}

# Function: Compile-SourceScript
$cmd = "Compile-SourceScript"

#############
# SourceMod #
#############

"`n[sourcemod] Compile plugin via wrapper, good plugin" | Write-Host
$cmdArgs = @{
    File = "$PSScriptRoot\..\..\mod\sourcemod\addons\sourcemod\scripting\plugin1.sp"
    Force = $true
}
$iterations = 2
$expectedExitCode = 0
& $functionTestScriptBlock

"`n[sourcemod] Compile plugin via wrapper, bad plugin" | Write-Host
$cmdArgs = @{
    File = "$PSScriptRoot\..\..\mod\sourcemod\addons\sourcemod\scripting\plugin1_bad.sp"
    Force = $true
}
$iterations = 2
$expectedExitCode = 1
& $functionTestScriptBlock

"`n[sourcemod] Compile plugin via compiler, good plugin" | Write-Host
$cmdArgs = @{
    File = "$PSScriptRoot\..\..\mod\sourcemod\addons\sourcemod\scripting\plugin2.sp"
    Force = $true
    SkipWrapper = $true
}
$iterations = 2
$expectedExitCode = 0
& $functionTestScriptBlock

"`n[sourcemod] Compile plugin via compiler, bad plugin" | Write-Host
$cmdArgs = @{
    File = "$PSScriptRoot\..\..\mod\sourcemod\addons\sourcemod\scripting\plugin2_bad.sp"
    Force = $true
    SkipWrapper = $true
}
$iterations = 2
$expectedExitCode = 1
& $functionTestScriptBlock

#############
# AMX Mod X #
#############

"`n[amxmodx] Compile plugin via wrapper, good plugin" | Write-Host
# The following test should be run only for Windows, reason being that the non-Windows version:
# - Does not take in arguments, instead compiles all plugins within the scripting directory
# - Displays all the output using 'less' at the end of the compilation, thus is limited to interactive use
if ($env:OS -eq 'Windows_NT') {
    $cmdArgs = @{
        File = "$PSScriptRoot\..\..\mod\amxmodx\addons\amxmodx\scripting\plugin1.sma"
        Force = $true
    }
    $expectedExitCode = 0
    $iterations = 2
    & $functionTestScriptBlock

    "`n[amxmodx] Compile plugin via wrapper, bad plugin" | Write-Host
    $cmdArgs = @{
        File = "$PSScriptRoot\..\..\mod\amxmodx\addons\amxmodx\scripting\plugin1_bad.sma"
        Force = $true
    }
    $expectedExitCode = 1
    $iterations = 2
    & $functionTestScriptBlock
}else { "Skipping: Test only applicable to Windows." | Write-Host }

"`n[amxmodx] Compile plugin via compiler, good plugin" | Write-Host
$cmdArgs = @{
    File = "$PSScriptRoot\..\..\mod\amxmodx\addons\amxmodx\scripting\plugin2.sma"
    Force = $true
    SkipWrapper = $true
}
$expectedExitCode = 0
$iterations = 2
& $functionTestScriptBlock

"`n[amxmodx] Compile plugin via compiler, bad plugin" | Write-Host
$cmdArgs = @{
    File = "$PSScriptRoot\..\..\mod\amxmodx\addons\amxmodx\scripting\plugin2_bad.sma"
    Force = $true
    SkipWrapper = $true
}
$expectedExitCode = 1
$iterations = 2
& $functionTestScriptBlock

###########
# Results #
###########
if ($failedCount -gt 0) {
    "$failedCount tests failed." | Write-Warning
}
$failedCount
