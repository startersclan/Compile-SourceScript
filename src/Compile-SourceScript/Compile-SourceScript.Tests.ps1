Describe "Compile-SourceScript" -Tag 'Integration' {
    BeforeAll {
    }
    BeforeEach {
    }
    AfterEach {
    }
    It "[sourcemod] Compile-SourceScript -Force (good plugin)" {
        $cmd = "Compile-SourceScript"
        $cmdArgs = @{
            File = ".\mod\sourcemod\addons\sourcemod\scripting\plugin1.sp"
            Force = $true
        }
        $iterations = 2
        $expectedExitCode = 0
        for ($i=0; $i -le $iterations-1; $i++) {
            "Iteration: $($i+1)" | Write-Host
            & $cmd @cmdArgs
            if ($LASTEXITCODE -ne $expectedExitCode) {
                throw "Expected exit code $expectedExitCode but got exit code $LASTEXITCODE"
            }
            "Expected exit code: $expectedExitCode, Exit code: $LASTEXITCODE" | Write-Host -ForegroundColor Yellow
        }
    }
    It "[sourcemod] Compile-SourceScript -Force (bad plugin)" {
        $cmd = "Compile-SourceScript"
        $cmdArgs = @{
            File = ".\mod\sourcemod\addons\sourcemod\scripting\plugin1_bad.sp"
            Force = $true
        }
        $iterations = 2
        $expectedExitCode = 1
        for ($i=0; $i -le $iterations-1; $i++) {
            "Iteration: $($i+1)" | Write-Host
            & $cmd @cmdArgs
            if ($LASTEXITCODE -ne $expectedExitCode) {
                throw "Expected exit code $expectedExitCode but got exit code $LASTEXITCODE"
            }
            "Expected exit code: $expectedExitCode, Exit code: $LASTEXITCODE" | Write-Host -ForegroundColor Yellow
        }
    }
    It "[sourcemod] Compile-SourceScript -Force -SkipWrapper (good plugin)" {
        $cmd = "Compile-SourceScript"
        $cmdArgs = @{
            File = ".\mod\sourcemod\addons\sourcemod\scripting\plugin2.sp"
            Force = $true
            SkipWrapper = $true
        }
        $iterations = 2
        $expectedExitCode = 0
        for ($i=0; $i -le $iterations-1; $i++) {
            "Iteration: $($i+1)" | Write-Host
            & $cmd @cmdArgs
            if ($LASTEXITCODE -ne $expectedExitCode) {
                throw "Expected exit code $expectedExitCode but got exit code $LASTEXITCODE"
            }
            "Expected exit code: $expectedExitCode, Exit code: $LASTEXITCODE" | Write-Host -ForegroundColor Yellow
        }
    }
    It "[sourcemod] Compile-SourceScript -Force -SkipWrapper (bad plugin)" {
        $cmd = "Compile-SourceScript"
        $cmdArgs = @{
            File = ".\mod\sourcemod\addons\sourcemod\scripting\plugin2_bad.sp"
            Force = $true
            SkipWrapper = $true
        }
        $iterations = 2
        $expectedExitCode = 1
        for ($i=0; $i -le $iterations-1; $i++) {
            "Iteration: $($i+1)" | Write-Host
            & $cmd @cmdArgs
            if ($LASTEXITCODE -ne $expectedExitCode) {
                throw "Expected exit code $expectedExitCode but got exit code $LASTEXITCODE"
            }
            "Expected exit code: $expectedExitCode, Exit code: $LASTEXITCODE" | Write-Host -ForegroundColor Yellow
        }
    }
    if ($env:OS -eq 'Windows_NT') {
        It "[amxmodx] Compile-SourceScript -Force (good plugin)" {
            $cmd = "Compile-SourceScript"
            $cmdArgs = @{
                File = ".\mod\amxmodx\addons\amxmodx\scripting\plugin1.sma"
                Force = $true
            }
            $iterations = 2
            $expectedExitCode = 0
            for ($i=0; $i -le $iterations-1; $i++) {
                "Iteration: $($i+1)" | Write-Host
                & $cmd @cmdArgs
                if ($LASTEXITCODE -ne $expectedExitCode) {
                    throw "Expected exit code $expectedExitCode but got exit code $LASTEXITCODE"
                }
                "Expected exit code: $expectedExitCode, Exit code: $LASTEXITCODE" | Write-Host -ForegroundColor Yellow
            }
        }
        It "[amxmodx] Compile-SourceScript -Force (bad plugin)" {
            $cmd = "Compile-SourceScript"
            $cmdArgs = @{
                File = ".\mod\amxmodx\addons\amxmodx\scripting\plugin1_bad.sma"
                Force = $true
            }
            $iterations = 2
            $expectedExitCode = 1
            for ($i=0; $i -le $iterations-1; $i++) {
                "Iteration: $($i+1)" | Write-Host
                & $cmd @cmdArgs
                if ($LASTEXITCODE -ne $expectedExitCode) {
                    throw "Expected exit code $expectedExitCode but got exit code $LASTEXITCODE"
                }
                "Expected exit code: $expectedExitCode, Exit code: $LASTEXITCODE" | Write-Host -ForegroundColor Yellow
            }
        }
    }
    It "[amxmodx] Compile-SourceScript -Force -SkipWrapper (good plugin)" {
        $cmd = "Compile-SourceScript"
        $cmdArgs = @{
            File = ".\mod\amxmodx\addons\amxmodx\scripting\plugin2.sma"
            Force = $true
            SkipWrapper = $true
        }
        $iterations = 2
        $expectedExitCode = 0
        for ($i=0; $i -le $iterations-1; $i++) {
            "Iteration: $($i+1)" | Write-Host
            & $cmd @cmdArgs
            if ($LASTEXITCODE -ne $expectedExitCode) {
                throw "Expected exit code $expectedExitCode but got exit code $LASTEXITCODE"
            }
            "Expected exit code: $expectedExitCode, Exit code: $LASTEXITCODE" | Write-Host -ForegroundColor Yellow
        }
    }
    It "[amxmodx] Compile-SourceScript -Force -SkipWrapper (bad plugin)" {
        $cmd = "Compile-SourceScript"
        $cmdArgs = @{
            File = ".\mod\amxmodx\addons\amxmodx\scripting\plugin2_bad.sma"
            Force = $true
            SkipWrapper = $true
        }
        $iterations = 2
        $expectedExitCode = 1
        for ($i=0; $i -le $iterations-1; $i++) {
            "Iteration: $($i+1)" | Write-Host
            & $cmd @cmdArgs
            if ($LASTEXITCODE -ne $expectedExitCode) {
                throw "Expected exit code $expectedExitCode but got exit code $LASTEXITCODE"
            }
            "Expected exit code: $expectedExitCode, Exit code: $LASTEXITCODE" | Write-Host -ForegroundColor Yellow
        }
    }
}
