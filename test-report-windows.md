# Cheap Talk - Windows Test Report

- **Time**: 2026-11-20 11:35:44
- **OS**: Windows_NT Microsoft Windows NT 10.0.17763.0
- **Arch**: AMD64
- **Expected output**: `Talk is cheap. Show me the code.`

## Environment

| Tool | Version | Status |
|------|---------|--------|
| Python | Python 3.14.6 | Installed |
| Node.js | v24.16.0 | Installed |
| .NET SDK | 10.0.301 | Installed |
| GCC | gcc.exe (x86_64-posix-seh-rev1, Built by MinGW-Builds project) 16.2.0 | Available |
| Go | go version go1.23.4 windows/amd64 | Available |
| NASM | NASM version 3.02 compiled on Jun 28 2026 | Available |
| Java | openjdk version "21.0.5" 2024-10-15 LTS | Available |

## Offline Dependencies

| Platform | Path | Description |
|----------|------|-------------|
| Windows x64 | `deps/dotnet-win-x64/csproj.exe` | C# self-contained publish (no .NET runtime needed) |
| Linux x64 | `deps/dotnet-linux-x64/csproj` | C# self-contained publish (no .NET runtime needed) |

## Test Summary

| Result | Count |
|--------|:-----:|
| PASS | 7 |
| SKIP | 0 |
| FAIL | 0 |
| INFO | 2 |

## Detailed Results

| # | Language | Status | Duration | Exit Code | Actual Output |
|---|----------|--------|----------|:---------:|---------------|
| 1 | Python | PASS | 151ms | 0 | Talk is cheap. Show me the code. |
| 2 | JavaScript | PASS | 65ms | 0 | Talk is cheap. Show me the code. |
| 3 | C# | PASS | 66ms | 0 | Talk is cheap. Show me the code. |
| 4 | C | PASS | 787ms | 0 | Talk is cheap. Show me the code. |
| 5 | Go | PASS | 401ms | 0 | Talk is cheap. Show me the code. |
| 6 | Assembly | PASS | 83ms | 0 | Talk is cheap. Show me the code. |
| 7 | Java | PASS | 723ms | 0 | Talk is cheap. Show me the code. |
| 8 | Hex (machine code) | INFO (reference only) | 9ms | 0 | Parsed 106 hex tokens (show_code.hex) |
| 9 | Binary (machine code) | INFO (reference only) | 4ms | 0 | Read 851 bytes (show_code.bin) |

## Debug Log Output (stderr)

All source files now include structured debug logging. Program output goes to **stdout**, debug logs to **stderr**.

Format: `timestamp | LEVEL | module | message`
### Python

```
2026-11-20 11:35:42 | INFO    | show_code | === Process started ===
2026-11-20 11:35:42 | INFO    | show_code | PID: 107852
2026-11-20 11:35:42 | INFO    | show_code | Python: 3.14.6
2026-11-20 11:35:42 | INFO    | show_code | Platform: win32
2026-11-20 11:35:42 | INFO    | show_code | Working dir: D:\MaxWorkSpaces\output\cheap_talk
2026-11-20 11:35:42 | DEBUG   | show_code | Entering show_code()
2026-11-20 11:35:42 | INFO    | show_code | Message variable assigned (len=32)
2026-11-20 11:35:42 | DEBUG   | show_code | Preparing to print to stdout
2026-11-20 11:35:42 | DEBUG   | show_code | print() completed
2026-11-20 11:35:42 | DEBUG   | show_code | Exiting show_code()
2026-11-20 11:35:42 | INFO    | show_code | === Process finished (elapsed: 0.11ms) ===
```

### JavaScript

```
2026-11-20 03:35:42.193 | INFO    | main | === Process started ===
2026-11-20 03:35:42.193 | INFO    | main | PID: 106168
2026-11-20 03:35:42.193 | INFO    | main | Node.js: v24.16.0
2026-11-20 03:35:42.193 | INFO    | main | Platform: win32 x64
2026-11-20 03:35:42.193 | INFO    | main | Working dir: D:\MaxWorkSpaces\output\cheap_talk
2026-11-20 03:35:42.194 | DEBUG   | showCode | Entering showCode()
2026-11-20 03:35:42.194 | INFO    | showCode | Message variable assigned (len=32)
2026-11-20 03:35:42.194 | DEBUG   | showCode | Preparing to print to stdout
2026-11-20 03:35:42.194 | DEBUG   | showCode | console.log() completed
2026-11-20 03:35:42.194 | DEBUG   | showCode | Exiting showCode()
2026-11-20 03:35:42.194 | INFO    | main | === Process finished (elapsed: 0.33ms) ===
```

### C#

```
2026-11-20 11:35:42 | INFO    | main | === Process started ===
2026-11-20 11:35:42 | INFO    | main | PID: 20976
2026-11-20 11:35:42 | INFO    | main | .NET: 8.0.28
2026-11-20 11:35:42 | INFO    | main | Platform: Microsoft Windows NT 10.0.17763.0
2026-11-20 11:35:42 | INFO    | main | Working dir: D:\MaxWorkSpaces\output\cheap_talk
2026-11-20 11:35:42 | DEBUG   | ShowCode | Entering ShowCode()
2026-11-20 11:35:42 | INFO    | ShowCode | Message variable assigned (len=32)
2026-11-20 11:35:42 | DEBUG   | ShowCode | Preparing to print to stdout
2026-11-20 11:35:42 | DEBUG   | ShowCode | Console.WriteLine() completed
2026-11-20 11:35:42 | DEBUG   | ShowCode | Exiting ShowCode()
2026-11-20 11:35:42 | INFO    | main | === Process finished (elapsed: 0.15ms) ===
```

### C

```
2026-11-20 11:35:43 | INFO    | main | === Process started ===
2026-11-20 11:35:43 | INFO    | main | PID: 107184
2026-11-20 11:35:43 | INFO    | main | Platform: Windows x64 (MinGW GCC)
2026-11-20 11:35:43 | INFO    | main | Working dir: D:\MaxWorkSpaces\output\cheap_talk
2026-11-20 11:35:43 | DEBUG   | show_code | Entering show_code()
2026-11-20 11:35:43 | INFO    | show_code | Message variable assigned (len=32)
2026-11-20 11:35:43 | DEBUG   | show_code | Preparing to print to stdout
2026-11-20 11:35:43 | DEBUG   | show_code | printf() completed
2026-11-20 11:35:43 | DEBUG   | show_code | Exiting show_code()
2026-11-20 11:35:43 | INFO    | main | === Process finished (elapsed: 0.23ms) ===
```

### Go

```
2026/11/20 11:35:43 [INFO] === Process started ===
2026/11/20 11:35:43 [INFO] PID: 108552
2026/11/20 11:35:43 [INFO] Go: go1.23.4
2026/11/20 11:35:43 [INFO] Platform: windows/amd64
2026/11/20 11:35:43 [INFO] Working dir: D:\MaxWorkSpaces\output\cheap_talk
2026/11/20 11:35:43 [DEBUG] Entering showCode()
2026/11/20 11:35:43 [INFO] Message variable assigned (len=32)
2026/11/20 11:35:43 [DEBUG] Preparing to print to stdout
2026/11/20 11:35:43 [DEBUG] fmt.Println() completed
2026/11/20 11:35:43 [DEBUG] Exiting showCode()
2026/11/20 11:35:43 [INFO] === Process finished (elapsed: 0.00ms) ===
```

### Assembly

```
INFO  | main      | === Process started ===
DEBUG | show_code | Entering show_code()
DEBUG | show_code | Preparing to print to stdout
DEBUG | show_code | WriteFile completed
DEBUG | show_code | Exiting show_code()
INFO  | main      | === Process finished ===
```

### Java

```
2026-11-20 03:35:44.221642 | INFO    | main | === Process started ===
2026-11-20 03:35:44.228585900 | INFO    | main | PID: 107416@ICWATMAX
2026-11-20 03:35:44.228585900 | INFO    | main | Java: 21.0.5
2026-11-20 03:35:44.233052 | INFO    | main | Platform: Windows Server 2019 amd64
2026-11-20 03:35:44.233546100 | INFO    | main | Working dir: D:\MaxWorkSpaces\output\cheap_talk
2026-11-20 03:35:44.233546100 | DEBUG   | showCode | Entering showCode()
2026-11-20 03:35:44.244457900 | INFO    | showCode | Message variable assigned (len=32)
2026-11-20 03:35:44.244954500 | DEBUG   | showCode | Preparing to print to stdout
2026-11-20 03:35:44.244954500 | DEBUG   | showCode | System.out.println() completed
2026-11-20 03:35:44.244954500 | DEBUG   | showCode | Exiting showCode()
2026-11-20 03:35:44.245946 | INFO    | main | === Process finished (elapsed: 11.90ms) ===
```

### Hex (machine code)

```
Parsed 106 hex tokens
```

### Binary (machine code)

```
Read 851 bytes
```

## Offline Run Instructions

### C# (verified offline)

Published via `dotnet publish --self-contained`:

```
dotnet publish -c Release -r win-x64   --self-contained true -o deps/dotnet-win-x64
dotnet publish -c Release -r linux-x64 --self-contained true -o deps/dotnet-linux-x64
```

The publish bundle includes the full .NET runtime. Target machines need **no .NET installed**:

- **Windows**: run `deps\dotnet-win-x64\csproj.exe`
- **Linux**: `chmod +x deps/dotnet-linux-x64/csproj && ./deps/dotnet-linux-x64/csproj`

### Python / JavaScript

Require corresponding interpreters. Pre-install Python / Node.js on offline machines.

### C / Go / Assembly / Java

Require compiler toolchains (gcc / go / nasm / jdk). Install via Chocolatey or manual download:

```
choco install mingw -y
choco install nasm -y
# Go and JDK: manual download (chocolatey sources may be unavailable)
# Go:   https://go.dev/dl/go1.23.4.windows-amd64.zip -> extract to C:\go
# JDK:  https://download.bell-sw.com/java/21.0.5+11/bellsoft-jdk21.0.5+11-windows-amd64.zip -> extract to C:\jdk21
# Set JAVA_HOME and add %JAVA_HOME%\bin to PATH
```

## Binary Versions

`show_code.hex` and `show_code.bin` are human-readable representations of x86_64 machine code (reference only, not directly executable).
To produce an executable binary, assemble `show_code_win.asm` with nasm and link with gcc.