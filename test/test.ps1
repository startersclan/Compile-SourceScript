[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [string]$Tag
)

Set-StrictMode -Version Latest
$script:PesterDebugPreference_ShowFullErrors = $true

try {
    Push-Location $PSScriptRoot

    # Process variables
    $moduleManifest = Get-Item ../src/*/*.psd1 -ErrorAction SilentlyContinue
    $scriptModule = Get-Item ../src/*/*.psm1 -ErrorAction SilentlyContinue
    $moduleItem = if ($moduleManifest) { $moduleManifest }
                   elseif ($scriptModule) { $scriptModule }
                   else { throw "Unable to locate module manifest file (.psd1) nor script module file (.psm1)." }
    $MODULE_PATH = $moduleItem.FullName
    $MODULE_DIR = $moduleItem.Directory

    # Install Pester if needed
    "Checking Pester version" | Write-Host
    $pesterMinimumVersion = [version]'4.0.0'
    $pesterMaximumVersion = [version]'4.10.1'
    $pester = Get-Module Pester -ListAvailable -ErrorAction SilentlyContinue
    if (!$pester -or !($pester | ? { $_.Version -ge $pesterMinimumVersion -and $_.Version -le $pesterMaximumVersion })) {
        "Installing Pester" | Write-Host
        Install-Module -Name Pester -Repository PSGallery -MinimumVersion $pesterMinimumVersion -MaximumVersion $pesterMaximumVersion -Scope CurrentUser -Force -SkipPublisherCheck
    }
    $pester = Get-Module Pester -ListAvailable
    $pester | Out-String | Write-Verbose
    $pester | ? { $_.Version -ge $pesterMinimumVersion -and $_.Version -le $pesterMaximumVersion } | Select-Object -First 1 | Import-Module -Force # Force import the latest version within the defined range to ensure environment uses the correct version of Pester

    # Install linux dependencies
    if ($env:OS -ne 'Windows_NT') {
        if ($IsLinux) {
            "Installing dependencies for linux" | Write-Host

            # Provisioning script block
            $provisionScriptBlock = {
                $sudo = sh -c 'command -v sudo'
                $shellBin = sh -c 'command -v bash || command -v sh'
                $sudo | Write-Host
                $shellBin | Write-Host
                "Shell command:" | Write-Verbose
                $script:shellArgs | Write-Verbose
                if ($sudo) {
                    'Executing command with sudo' | Write-Host
                    & $sudo $shellBin @script:shellArgs | Write-Host
                }else {
                    & $shellBin @script:shellArgs | Write-Host
                }
                if ($LASTEXITCODE) { throw "An error occurred." }
            }

            $shellArgs = @(
                'scripts/dep/linux/sourcepawn-dependencies.sh'
            )
            & $provisionScriptBlock
        }
    }

    # Import the project module
    Import-Module $MODULE_PATH -Force

    if ($Tag) {
        # Run Unit Tests
        $res = Invoke-Pester -Script $MODULE_DIR -Tag $Tag -PassThru -ErrorAction Stop
        if (!($res.PassedCount -eq $res.TotalCount)) {
            "$($res.TotalCount - $res.PassedCount) unit tests did not pass." | Write-Host
        }
        if (!($res.PassedCount -eq $res.TotalCount)) {
            throw
        }
    }else {
        # Run Unit Tests
        $res = Invoke-Pester -Script $MODULE_DIR -Tag 'Unit' -PassThru -ErrorAction Stop
        if (!($res.PassedCount -eq $res.TotalCount)) {
            "$($res.TotalCount - $res.PassedCount) unit tests did not pass." | Write-Host
        }

        # Run Integration Tests
        $res2 = Invoke-Pester -Script $MODULE_DIR -Tag 'Integration' -PassThru -ErrorAction Stop
        if (!($res2.PassedCount -eq $res2.TotalCount)) {
            "$($res2.TotalCount - $res2.PassedCount) integration tests did not pass." | Write-Host
        }

        if (!($res.PassedCount -eq $res.TotalCount) -or !($res2.PassedCount -eq $res2.TotalCount)) {
            throw
        }
    }

}catch {
    throw
}finally {
    "Listing test artifacts" | Write-Host
    Push-Location (git rev-parse --show-toplevel)
    git ls-files --others --exclude-standard
    Pop-Location

    Pop-Location
}
