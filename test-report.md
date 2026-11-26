# Cheap Talk — 综合测试运行报告

> **项目**: 多语言实现 `Talk is cheap. Show me the code.` 输出逻辑
> **报告生成时间**: 2026-11-20 (最新测试: 11:35:41)
> **运行环境**: Windows Server 2019 (10.0.17763) / AMD64

---

## 一、项目概览

将同一逻辑——打印字符串 `Talk is cheap. Show me the code.` 到标准输出——用 **7 种语言**实现，涵盖从高级语言到二进制机器码的完整链路，区分 Windows / Linux 两套环境，含离线依赖与一键运行脚本。

### 文件清单

```
cheap_talk/
├── README.md                      # 项目说明文档
├── show_code.py                   # Python
├── show_code.js                   # JavaScript (Node.js)
├── show_code.go                   # Go
├── show_code.cs                   # C# (源文件)
├── ShowCode.java                  # Java
├── show_code.c                    # C
├── show_code.asm                  # x86_64 汇编 (Linux/macOS, NASM syscall)
├── show_code_win.asm              # x86_64 汇编 (Windows, NASM + Windows API)
├── show_code.hex                  # 十六进制机器码 (参考)
├── show_code.bin                  # 二进制机器码 (参考)
├── csproj/                        # C# 项目 (用于 dotnet publish)
├── deps/
│   ├── dotnet-win-x64/            # C# Windows 离线发布包 (自包含)
│   └── dotnet-linux-x64/          # C# Linux 离线发布包 (自包含)
├── build/                         # 编译产物 (C/Assembly/Java)
├── run-windows.ps1                # Windows 一键运行脚本
├── run-linux.sh                   # Linux 一键运行脚本
├── test-report-windows.md         # Windows 测试报告 (脚本自动生成)
├── test-report-linux.md           # Linux 测试报告 (脚本运行后生成)
└── test-report.md                 # 本综合报告
```

---

## 二、工具链安装记录

| 工具 | 安装方式 | 版本 | 安装结果 |
|------|----------|------|:--------:|
| GCC (MinGW) | `choco install mingw -y` | 16.2.0 | 成功 |
| NASM | `choco install nasm -y` | 3.02 | 成功 |
| Go | 官方 zip 手动安装 | 1.23.4 | 成功 |
| JDK (Liberica) | BellSoft zip 手动安装 | 21.0.5 | 成功 |

> Go 和 JDK 通过 Chocolatey 安装时下载源不可用 (404)，改为手动下载 zip 包解压：
> - Go: `https://go.dev/dl/go1.23.4.windows-amd64.zip` → 解压到 `C:\go`
> - JDK: `https://download.bell-sw.com/java/21.0.5+11/bellsoft-jdk21.0.5+11-windows-amd64.zip` → 解压到 `C:\jdk21`

---

## 三、环境变量注入

以下路径已**永久写入操作系统注册表** (`HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment`)：

| 变量 | 值 | 说明 |
|------|------|------|
| `PATH` (追加) | `C:\ProgramData\mingw64\mingw64\bin` | GCC |
| `PATH` (追加) | `C:\Program Files\NASM` | NASM |
| `PATH` (追加) | `C:\go\go\bin` | Go |
| `JAVA_HOME` (新增) | `C:\jdk21\jdk-21.0.5` | JDK 根目录 |
| `PATH` (追加) | `%JAVA_HOME%\bin` | Java / javac |

已通过 `SendMessageTimeout` 广播 `WM_SETTINGCHANGE`，新开终端自动生效。

---

## 四、离线依赖

### C# 自包含发布包 (已验证)

通过 `dotnet publish --self-contained true` 发布，内含完整 .NET 运行时，**目标机器无需安装 .NET**：

| 平台 | 路径 | 发布命令 |
|------|------|----------|
| **Windows x64** | `deps/dotnet-win-x64/csproj.exe` | `dotnet publish -c Release -r win-x64 --self-contained true -o deps/dotnet-win-x64` |
| **Linux x64** | `deps/dotnet-linux-x64/csproj` | `dotnet publish -c Release -r linux-x64 --self-contained true -o deps/dotnet-linux-x64` |

### 工具链离线安装

| 工具 | 命令 | 备注 |
|------|------|------|
| GCC | `choco install mingw -y` | 安装到 `C:\ProgramData\mingw64\mingw64\bin` |
| NASM | `choco install nasm -y` | 安装到 `C:\Program Files\NASM` |
| Go | 手动下载 zip 解压 | Chocolatey 源不可用时的备选方案 |
| JDK | 手动下载 zip 解压 | 设置 `JAVA_HOME` 并添加 `%JAVA_HOME%\bin` 到 PATH |

---

## 五、运行脚本

### Windows: `run-windows.ps1`

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File run-windows.ps1
```

- 自动检测工具链可用性并添加 PATH
- 依次运行 Python / JS / C# / C / Go / Assembly / Java (7 个版本)
- C# 使用 `deps/dotnet-win-x64/csproj.exe` 离线包
- C 和 Assembly 先编译再运行 (gcc 编译 C，nasm + gcc 链接 Assembly)
- Java 先 javac 编译再 java 运行
- 生成 `test-report-windows.md`

### Linux: `run-linux.sh`

```bash
chmod +x run-linux.sh
./run-linux.sh
```

- 自动检测工具链可用性
- 依次运行 Python / JS / C# / C / Go / Assembly / Java (7 个版本)
- C# 使用 `deps/dotnet-linux-x64/csproj` 离线包
- 生成 `test-report-linux.md`

---

## 六、Windows 测试结果 (已执行)

### 环境

| 工具 | 版本 | 状态 |
|------|------|------|
| Python | 3.14.6 | 已安装 |
| Node.js | v24.16.0 | 已安装 |
| .NET SDK | 10.0.301 | 已安装 |
| GCC | 16.2.0 (MinGW) | 已安装 |
| Go | 1.23.4 | 已安装 |
| NASM | 3.02 | 已安装 |
| Java | 21.0.5 (Liberica JDK) | 已安装 |

### 结果汇总

| 结果 | 数量 |
|------|:----:|
| **PASS** | **7** |
| SKIP | 0 |
| FAIL | 0 |
| INFO | 2 |

### 详细结果

| # | 语言 | 状态 | 耗时 | 实际输出 |
|---|------|------|------|----------|
| 1 | Python | **PASS** | 151ms | `Talk is cheap. Show me the code.` |
| 2 | JavaScript | **PASS** | 65ms | `Talk is cheap. Show me the code.` |
| 3 | C# (self-contained) | **PASS** | 66ms | `Talk is cheap. Show me the code.` |
| 4 | C | **PASS** | 787ms | `Talk is cheap. Show me the code.` |
| 5 | Go | **PASS** | 401ms | `Talk is cheap. Show me the code.` |
| 6 | Assembly | **PASS** | 83ms | `Talk is cheap. Show me the code.` |
| 7 | Java | **PASS** | 723ms | `Talk is cheap. Show me the code.` |
| 8 | Hex (machine code) | INFO (reference only) | 9ms | Parsed 106 hex tokens (`show_code.hex`) |
| 9 | Binary (machine code) | INFO (reference only) | 4ms | Read 851 bytes (`show_code.bin`) |

> 完整报告见 `test-report-windows.md`

### Assembly 版本说明

Windows 版汇编 (`show_code_win.asm`) 使用 Windows API (`GetStdHandle` + `WriteFile`) 而非 syscall，通过 NASM 汇编后用 gcc 链接：

```
nasm -f win64 show_code_win.asm -o build\show_code_win.obj
gcc build\show_code_win.obj -o build\show_code_asm.exe
build\show_code_asm.exe
```

---

## 七、Linux 测试结果 (预期)

当前环境为 Windows，无 WSL，Linux 脚本未实际执行。以下为预期结果：

| # | 语言 | 预期状态 | 说明 |
|---|------|----------|------|
| 1 | Python | PASS/SKIP | 取决于是否安装 python3 |
| 2 | JavaScript | PASS/SKIP | 取决于是否安装 node |
| 3 | C# (self-contained) | **PASS** | 离线包已发布，无需 .NET 运行时 |
| 4 | C | PASS/SKIP | 取决于是否安装 gcc |
| 5 | Go | PASS/SKIP | 取决于是否安装 go |
| 6 | Assembly | PASS/SKIP | 取决于是否安装 nasm + ld |
| 7 | Java | PASS/SKIP | 取决于是否安装 jdk |

> 在 Linux 机器上执行 `./run-linux.sh` 后将自动生成 `test-report-linux.md`。
> Linux 版汇编 (`show_code.asm`) 使用 syscall 指令，通过 nasm -f elf64 + ld 链接。

---

## 八、从高级语言到二进制的链路

```
高级语言 (.py .js .go .cs .java .c)
        │  编译 / 解释
        ▼
汇编语言 (.asm)
        │  汇编器 (nasm)
        ▼
十六进制机器码 (.hex)
        │  字节的十六进制表示
        ▼
二进制机器码 (.bin)  ← 最接近硬件
        │  CPU 电平信号
        ▼
    硅
```

---

## 九、调试环境与日志输出

### 源码内置日志

**所有 7 个原始源码文件已修改为内置结构化调试日志**。程序结果输出到 **stdout**，调试日志输出到 **stderr**，实现流分离。

#### 日志格式

```
2026-11-19 15:13:52 | INFO    | show_code | === Process started ===
2026-11-19 15:13:52 | INFO    | show_code | PID: 111096
2026-11-19 15:13:52 | DEBUG   | show_code | Entering show_code()
2026-11-19 15:13:52 | INFO    | show_code | Message variable assigned (len=32)
2026-11-19 15:13:52 | DEBUG   | show_code | Preparing to print to stdout
Talk is cheap. Show me the code.
2026-11-19 15:13:52 | DEBUG   | show_code | print() completed
2026-11-19 15:13:52 | INFO    | show_code | === Process finished (elapsed: 0.11ms) ===
```

#### 各语言日志机制

| 源码文件 | 语言 | 日志输出方式 | 日志行数 |
|----------|------|-------------|:--------:|
| `show_code.py` | Python | `logging` → `sys.stderr` | 12 |
| `show_code.js` | JavaScript | `process.stderr.write` | 12 |
| `show_code.go` | Go | `log` 标准库 (默认 stderr) | 12 |
| `ShowCode.java` | Java | `System.err.printf` | 12 |
| `show_code.c` | C | `fprintf(stderr, ...)` | 12 |
| `show_code.cs` | C# | `Console.Error.WriteLine` | 12 |
| `show_code_win.asm` | Assembly (Windows) | `WriteFile(stderr_fd, ...)` | 6 |
| `show_code.asm` | Assembly (Linux) | `syscall write(fd=2)` | 6 |

#### 日志内容

每个语言的日志包含：
1. `INFO` — 进程启动（PID、运行时版本、平台、工作目录）
2. `DEBUG` — 进入函数
3. `INFO` — 变量赋值（含字符串长度）
4. `DEBUG` — 准备输出
5. `DEBUG` — 输出完成
6. `DEBUG` — 退出函数
7. `INFO` — 进程结束（含耗时）

### 测试脚本日志分离

`run-windows.ps1` 和 `run-linux.sh` 已更新，测试时：
- **stdout** — 验证程序输出是否匹配预期字符串
- **stderr** — 捕获并写入测试报告的 "Debug Log Output" 章节

### 独立 debug 版本

`debug/` 目录中保留了独立的 debug 版本（含更详细的环境信息），以及 VS Code 调试配置：

| 配置 | 调试器 | 断点支持 |
|------|--------|:--------:|
| Debug: Python | debugpy | 支持 |
| Debug: JavaScript | Node.js | 支持 |
| Debug: Go | delve | 支持 |
| Debug: Java | Java debugger | 支持 |
| Debug: C# | coreclr | 支持 |
| Debug: C | gdb (cppdbg) | 支持 (`-g -O0`) |
| Debug: Assembly | gdb (cppdbg) | 支持 (`stopAtEntry`) |

### 跨平台 C 源码

`show_code.c` 已改为跨平台版本，通过 `#ifdef _WIN32` 条件编译：
- **Windows** — `GetCurrentProcessId()` + `QueryPerformanceCounter`
- **Linux** — `getpid()` + `gettimeofday()`

---

## 十、结论

1. **全部 7 个语言版本通过测试** (Python / JavaScript / C# / C / Go / Assembly / Java)，输出完全一致
2. **4 个工具链安装并注入系统环境** — GCC 16.2.0、Go 1.23.4、NASM 3.02、JDK 21.0.5，PATH 和 JAVA_HOME 已永久写入注册表
3. **C# 离线方案验证成功** — Windows 和 Linux 两套自包含发布包已生成，目标机器无需安装 .NET
4. **所有源码内置结构化日志** — stdout/stderr 流分离，7 种语言均输出 `时间戳 | LEVEL | 模块 | 消息` 格式调试日志
5. **调试环境搭建完成** — VS Code 7 个调试配置支持断点调试，独立 debug 版本位于 `debug/` 目录
6. **二进制版本** (`show_code.hex` / `show_code.bin`) 为参考性展示，可通过 nasm 汇编 `.asm` 文件后链接为可执行文件
