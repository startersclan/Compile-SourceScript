[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

# Install Pester if needed
"Checking Pester version" | Write-Host
$pesterMinimumVersion = [version]'4.0.0'
$pester = Get-Module 'Pester' -ListAvailable -ErrorAction SilentlyContinue
if (!$pester -or !($pester.Version -gt $pesterMinimumVersion)) {
    "Installing Pester" | Write-Host
    Install-Module -Name 'Pester' -Repository 'PSGallery' -MinimumVersion $pesterMinimumVersion -Scope CurrentUser -Force
}
Get-Module Pester -ListAvailable

Set-StrictMode -Off
if ($IsLinux) {
    $provisionScript = {
        bash -e -c "$shellScript" | Write-Host
        if ($LASTEXITCODE) { throw "An error occurred." }
    }
    # Install lib32stdc++6
    $shellScript = @"
echo 'Installing lib32stdc++6'
if ! dpkg -l lib32stdc++6; then
    apt-get update && apt-get install -y lib32stdc++6
fi
"@
    & $provisionScript
}
Set-StrictMode -Version Latest
