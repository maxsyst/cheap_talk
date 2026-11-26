# Cheap Talk - Debug Environment Report (Windows)

- **Time**: 2026-11-19 11:14:26
- **OS**: Windows_NT Microsoft Windows NT 10.0.17763.0
- **Expected stdout**: `Talk is cheap. Show me the code.`
- **Debug logs**: Written to stderr (structured: `timestamp | LEVEL | module | message`)

## Test Summary

| Result | Count |
|--------|:-----:|
| PASS | 7 |
| FAIL | 0 |

## Detailed Results

| # | Language | Status | Duration | Exit Code | stdout |
|---|----------|--------|----------|:---------:|--------|
| 1 | Python | PASS | 127ms | 0 | Talk is cheap. Show me the code. |
| 2 | JavaScript | PASS | 63ms | 0 | Talk is cheap. Show me the code. |
| 3 | C# | PASS | 817ms | 0 | Talk is cheap. Show me the code. |
| 4 | C | PASS | 781ms | 0 | Talk is cheap. Show me the code. |
| 5 | Go | PASS | 365ms | 0 | Talk is cheap. Show me the code. |
| 6 | Assembly | PASS | 75ms | 0 | Talk is cheap. Show me the code. |
| 7 | Java | PASS | 687ms | 0 | Talk is cheap. Show me the code. |

## Debug Log Output

### Python

**stdout:**

````nTalk is cheap. Show me the code.````n
**stderr (debug log):**

````n2026-11-19 11:14:23 | INFO    | show_code | === Process started ===
2026-11-19 11:14:23 | INFO    | show_code | PID: 8712
2026-11-19 11:14:23 | INFO    | show_code | Python: 3.14.6
2026-11-19 11:14:23 | INFO    | show_code | Platform: win32
2026-11-19 11:14:23 | INFO    | show_code | Working dir: D:\MaxWorkSpaces\output\cheap_talk\debug
2026-11-19 11:14:23 | DEBUG   | show_code | Entering show_code()
2026-11-19 11:14:23 | INFO    | show_code | Message variable assigned (len=32)
2026-11-19 11:14:23 | DEBUG   | show_code | Preparing to print to stdout
2026-11-19 11:14:23 | DEBUG   | show_code | print() completed
2026-11-19 11:14:23 | DEBUG   | show_code | Exiting show_code()
2026-11-19 11:14:23 | INFO    | show_code | === Process finished (elapsed: 0.12ms) ===````n
### JavaScript

**stdout:**

````nTalk is cheap. Show me the code.````n
**stderr (debug log):**

````n2026-11-19 03:14:23.494 | INFO    | main | === Process started ===
2026-11-19 03:14:23.495 | INFO    | main | PID: 90772
2026-11-19 03:14:23.495 | INFO    | main | Node.js: v24.16.0
2026-11-19 03:14:23.495 | INFO    | main | Platform: win32 x64
2026-11-19 03:14:23.495 | INFO    | main | Working dir: D:\MaxWorkSpaces\output\cheap_talk\debug
2026-11-19 03:14:23.495 | DEBUG   | showCode | Entering showCode()
2026-11-19 03:14:23.495 | INFO    | showCode | Message variable assigned (len=32)
2026-11-19 03:14:23.495 | DEBUG   | showCode | Preparing to print to stdout
2026-11-19 03:14:23.496 | DEBUG   | showCode | console.log() completed
2026-11-19 03:14:23.496 | DEBUG   | showCode | Exiting showCode()
2026-11-19 03:14:23.496 | INFO    | main | === Process finished (elapsed: 0.35ms) ===````n
### C#

**stdout:**

````nTalk is cheap. Show me the code.````n
**stderr (debug log):**

````n````n
### C

**stdout:**

````nTalk is cheap. Show me the code.````n
**stderr (debug log):**

````n2026-11-19 11:14:25 | INFO    | main | === Process started ===
2026-11-19 11:14:25 | INFO    | main | PID: 105128
2026-11-19 11:14:25 | INFO    | main | Compiler: MinGW GCC
2026-11-19 11:14:25 | INFO    | main | Platform: Windows x64
2026-11-19 11:14:25 | INFO    | main | Working dir: D:\MaxWorkSpaces\output\cheap_talk\debug
2026-11-19 11:14:25 | DEBUG   | show_code | Entering show_code()
2026-11-19 11:14:25 | INFO    | show_code | Message variable assigned (len=32)
2026-11-19 11:14:25 | DEBUG   | show_code | Preparing to print to stdout
2026-11-19 11:14:25 | DEBUG   | show_code | printf() completed
2026-11-19 11:14:25 | DEBUG   | show_code | Exiting show_code()
2026-11-19 11:14:25 | INFO    | main | === Process finished (elapsed: 0.27ms) ===````n
### Go

**stdout:**

````nTalk is cheap. Show me the code.````n
**stderr (debug log):**

````n2026/11/19 11:14:25 [INFO] === Process started ===
2026/11/19 11:14:25 [INFO] PID: 34580
2026/11/19 11:14:25 [INFO] Go: go1.23.4
2026/11/19 11:14:25 [INFO] Platform: windows/amd64
2026/11/19 11:14:25 [INFO] Working dir: D:\MaxWorkSpaces\output\cheap_talk\debug
2026/11/19 11:14:25 [DEBUG] Entering showCode()
2026/11/19 11:14:25 [INFO] Message variable assigned (len=32)
2026/11/19 11:14:25 [DEBUG] Preparing to print to stdout
2026/11/19 11:14:25 [DEBUG] fmt.Println() completed
2026/11/19 11:14:25 [DEBUG] Exiting showCode()
2026/11/19 11:14:25 [INFO] === Process finished (elapsed: 0.00ms) ===````n
### Assembly

**stdout:**

````nTalk is cheap. Show me the code.````n
**stderr (debug log):**

````nINFO  | main      | === Process started ===
DEBUG | show_code | Entering show_code()
DEBUG | show_code | Preparing to print to stdout
DEBUG | show_code | WriteFile completed
DEBUG | show_code | Exiting show_code()
INFO  | main      | === Process finished ===````n
### Java

**stdout:**

````nTalk is cheap. Show me the code.````n
**stderr (debug log):**

````n2026-11-19 03:14:26.192326400 | INFO    | main | === Process started ===
2026-11-19 03:14:26.199270 | INFO    | main | PID: 101440@ICWATMAX
2026-11-19 03:14:26.199766200 | INFO    | main | Java: 21.0.5
2026-11-19 03:14:26.203734800 | INFO    | main | Platform: Windows Server 2019 amd64
2026-11-19 03:14:26.203734800 | INFO    | main | Working dir: D:\MaxWorkSpaces\output\cheap_talk\debug
2026-11-19 03:14:26.204231200 | DEBUG   | showCode | Entering showCode()
2026-11-19 03:14:26.213653900 | INFO    | showCode | Message variable assigned (len=32)
2026-11-19 03:14:26.214149900 | DEBUG   | showCode | Preparing to print to stdout
2026-11-19 03:14:26.214149900 | DEBUG   | showCode | System.out.println() completed
2026-11-19 03:14:26.214646100 | DEBUG   | showCode | Exiting showCode()
2026-11-19 03:14:26.215141800 | INFO    | main | === Process finished (elapsed: 10.41ms) ===````n

## Debug Environment Setup

### Log Format

All debug versions output structured logs to **stderr** (separated from program output on **stdout**):

```
2026-11-19 10:00:00 | INFO    | main      | === Process started ===
2026-11-19 10:00:00 | INFO    | main      | PID: 12345
2026-11-19 10:00:00 | DEBUG   | show_code | Entering show_code()
2026-11-19 10:00:00 | DEBUG   | show_code | Preparing to print to stdout
Talk is cheap. Show me the code.
2026-11-19 10:00:00 | DEBUG   | show_code | print completed
2026-11-19 10:00:00 | INFO    | main      | === Process finished (elapsed: 0.12ms) ===
```

### VS Code Debug Configurations

Located at `.vscode/launch.json`:

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
| C | `-g -O0` (debug symbols, no optimization) |
| Assembly | `-g` (debug symbols), `stopAtEntry: true` in launch.json |
| C# | `dotnet build` (Debug configuration) |
| Java | `javac -g` (debug symbols, default in javac) |
| Go | `mode: debug` (delve) |
| Python | `justMyCode: true` |
| JavaScript | Node.js `--inspect` via launch config |