<#
.SYNOPSIS
    Windows 环境一键运行所有语言版本的 show_code
.DESCRIPTION
    依次运行 Python / JavaScript / C# (自包含离线包) / C / Go / 汇编版本，
    记录每个版本的执行结果并生成测试报告。
    C# 使用 deps/dotnet-win-x64 自包含发布包，无需安装 .NET 运行时。
#>

param(
    [string]$ReportPath = "$PSScriptRoot\test-report-windows.md"
)

$ErrorActionPreference = "Continue"
$BaseDir = $PSScriptRoot
$Expected = "Talk is cheap. Show me the code."
$Results = @()

# Ensure toolchain paths are available (installed via choco / manual)
$ToolPaths = @(
    "C:\ProgramData\mingw64\mingw64\bin",
    "C:\Program Files\NASM",
    "C:\go\go\bin",
    "C:\jdk21\jdk-21.0.5\bin"
)
foreach ($tp in $ToolPaths) {
    if ((Test-Path $tp) -and ($env:PATH -notlike "*$tp*")) {
        $env:PATH = "$tp;$env:PATH"
    }
}

function Invoke-TestCase {
    param(
        [string]$Name,
        [string]$ExePath,
        [string]$Arguments = "",
        [string]$WorkingDir = $BaseDir
    )

    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $output = ""
    $exitCode = 0
    $status = "PASS"

    try {
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $ExePath
        if ($Arguments) { $psi.Arguments = $Arguments }
        $psi.UseShellExecute = $false
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $psi.WorkingDirectory = $WorkingDir
        $psi.StandardOutputEncoding = [System.Text.Encoding]::UTF8

        $proc = [System.Diagnostics.Process]::Start($psi)
        $stdout = $proc.StandardOutput.ReadToEnd()
        $stderr = $proc.StandardError.ReadToEnd()
        $proc.WaitForExit(60000) | Out-Null
        $exitCode = $proc.ExitCode
        $stopwatch.Stop()

        $output = $stdout.Trim()
        if ($exitCode -ne 0) {
            $status = "FAIL (exit $exitCode)"
        }
        if ($output -ne $Expected) {
            $status = "FAIL (output mismatch)"
        }
    }
    catch {
        $stopwatch.Stop()
        $status = "ERROR: $($_.Exception.Message)"
        $output = ""
        $exitCode = -1
    }

    return [PSCustomObject]@{
        Name      = $Name
        Status    = $status
        Output    = $output
        Stderr    = ($stderr.Trim())
        ExitCode  = $exitCode
        Duration  = "{0:N0}ms" -f $stopwatch.Elapsed.TotalMilliseconds
    }
}

# Helper: run a shell command (compile+run) via cmd /c with a temp batch file
function Invoke-ShellTestCase {
    param(
        [string]$Name,
        [string]$Script
    )

    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $output = ""
    $exitCode = 0
    $status = "PASS"

    try {
        $batFile = Join-Path $env:TEMP "cheap_talk_test_$([guid]::NewGuid().ToString('N').Substring(0,8)).bat"
        $batContent = "@echo off`r`n$Script"
        $batContent | Out-File -FilePath $batFile -Encoding ascii -NoNewline

        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = "cmd.exe"
        $psi.Arguments = "/c `"$batFile`""
        $psi.UseShellExecute = $false
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $psi.WorkingDirectory = $BaseDir
        $psi.EnvironmentVariables["PATH"] = $env:PATH

        $proc = [System.Diagnostics.Process]::Start($psi)
        $stdout = $proc.StandardOutput.ReadToEnd()
        $stderr = $proc.StandardError.ReadToEnd()
        $proc.WaitForExit(60000) | Out-Null
        $exitCode = $proc.ExitCode
        $stopwatch.Stop()

        Remove-Item $batFile -Force -ErrorAction SilentlyContinue

        $output = $stdout.Trim()
        if ($exitCode -ne 0) {
            $status = "FAIL (exit $exitCode)"
        }
        if ($output -ne $Expected) {
            $status = "FAIL (output mismatch)"
        }
    }
    catch {
        $stopwatch.Stop()
        $status = "ERROR: $($_.Exception.Message)"
        $output = ""
        $exitCode = -1
    }

    return [PSCustomObject]@{
        Name      = $Name
        Status    = $status
        Output    = $output
        Stderr    = ($stderr.Trim())
        ExitCode  = $exitCode
        Duration  = "{0:N0}ms" -f $stopwatch.Elapsed.TotalMilliseconds
    }
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Cheap Talk - Windows Test Runner" -ForegroundColor Cyan
Write-Host "  $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$pyExe   = (Get-Command python -ErrorAction SilentlyContinue).Source
$nodeExe = (Get-Command node -ErrorAction SilentlyContinue).Source
$gccExe  = (Get-Command gcc -ErrorAction SilentlyContinue).Source
$goExe   = (Get-Command go -ErrorAction SilentlyContinue).Source
$nasmExe = (Get-Command nasm -ErrorAction SilentlyContinue).Source
$javaExe = (Get-Command java -ErrorAction SilentlyContinue).Source
$javacExe = (Get-Command javac -ErrorAction SilentlyContinue).Source

# 1. Python
Write-Host "[1/9] Python..." -NoNewline
if ($pyExe) {
    $r = Invoke-TestCase -Name "Python" -ExePath $pyExe -Arguments "`"$BaseDir\show_code.py`""
    $Results += $r
} else {
    $r = [PSCustomObject]@{ Name="Python"; Status="SKIP (python not installed)"; Output=""; Stderr=""; ExitCode=-1; Duration="N/A" }
    $Results += $r
}
Write-Host " $($r.Status) ($($r.Duration))" -ForegroundColor $(if($r.Status -eq 'PASS'){'Green'}else{'Red'})

# 2. JavaScript (Node.js)
Write-Host "[2/9] JavaScript..." -NoNewline
if ($nodeExe) {
    $r = Invoke-TestCase -Name "JavaScript" -ExePath $nodeExe -Arguments "`"$BaseDir\show_code.js`""
    $Results += $r
} else {
    $r = [PSCustomObject]@{ Name="JavaScript"; Status="SKIP (node not installed)"; Output=""; Stderr=""; ExitCode=-1; Duration="N/A" }
    $Results += $r
}
Write-Host " $($r.Status) ($($r.Duration))" -ForegroundColor $(if($r.Status -eq 'PASS'){'Green'}else{'Red'})

# 3. C# (self-contained)
Write-Host "[3/9] C# (self-contained)..." -NoNewline
$csExe = "$BaseDir\deps\dotnet-win-x64\csproj.exe"
if (Test-Path $csExe) {
    $r = Invoke-TestCase -Name "C#" -ExePath $csExe
    $Results += $r
} else {
    $r = [PSCustomObject]@{ Name="C#"; Status="SKIP (offline package not found)"; Output=""; Stderr=""; ExitCode=-1; Duration="N/A" }
    $Results += $r
}
Write-Host " $($r.Status) ($($r.Duration))" -ForegroundColor $(if($r.Status -eq 'PASS'){'Green'}else{'Red'})

# 4. C (needs gcc)
Write-Host "[4/9] C..." -NoNewline
if ($gccExe) {
    $null = New-Item -ItemType Directory -Path "$BaseDir\build" -Force
    $cScript = "gcc `"$BaseDir\show_code.c`" -o `"$BaseDir\build\show_code_c.exe`" && `"$BaseDir\build\show_code_c.exe`""
    $r = Invoke-ShellTestCase -Name "C" -Script $cScript
    $Results += $r
} else {
    $r = [PSCustomObject]@{ Name="C"; Status="SKIP (gcc not installed)"; Output=""; Stderr=""; ExitCode=-1; Duration="N/A" }
    $Results += $r
}
Write-Host " $($r.Status) ($($r.Duration))" -ForegroundColor $(if($r.Status -eq 'PASS'){'Green'}else{'Red'})

# 5. Go (needs go)
Write-Host "[5/9] Go..." -NoNewline
if ($goExe) {
    $goScript = "go run `"$BaseDir\show_code.go`""
    $r = Invoke-ShellTestCase -Name "Go" -Script $goScript
    $Results += $r
} else {
    $r = [PSCustomObject]@{ Name="Go"; Status="SKIP (go not installed)"; Output=""; Stderr=""; ExitCode=-1; Duration="N/A" }
    $Results += $r
}
Write-Host " $($r.Status) ($($r.Duration))" -ForegroundColor $(if($r.Status -eq 'PASS'){'Green'}else{'Red'})

# 6. Assembly (needs nasm + gcc linker)
Write-Host "[6/9] Assembly..." -NoNewline
if ($nasmExe -and $gccExe) {
    $null = New-Item -ItemType Directory -Path "$BaseDir\build" -Force
    $asmScript = "nasm -f win64 `"$BaseDir\show_code_win.asm`" -o `"$BaseDir\build\show_code_win.obj`" && gcc `"$BaseDir\build\show_code_win.obj`" -o `"$BaseDir\build\show_code_asm.exe`" && `"$BaseDir\build\show_code_asm.exe`""
    $r = Invoke-ShellTestCase -Name "Assembly" -Script $asmScript
    $Results += $r
} else {
    $r = [PSCustomObject]@{ Name="Assembly"; Status="SKIP (nasm/gcc not installed)"; Output=""; Stderr=""; ExitCode=-1; Duration="N/A" }
    $Results += $r
}
Write-Host " $($r.Status) ($($r.Duration))" -ForegroundColor $(if($r.Status -eq 'PASS'){'Green'}else{'Red'})

# 7. Java (needs javac + java)
Write-Host "[7/9] Java..." -NoNewline
if ($javacExe -and $javaExe) {
    $null = New-Item -ItemType Directory -Path "$BaseDir\build" -Force
    $javaScript = "javac -d `"$BaseDir\build`" `"$BaseDir\ShowCode.java`" && java -cp `"$BaseDir\build`" ShowCode"
    $r = Invoke-ShellTestCase -Name "Java" -Script $javaScript
    $Results += $r
} else {
    $r = [PSCustomObject]@{ Name="Java"; Status="SKIP (java/javac not installed)"; Output=""; Stderr=""; ExitCode=-1; Duration="N/A" }
    $Results += $r
}
Write-Host " $($r.Status) ($($r.Duration))" -ForegroundColor $(if($r.Status -eq 'PASS'){'Green'}else{'Red'})

# 8. Hex (machine code - reference, measure parse time)
Write-Host "[8/9] Hex (machine code)..." -NoNewline
$hexFile = "$BaseDir\show_code.hex"
if (Test-Path $hexFile) {
    $hexSw = [System.Diagnostics.Stopwatch]::StartNew()
    $hexContent = Get-Content $hexFile -Raw
    $hexBytes = ($hexContent -replace '[^0-9a-fA-F\s]', '' -split '\s+' | Where-Object { $_ -ne '' }).Count
    $hexSw.Stop()
    $hexDuration = "{0:N0}ms" -f $hexSw.Elapsed.TotalMilliseconds
    $r = [PSCustomObject]@{ Name="Hex (machine code)"; Status="INFO (reference only)"; Output="Parsed $hexBytes hex tokens (show_code.hex)"; Stderr="Parsed $hexBytes hex tokens"; ExitCode=0; Duration=$hexDuration }
} else {
    $r = [PSCustomObject]@{ Name="Hex (machine code)"; Status="SKIP (file not found)"; Output="N/A"; Stderr=""; ExitCode=-1; Duration="N/A" }
}
$Results += $r
Write-Host " $($r.Status) ($($r.Duration))" -ForegroundColor Cyan

# 9. Binary (machine code - reference, measure read time)
Write-Host "[9/9] Binary (machine code)..." -NoNewline
$binFile = "$BaseDir\show_code.bin"
if (Test-Path $binFile) {
    $binSw = [System.Diagnostics.Stopwatch]::StartNew()
    $binBytes = (Get-Item $binFile).Length
    $null = [System.IO.File]::ReadAllBytes($binFile)
    $binSw.Stop()
    $binDuration = "{0:N0}ms" -f $binSw.Elapsed.TotalMilliseconds
    $r = [PSCustomObject]@{ Name="Binary (machine code)"; Status="INFO (reference only)"; Output="Read $binBytes bytes (show_code.bin)"; Stderr="Read $binBytes bytes"; ExitCode=0; Duration=$binDuration }
} else {
    $r = [PSCustomObject]@{ Name="Binary (machine code)"; Status="SKIP (file not found)"; Output="N/A"; Stderr=""; ExitCode=-1; Duration="N/A" }
}
$Results += $r
Write-Host " $($r.Status) ($($r.Duration))" -ForegroundColor Cyan

# Generate counts
$passCount = ($Results | Where-Object { $_.Status -eq 'PASS' }).Count
$skipCount = ($Results | Where-Object { $_.Status -like 'SKIP*' }).Count
$failCount = ($Results | Where-Object { $_.Status -like 'FAIL*' -or $_.Status -like 'ERROR*' }).Count
$infoCount = ($Results | Where-Object { $_.Status -like 'INFO*' }).Count

# ---- Pre-compute environment strings ----
if ($pyExe)   { $pyVer   = & python --version 2>&1 } else { $pyVer = "Not installed" }
if ($nodeExe) { $nodeVer = & node --version 2>&1 }   else { $nodeVer = "Not installed" }
if (Get-Command dotnet -ErrorAction SilentlyContinue) { $dotVer = & dotnet --version 2>&1 } else { $dotVer = "Not installed" }
if ($gccExe)  { $gccVer  = & gcc --version 2>&1 | Select-Object -First 1; $gccStatus  = "Available" } else { $gccVer = "Not installed"; $gccStatus = "Missing" }
if ($goExe)   { $goVer   = & go version 2>&1;       $goStatus   = "Available" } else { $goVer  = "Not installed"; $goStatus  = "Missing" }
if ($nasmExe) { $nasmVer = & nasm --version 2>&1;   $nasmStatus = "Available" } else { $nasmVer = "Not installed"; $nasmStatus = "Missing" }
if ($javaExe) { $javaVer = & java -version 2>&1 | Select-Object -First 1; $javaStatus = "Available" } else { $javaVer = "Not installed"; $javaStatus = "Missing" }

# Build detail rows
$detailRows = ""
for ($idx = 0; $idx -lt $Results.Count; $idx++) {
    $r = $Results[$idx]
    $detailRows += "| $($idx + 1) | $($r.Name) | $($r.Status) | $($r.Duration) | $($r.ExitCode) | $($r.Output) |`n"
}

# Generate report
$report = @"
# Cheap Talk - Windows Test Report

- **Time**: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
- **OS**: $($env:OS) $([System.Environment]::OSVersion.VersionString)
- **Arch**: $env:PROCESSOR_ARCHITECTURE
- **Expected output**: ``Talk is cheap. Show me the code.``

## Environment

| Tool | Version | Status |
|------|---------|--------|
| Python | $pyVer | $(if($pyExe){'Installed'}else{'Missing'}) |
| Node.js | $nodeVer | $(if($nodeExe){'Installed'}else{'Missing'}) |
| .NET SDK | $dotVer | Installed |
| GCC | $gccVer | $gccStatus |
| Go | $goVer | $goStatus |
| NASM | $nasmVer | $nasmStatus |
| Java | $javaVer | $javaStatus |

## Offline Dependencies

| Platform | Path | Description |
|----------|------|-------------|
| Windows x64 | ``deps/dotnet-win-x64/csproj.exe`` | C# self-contained publish (no .NET runtime needed) |
| Linux x64 | ``deps/dotnet-linux-x64/csproj`` | C# self-contained publish (no .NET runtime needed) |

## Test Summary

| Result | Count |
|--------|:-----:|
| PASS | $passCount |
| SKIP | $skipCount |
| FAIL | $failCount |
| INFO | $infoCount |

## Detailed Results

| # | Language | Status | Duration | Exit Code | Actual Output |
|---|----------|--------|----------|:---------:|---------------|
$detailRows
## Debug Log Output (stderr)

All source files now include structured debug logging. Program output goes to **stdout**, debug logs to **stderr**.

Format: ``timestamp | LEVEL | module | message``

"@

# Append debug logs for each result
for ($idx = 0; $idx -lt $Results.Count; $idx++) {
    $r = $Results[$idx]
    if ($r.Stderr -and $r.Stderr.Length -gt 0) {
        $report += "### $($r.Name)" + "`r`n`r`n" + "``````" + "`r`n" + $r.Stderr + "`r`n" + "``````" + "`r`n`r`n"
    }
}

$report += @"
## Offline Run Instructions

### C# (verified offline)

Published via ``dotnet publish --self-contained``:

``````
dotnet publish -c Release -r win-x64   --self-contained true -o deps/dotnet-win-x64
dotnet publish -c Release -r linux-x64 --self-contained true -o deps/dotnet-linux-x64
``````

The publish bundle includes the full .NET runtime. Target machines need **no .NET installed**:

- **Windows**: run ``deps\dotnet-win-x64\csproj.exe``
- **Linux**: ``chmod +x deps/dotnet-linux-x64/csproj && ./deps/dotnet-linux-x64/csproj``

### Python / JavaScript

Require corresponding interpreters. Pre-install Python / Node.js on offline machines.

### C / Go / Assembly / Java

Require compiler toolchains (gcc / go / nasm / jdk). Install via Chocolatey or manual download:

``````
choco install mingw -y
choco install nasm -y
# Go and JDK: manual download (chocolatey sources may be unavailable)
# Go:   https://go.dev/dl/go1.23.4.windows-amd64.zip -> extract to C:\go
# JDK:  https://download.bell-sw.com/java/21.0.5+11/bellsoft-jdk21.0.5+11-windows-amd64.zip -> extract to C:\jdk21
# Set JAVA_HOME and add %JAVA_HOME%\bin to PATH
``````

## Binary Versions

``show_code.hex`` and ``show_code.bin`` are human-readable representations of x86_64 machine code (reference only, not directly executable).
To produce an executable binary, assemble ``show_code_win.asm`` with nasm and link with gcc.
"@

$report | Out-File -FilePath $ReportPath -Encoding utf8 -NoNewline

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  PASS: $passCount | SKIP: $skipCount | FAIL: $failCount | INFO: $infoCount" -ForegroundColor $(if($failCount -gt 0){'Red'}elseif($skipCount -gt 0){'Yellow'}else{'Green'})
Write-Host "  Report: $ReportPath" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
