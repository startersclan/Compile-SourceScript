[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$VerbosePreference = 'Continue'
$global:PesterDebugPreference_ShowFullErrors = $true

try {
    Push-Location $PSScriptRoot

    # Install test dependencies
    "Installing test dependencies" | Write-Host
    & "$PSScriptRoot\scripts\dep\Install-TestDependencies.ps1" > $null

    # Import the project module
    Import-Module "../src/Compile-SourceScript/Compile-SourceScript.psm1" -Force

    # Run unit tests
    "Running unit tests" | Write-Host
    $testFailed = $false
    $unitResult = Invoke-Pester -Script "$PSScriptRoot\..\src\Compile-SourceScript" -Tag 'Unit' -PassThru
    if ($unitResult.FailedCount -gt 0) {
        "$($unitResult.FailedCount) tests failed." | Write-Warning
        $testFailed = $true
    }

    # Run integration tests
    "Running integration tests" | Write-Host
    $integratedFailedCount = Invoke-Pester -Script "$PSScriptRoot\..\src\Compile-SourceScript" -Tag 'Integration' -PassThru
    if ($integratedFailedCount.FailedCount -gt 0) {
        "$($integratedFailedCount.FailedCount) tests failed." | Write-Warning
        $testFailed = $true
    }

    "Listing test artifacts" | Write-Host
    git ls-files --others --exclude-standard

    "End of tests" | Write-Host
    if ($testFailed) {
        throw "One or more tests failed."
    }
}catch {
    throw
}finally {
    Pop-Location
}
