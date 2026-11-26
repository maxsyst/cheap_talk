# Talk is cheap. Show me the code.

同一逻辑——将字符串 `"Talk is cheap. Show me the code."` 打印到标准输出——用 **7 种语言**实现，涵盖从高级语言到二进制机器码的完整链路，区分 Windows / Linux 两套环境，含离线依赖、一键运行脚本、完整的**调试环境**（带日志输出 + VS Code 调试配置）。所有源码均内置结构化调试日志（输出到 stderr），程序结果输出到 stdout，实现流分离。

## 文件清单

| 文件 | 语言 / 层级 | 距离二进制 |
|------|------------|:----------:|
| `show_code.py`      | Python    | 远 |
| `show_code.js`      | JavaScript | 远 |
| `show_code.go`      | Go        | 远 |
| `show_code.cs`      | C#        | 远 |
| `ShowCode.java`     | Java      | 远 |
| `show_code.c`       | C         | 中 |
| `show_code.asm`     | x86_64 汇编 (Linux/macOS, NASM syscall) | 近 |
| `show_code_win.asm` | x86_64 汇编 (Windows, NASM + Windows API) | 近 |
| `show_code.hex`     | 十六进制机器码 | 很近 |
| `show_code.bin`     | 二进制机器码（0/1 书写） | 最近 |

## 逻辑说明

所有版本都做同一件事：

1. 定义函数/方法 `show_code` / `ShowCode` / `showCode`
2. 将字符串赋给变量 `message`
3. 打印 `message` 到标准输出
4. 入口点调用该函数

## 各语言核心实现对照

> 所有版本均输出结构化调试日志到 **stderr**，程序结果输出到 **stdout**，实现流分离。

### Python
```python
import logging, sys
logging.basicConfig(level=logging.DEBUG,
    format="%(asctime)s | %(levelname)-7s | %(name)s | %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S", stream=sys.stderr)
logger = logging.getLogger("show_code")

def show_code():
    logger.debug("Entering show_code()")
    message = "Talk is cheap. Show me the code."
    logger.info("Message variable assigned (len=%d)", len(message))
    print(message)
    logger.debug("print() completed")
```

### JavaScript (Node.js)
```javascript
function log(level, module, msg) {
    process.stderr.write(`${timestamp()} | ${level.padEnd(7)} | ${module} | ${msg}\n`);
}
function showCode() {
    log("DEBUG", "showCode", "Entering showCode()");
    const message = "Talk is cheap. Show me the code.";
    log("INFO", "showCode", `Message variable assigned (len=${message.length})`);
    console.log(message);
    log("DEBUG", "showCode", "console.log() completed");
}
```

### Go
```go
func showCode() {
    log.Println("[DEBUG] Entering showCode()")
    message := "Talk is cheap. Show me the code."
    log.Printf("[INFO] Message variable assigned (len=%d)\n", len(message))
    fmt.Println(message)
    log.Println("[DEBUG] fmt.Println() completed")
}
```

### C#
```csharp
static void Log(string level, string module, string msg) =>
    Console.Error.WriteLine($"{DateTime.Now:yyyy-MM-dd HH:mm:ss} | {level,-7} | {module} | {msg}");
static void ShowCode() {
    Log("DEBUG", "ShowCode", "Entering ShowCode()");
    string message = "Talk is cheap. Show me the code.";
    Log("INFO", "ShowCode", $"Message variable assigned (len={message.Length})");
    Console.WriteLine(message);
    Log("DEBUG", "ShowCode", "Console.WriteLine() completed");
}
```

### Java
```java
private static void log(String level, String module, String msg) {
    String ts = Instant.now().toString().replace("T", " ").replace("Z", "");
    System.err.printf("%s | %-7s | %s | %s%n", ts, level, module, msg);
}
public static void showCode() {
    log("DEBUG", "showCode", "Entering showCode()");
    String message = "Talk is cheap. Show me the code.";
    log("INFO", "showCode", String.format("Message variable assigned (len=%d)", message.length()));
    System.out.println(message);
    log("DEBUG", "showCode", "System.out.println() completed");
}
```

### C
```c
static void log_msg(const char *level, const char *module, const char *msg) {
    fprintf(stderr, "%s | %-7s | %s | %s\n", ts, level, module, msg);
}
void show_code(void) {
    log_msg("DEBUG", "show_code", "Entering show_code()");
    const char *message = "Talk is cheap. Show me the code.";
    printf("%s\n", message);
    log_msg("DEBUG", "show_code", "printf() completed");
}
```

### x86_64 汇编 (Windows API)
```asm
write_stderr:
    mov     rcx, [rel stderr_fd]
    call    WriteFile      ; debug log to stderr
show_code:
    ; DEBUG: Entering show_code()
    lea     rdx, [rel dbg_enter]
    call    write_stderr
    ; stdout: message
    mov     rcx, [rel stdout_fd]
    call    WriteFile
```

### x86_64 汇编 (Linux syscall)
```asm
write_stderr:
    mov     rax, 1          ; SYS_write
    mov     rdi, 2          ; fd: stderr
    syscall
show_code:
    lea     rsi, [rel dbg_enter]
    call    write_stderr
    lea     rsi, [rel message]
    mov     rdi, 1          ; fd: stdout
    syscall
```

## 从高级语言到二进制的链路

```
高级语言 (.py .js .go .cs .java .c)
        │  编译/解释
        ▼
汇编语言 (.asm)
        │  汇编器 (nasm)
        ▼
十六进制机器码 (.hex)
        │  即字节的十六进制表示
        ▼
二进制机器码 (.bin)  ← 最接近硬件执行的形态
        │  CPU 电平信号
        ▼
    硅
```

每一层之间的转换都是**有损压缩的反向**：越往下越接近硬件，人类可读性越低，但执行效率越高。

## 最接近二进制的方案说明

`show_code.bin` 是 x86_64 机器码的**真二进制书写形式**，这是最贴近 CPU 硬件执行的形态：

- 每一条汇编指令直接对应固定字节，再展开为 8 位二进制
- 例如字符串首字符 `'T'`：

```
ASCII:    T
十六进制: 0x54
二进制:   01010100
```

- 完整字符串 `"Talk is cheap. Show me the code.\n"` 共 37 字节，其二进制表示见 `show_code.bin` 最后一行
- 核心机制：直接通过 `syscall` 调用内核 `write(stdout, message, 37)`，无任何运行时或标准库

## 运行方式

### 统一入口（推荐）

`csproj/Program.cs` 是项目的主入口，一条命令调用全部 7 种语言的 `show_code` / `showCode` 函数：

```bash
cd csproj && dotnet run
```

输出包含：
- **stderr** — 结构化调试日志（每步调用的时间戳、PID、耗时）
- **stdout** — 汇总结果表（7 种语言的 PASS/FAIL/SKIP 状态、耗时、stdout 片段）

```
┌──────────────────────────────────────────────────────────────────┐
│          Unified Entry — All Language Results                   │
├────────────┬──────────┬────────────────────┬──────────────────────┤
│ Language   │ Status   │ Elapsed (ms)       │ stdout               │
├────────────┼──────────┼────────────────────┼──────────────────────┤
│ C#         │ PASS     │                  0 │ Talk is cheap. Show...│
│ Python     │ PASS     │                207 │ Talk is cheap. Show...│
│ JavaScript │ PASS     │                 83 │ Talk is cheap. Show...│
│ Go         │ PASS     │                438 │ Talk is cheap. Show...│
│ C          │ PASS     │                833 │ Talk is cheap. Show...│
│ Assembly   │ PASS     │                 85 │ Talk is cheap. Show...│
│ Java       │ PASS     │                745 │ Talk is cheap. Show...│
└────────────┴──────────┴────────────────────┴──────────────────────┘

  PASS: 7  |  SKIP: 0  |  FAIL: 0  |  Total elapsed: 2405ms
```

调用方式：
- **C#** — 进程内直接调用 `ShowCodeCSharp()` 函数
- **Python** — 子进程 `python show_code.py`
- **JavaScript** — 子进程 `node show_code.js`
- **Go** — 子进程 `go run show_code.go`
- **C** — 子进程 `gcc show_code.c -o build\show_code_c.exe && run`
- **Assembly** — 子进程 `nasm + gcc link + run`
- **Java** — 子进程 `javac ShowCode.java && java ShowCode`

### 分别运行（测试脚本）

### Windows

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File run-windows.ps1
```

### Linux

```bash
chmod +x run-linux.sh
./run-linux.sh
```

### 手动运行单个语言

| 文件 | 运行命令 |
|------|---------|
| `.py`     | `python show_code.py` |
| `.js`     | `node show_code.js` |
| `.go`     | `go run show_code.go` |
| `.cs`     | `dotnet run` 或直接运行 `deps\dotnet-win-x64\csproj.exe` |
| `.java`   | `javac ShowCode.java && java ShowCode` |
| `.c`      | `gcc show_code.c -o show_code && ./show_code` |
| `.asm` (Linux) | `nasm -f elf64 show_code.asm && ld show_code.o -o show_code && ./show_code` |
| `.asm` (Windows) | `nasm -f win64 show_code_win.asm -o show_code.obj && gcc show_code.obj -o show_code.exe && show_code.exe` |

> 注：`show_code.asm` 使用 syscall 指令（Linux/macOS），`show_code_win.asm` 使用 Windows API（GetStdHandle + WriteFile）。

## 环境要求

| 工具 | 版本 | 用途 |
|------|------|------|
| Python | 3.14+ | 运行 `.py` |
| Node.js | 24+ | 运行 `.js` |
| .NET SDK | 8.0+ | 编译 C#（离线包已发布，运行时无需） |
| JDK | 21+ | 编译运行 `.java` |
| GCC | 16+ | 编译 `.c`，链接 Assembly |
| Go | 1.23+ | 运行 `.go` |
| NASM | 3.02+ | 汇编 `.asm` |

## 离线依赖

| 平台 | 路径 | 说明 |
|------|------|------|
| Windows x64 | `deps/dotnet-win-x64/csproj.exe` | C# 自包含发布包，无需 .NET 运行时 |
| Linux x64 | `deps/dotnet-linux-x64/csproj` | C# 自包含发布包，无需 .NET 运行时 |

## 调试环境

每种语言都有对应的 **debug 版本**（位于 `debug/` 目录），带结构化日志输出和 VS Code 调试配置。

### 日志格式

所有 debug 版本将**程序输出**发送到 stdout，**调试日志**发送到 stderr，实现流分离：

```
2026-11-19 10:00:00 | INFO    | main      | === Process started ===
2026-11-19 10:00:00 | INFO    | main      | PID: 12345
2026-11-19 10:00:00 | DEBUG   | show_code | Entering show_code()
2026-11-19 10:00:00 | INFO    | show_code | Message variable assigned (len=32)
2026-11-19 10:00:00 | DEBUG   | show_code | Preparing to print to stdout
Talk is cheap. Show me the code.
2026-11-19 10:00:00 | DEBUG   | show_code | print completed
2026-11-19 10:00:00 | INFO    | main      | === Process finished (elapsed: 0.12ms) ===
```

### Debug 版本文件

| 文件 | 语言 | 日志机制 |
|------|------|----------|
| `debug/show_code_debug.py` | Python | `logging` 模块 |
| `debug/show_code_debug.js` | JavaScript | `process.stderr.write` |
| `debug/show_code_debug.go` | Go | `log` 标准库 |
| `debug/ShowCodeDebug.java` | Java | `System.err.printf` |
| `debug/show_code_debug.c` | C | `fprintf(stderr, ...)` |
| `debug/ProgramDebug.cs` | C# | `Console.Error.WriteLine` |
| `debug/show_code_debug_win.asm` | Assembly | `WriteFile(stderr_fd, ...)` |

### 运行调试环境

```powershell
# Windows
powershell -NoProfile -ExecutionPolicy Bypass -File debug/run-debug-windows.ps1
```

```bash
# Linux
chmod +x debug/run-debug-linux.sh
./debug/run-debug-linux.sh
```

### VS Code 调试配置

`.vscode/launch.json` 包含 7 个调试配置：

| 配置名 | 语言 | 调试器 | 特性 |
|--------|------|--------|------|
| Debug: Python | Python | debugpy | `justMyCode: true` |
| Debug: JavaScript (Node) | JavaScript | Node.js | 集成终端 |
| Debug: Go | Go | delve | `mode: debug` |
| Debug: Java | Java | Java debugger | 源码映射 |
| Debug: C# (.NET) | C# | coreclr | 预构建任务 |
| Debug: C (GDB) | C | gdb (cppdbg) | `-g -O0` 编译 |
| Debug: Assembly (GDB) | Assembly | gdb (cppdbg) | `stopAtEntry: true` |

编译任务定义在 `.vscode/tasks.json` 中，F5 即可启动断点调试。

### 调试编译标志

| 语言 | 编译标志 | 说明 |
|------|----------|------|
| C | `gcc -g -O0` | 调试符号，禁用优化 |
| Assembly | `nasm -g` | 调试符号 |
| C# | `dotnet build` (Debug) | 默认 Debug 配置 |
| Java | `javac -g` | 调试符号（默认开启） |
| Go | `mode: debug` | delve 调试模式 |
| Python | `justMyCode: true` | 仅调试用户代码 |
| JavaScript | Node.js launch | `--inspect` 集成 |

## 出处

> "Talk is cheap. Show me the code." — Linus Torvalds
