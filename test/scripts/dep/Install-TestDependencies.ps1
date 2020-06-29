[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

try {
    Push-Location $PSScriptRoot

    # Install Pester if needed
    "Checking Pester version" | Write-Host
    $pesterMinimumVersion = [version]'4.0.0'
    $pesterMaximumVersion = [version]'4.10.1'
    $pester = Get-Module 'Pester' -ListAvailable -ErrorAction SilentlyContinue
    if (!$pester -or !($pester.Version -ge $pesterMinimumVersion) -or !($pester.Version -le $pesterMaximumVersion)) {
        "Installing Pester" | Write-Host
        Install-Module -Name 'Pester' -Repository 'PSGallery' -MinimumVersion $pesterMinimumVersion -MaximumVersion $pesterMaximumVersion -Scope CurrentUser -Force
    }
    Get-Module Pester -ListAvailable | Out-String | Write-Verbose

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

            # Install linux dependencies
            $shellArgs = @(
                'linux/sourcepawn-dependencies.sh'
            )
            & $provisionScriptBlock
        }
    }

}catch {
    throw
}finally{
    Pop-Location
}
