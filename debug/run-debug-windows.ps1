<#
.SYNOPSIS
    Debug environment runner - runs all 7 language debug versions and captures logs
.DESCRIPTION
    Runs each language's debug version, separating stdout (program output) from
    stderr (debug logs). Generates a combined debug log report.
#>

param(
    [string]$ReportPath = "$PSScriptRoot\debug-report-windows.md"
)

$ErrorActionPreference = "Continue"
$BaseDir = $PSScriptRoot
$ParentDir = Split-Path $BaseDir -Parent
$Expected = "Talk is cheap. Show me the code."
$Results = @()

# Ensure toolchain paths
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

function Run-Debug {
    param([string]$Name, [string]$ExePath, [string]$Arguments = "")

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $stdout = ""
    $stderr = ""
    $exitCode = 0
    $status = "PASS"

    try {
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $ExePath
        if ($Arguments) { $psi.Arguments = $Arguments }
        $psi.UseShellExecute = $false
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $psi.WorkingDirectory = $BaseDir

        $proc = [System.Diagnostics.Process]::Start($psi)
        $stdoutTask = $proc.StandardOutput.ReadToEndAsync()
        $stderrTask = $proc.StandardError.ReadToEndAsync()
        $proc.WaitForExit(30000) | Out-Null
        $stdout = $stdoutTask.Result
        $stderr = $stderrTask.Result
        $exitCode = $proc.ExitCode
        $sw.Stop()

        $outTrim = $stdout.Trim()
        if ($exitCode -ne 0) { $status = "FAIL (exit $exitCode)" }
        if ($outTrim -ne $Expected) { $status = "FAIL (output mismatch)" }
    }
    catch {
        $sw.Stop()
        $status = "ERROR: $($_.Exception.Message)"
        $exitCode = -1
    }

    return [PSCustomObject]@{
        Name     = $Name
        Status   = $status
        Stdout   = $outTrim
        Stderr   = ($stderr.Trim())
        ExitCode = $exitCode
        Duration = "{0:N0}ms" -f $sw.Elapsed.TotalMilliseconds
    }
}

function Run-ShellDebug {
    param([string]$Name, [string]$Script)

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $stdout = ""
    $stderr = ""
    $exitCode = 0
    $status = "PASS"

    try {
        $batFile = Join-Path $env:TEMP "cheap_talk_debug_$([guid]::NewGuid().ToString('N').Substring(0,8)).bat"
        "@echo off`r`n$Script" | Out-File -FilePath $batFile -Encoding ascii -NoNewline

        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = "cmd.exe"
        $psi.Arguments = "/c `"$batFile`""
        $psi.UseShellExecute = $false
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $psi.WorkingDirectory = $BaseDir
        $psi.EnvironmentVariables["PATH"] = $env:PATH

        $proc = [System.Diagnostics.Process]::Start($psi)
        $stdoutTask = $proc.StandardOutput.ReadToEndAsync()
        $stderrTask = $proc.StandardError.ReadToEndAsync()
        $proc.WaitForExit(60000) | Out-Null
        $stdout = $stdoutTask.Result
        $stderr = $stderrTask.Result
        $exitCode = $proc.ExitCode
        $sw.Stop()

        Remove-Item $batFile -Force -ErrorAction SilentlyContinue
        $outTrim = $stdout.Trim()
        if ($exitCode -ne 0) { $status = "FAIL (exit $exitCode)" }
        if ($outTrim -ne $Expected) { $status = "FAIL (output mismatch)" }
    }
    catch {
        $sw.Stop()
        $status = "ERROR: $($_.Exception.Message)"
        $exitCode = -1
    }

    return [PSCustomObject]@{
        Name     = $Name
        Status   = $status
        Stdout   = $outTrim
        Stderr   = ($stderr.Trim())
        ExitCode = $exitCode
        Duration = "{0:N0}ms" -f $sw.Elapsed.TotalMilliseconds
    }
}

Write-Host "========================================" -ForegroundColor Magenta
Write-Host "  Cheap Talk - DEBUG Environment Runner" -ForegroundColor Magenta
Write-Host "  $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host ""

# Ensure build dir
$null = New-Item -ItemType Directory -Path "$BaseDir\build" -Force

# 1. Python
Write-Host "[1/7] Python (debug)..." -NoNewline
$r = Run-Debug -Name "Python" -ExePath "python" -Arguments "`"$BaseDir\show_code_debug.py`""
$Results += $r
Write-Host " $($r.Status) ($($r.Duration))" -ForegroundColor $(if($r.Status -eq 'PASS'){'Green'}else{'Red'})

# 2. JavaScript
Write-Host "[2/7] JavaScript (debug)..." -NoNewline
$r = Run-Debug -Name "JavaScript" -ExePath "node" -Arguments "`"$BaseDir\show_code_debug.js`""
$Results += $r
Write-Host " $($r.Status) ($($r.Duration))" -ForegroundColor $(if($r.Status -eq 'PASS'){'Green'}else{'Red'})

# 3. C# (dotnet run in debug project)
Write-Host "[3/7] C# (debug)..." -NoNewline
$r = Run-ShellDebug -Name "C#" -Script "dotnet run --project `"$BaseDir\csproj_debug`" --no-build 2>nul || dotnet run --project `"$BaseDir\csproj_debug`""
$Results += $r
Write-Host " $($r.Status) ($($r.Duration))" -ForegroundColor $(if($r.Status -eq 'PASS'){'Green'}else{'Red'})

# 4. C
Write-Host "[4/7] C (debug)..." -NoNewline
$cScript = "gcc -g -O0 `"$BaseDir\show_code_debug.c`" -o `"$BaseDir\build\show_code_debug_c.exe`" && `"$BaseDir\build\show_code_debug_c.exe`""
$r = Run-ShellDebug -Name "C" -Script $cScript
$Results += $r
Write-Host " $($r.Status) ($($r.Duration))" -ForegroundColor $(if($r.Status -eq 'PASS'){'Green'}else{'Red'})

# 5. Go
Write-Host "[5/7] Go (debug)..." -NoNewline
$r = Run-ShellDebug -Name "Go" -Script "go run `"$BaseDir\show_code_debug.go`""
$Results += $r
Write-Host " $($r.Status) ($($r.Duration))" -ForegroundColor $(if($r.Status -eq 'PASS'){'Green'}else{'Red'})

# 6. Assembly
Write-Host "[6/7] Assembly (debug)..." -NoNewline
$asmScript = "nasm -f win64 -g `"$BaseDir\show_code_debug_win.asm`" -o `"$BaseDir\build\show_code_debug_win.obj`" && gcc -g `"$BaseDir\build\show_code_debug_win.obj`" -o `"$BaseDir\build\show_code_debug_asm.exe`" && `"$BaseDir\build\show_code_debug_asm.exe`""
$r = Run-ShellDebug -Name "Assembly" -Script $asmScript
$Results += $r
Write-Host " $($r.Status) ($($r.Duration))" -ForegroundColor $(if($r.Status -eq 'PASS'){'Green'}else{'Red'})

# 7. Java
Write-Host "[7/7] Java (debug)..." -NoNewline
$javaScript = "javac -d `"$BaseDir\build`" `"$BaseDir\ShowCodeDebug.java`" && java -cp `"$BaseDir\build`" ShowCodeDebug"
$r = Run-ShellDebug -Name "Java" -Script $javaScript
$Results += $r
Write-Host " $($r.Status) ($($r.Duration))" -ForegroundColor $(if($r.Status -eq 'PASS'){'Green'}else{'Red'})

# Stats
$passCount = ($Results | Where-Object { $_.Status -eq 'PASS' }).Count
$failCount = ($Results | Where-Object { $_.Status -like 'FAIL*' -or $_.Status -like 'ERROR*' }).Count

# Print debug log samples
Write-Host ""
Write-Host "========== Debug Log Samples ==========" -ForegroundColor Yellow
foreach ($r in $Results) {
    Write-Host ""
    Write-Host "[$($r.Name)] stdout:" -ForegroundColor Cyan
    Write-Host "  $($r.Stdout)" -ForegroundColor White
    Write-Host "[$($r.Name)] stderr (debug log):" -ForegroundColor Cyan
    foreach ($line in ($r.Stderr -split "`n")) {
        Write-Host "  $line" -ForegroundColor DarkGray
    }
}

# Generate report
$detailRows = ""
for ($i = 0; $i -lt $Results.Count; $i++) {
    $r = $Results[$i]
    $detailRows += "| $($i+1) | $($r.Name) | $($r.Status) | $($r.Duration) | $($r.ExitCode) | $($r.Stdout) |`n"
}

# Build debug log section
$logSection = ""
foreach ($r in $Results) {
    $logSection += "### $($r.Name)`n`n"
    $logSection += "**stdout:**`n`n````````n$($r.Stdout)````````n`n"
    $logSection += "**stderr (debug log):**`n`n````````n$($r.Stderr)````````n`n"
}

$report = @"
# Cheap Talk - Debug Environment Report (Windows)

- **Time**: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
- **OS**: $($env:OS) $([System.Environment]::OSVersion.VersionString)
- **Expected stdout**: ``Talk is cheap. Show me the code.``
- **Debug logs**: Written to stderr (structured: ``timestamp | LEVEL | module | message``)

## Test Summary

| Result | Count |
|--------|:-----:|
| PASS | $passCount |
| FAIL | $failCount |

## Detailed Results

| # | Language | Status | Duration | Exit Code | stdout |
|---|----------|--------|----------|:---------:|--------|
$detailRows
## Debug Log Output

$logSection
## Debug Environment Setup

### Log Format

All debug versions output structured logs to **stderr** (separated from program output on **stdout**):

``````
2026-11-19 10:00:00 | INFO    | main      | === Process started ===
2026-11-19 10:00:00 | INFO    | main      | PID: 12345
2026-11-19 10:00:00 | DEBUG   | show_code | Entering show_code()
2026-11-19 10:00:00 | DEBUG   | show_code | Preparing to print to stdout
Talk is cheap. Show me the code.
2026-11-19 10:00:00 | DEBUG   | show_code | print completed
2026-11-19 10:00:00 | INFO    | main      | === Process finished (elapsed: 0.12ms) ===
``````

### VS Code Debug Configurations

Located at ``.vscode/launch.json``:

| Config | Language | Debugger |
|--------|----------|----------|
| Debug: Python | Python | debugpy |
| Debug: JavaScript (Node) | JavaScript | Node.js built-in |
| Debug: Go | Go | delve |
| Debug: Java | Java | Java debugger |
| Debug: C# (.NET) | C# | coreclr |
| Debug: C (GDB) | C | gdb via cppdbg |
| Debug: Assembly (GDB) | Assembly | gdb via cppdbg (stopAtEntry) |

### Compilation Flags

| Language | Debug Flags |
|----------|-------------|
| C | ``-g -O0`` (debug symbols, no optimization) |
| Assembly | ``-g`` (debug symbols), ``stopAtEntry: true`` in launch.json |
| C# | ``dotnet build`` (Debug configuration) |
| Java | ``javac -g`` (debug symbols, default in javac) |
| Go | ``mode: debug`` (delve) |
| Python | ``justMyCode: true`` |
| JavaScript | Node.js ``--inspect`` via launch config |
"@

$report | Out-File -FilePath $ReportPath -Encoding utf8 -NoNewline

Write-Host ""
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "  PASS: $passCount | FAIL: $failCount" -ForegroundColor $(if($failCount -gt 0){'Red'}else{'Green'})
Write-Host "  Report: $ReportPath" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
