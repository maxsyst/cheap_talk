#!/usr/bin/env bash
#=============================================================================
# Linux 环境一键运行所有语言版本的 show_code
# 依次运行 Python / JavaScript / C# (自包含离线包) / C / Go / 汇编版本，
# 记录每个版本的执行结果并生成测试报告。
# C# 使用 deps/dotnet-linux-x64 自包含发布包，无需安装 .NET 运行时。
#=============================================================================

set -e
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
EXPECTED="Talk is cheap. Show me the code."
REPORT_PATH="${BASE_DIR}/test-report-linux.md"
RESULTS_FILE="${BASE_DIR}/.test-results-linux.tsv"

# 清空临时结果文件
: > "$RESULTS_FILE"

echo "========================================"
echo "  Cheap Talk - Linux Test Runner"
echo "  $(date '+%Y-%m-%d %H:%M:%S')"
echo "========================================"
echo ""

run_test() {
    local name="$1"
    local cmd="$2"
    local start_ms end_ms duration exit_code output status

    start_ms=$(date +%s%3N 2>/dev/null || python3 -c 'import time;print(int(time.time()*1000))')
    # Capture only stdout (program output); stderr (debug logs) goes to log file
    output=$(eval "$cmd" 2>/dev/null) || true
    exit_code=$?
    end_ms=$(date +%s%3N 2>/dev/null || python3 -c 'import time;print(int(time.time()*1000))')
    duration=$((end_ms - start_ms))

    # 去除尾部换行
    output=$(echo "$output" | tr -d '\r' | head -1)

    if [ "$exit_code" -eq 0 ] && [ "$output" = "$EXPECTED" ]; then
        status="PASS"
    elif [ "$exit_code" -ne 0 ]; then
        status="FAIL (exit $exit_code)"
    else
        status="FAIL (output mismatch)"
    fi

    echo "$name|$status|$duration|$exit_code|$output" >> "$RESULTS_FILE"
    printf "  %s  %s (%dms)\n" "$name" "$status" "$duration"
}

# 检查命令是否存在
has_cmd() { command -v "$1" >/dev/null 2>&1; }

# 1. Python
echo -n "[1/6] Python..."
if has_cmd python3 || has_cmd python; then
    PYTHON=$(has_cmd python3 && echo python3 || echo python)
    run_test "Python" "$PYTHON '${BASE_DIR}/show_code.py'"
else
    echo "  SKIP (python not installed)"
    echo "Python|SKIP (python not installed)|0|-1|" >> "$RESULTS_FILE"
fi

# 2. JavaScript (Node.js)
echo -n "[2/7] JavaScript..."
if has_cmd node; then
    run_test "JavaScript" "node '${BASE_DIR}/show_code.js'"
else
    echo "  SKIP (node not installed)"
    echo "JavaScript|SKIP (node not installed)|0|-1|" >> "$RESULTS_FILE"
fi

# 3. C# (自包含离线包)
echo -n "[3/7] C# (self-contained)..."
CS_BIN="${BASE_DIR}/deps/dotnet-linux-x64/csproj"
if [ -f "$CS_BIN" ]; then
    chmod +x "$CS_BIN" 2>/dev/null || true
    run_test "C#" "$CS_BIN"
else
    echo "  SKIP (offline package not found)"
    echo "C#|SKIP (offline package not found)|0|-1|" >> "$RESULTS_FILE"
fi

# 4. C (需要 gcc)
echo -n "[4/7] C..."
if has_cmd gcc; then
    mkdir -p "${BASE_DIR}/build"
    run_test "C" "gcc '${BASE_DIR}/show_code.c' -o '${BASE_DIR}/build/show_code_c' && '${BASE_DIR}/build/show_code_c'"
else
    echo "  SKIP (gcc not installed)"
    echo "C|SKIP (gcc not installed)|0|-1|" >> "$RESULTS_FILE"
fi

# 5. Go (需要 go)
echo -n "[5/7] Go..."
if has_cmd go; then
    run_test "Go" "go run '${BASE_DIR}/show_code.go'"
else
    echo "  SKIP (go not installed)"
    echo "Go|SKIP (go not installed)|0|-1|" >> "$RESULTS_FILE"
fi

# 6. Assembly (需要 nasm)
echo -n "[6/7] Assembly..."
if has_cmd nasm; then
    mkdir -p "${BASE_DIR}/build"
    # Linux x86_64: 使用 nasm -f elf64 + gcc 链接 (main entry)
    run_test "Assembly" "nasm -f elf64 '${BASE_DIR}/show_code.asm' -o '${BASE_DIR}/build/show_code.o' && gcc '${BASE_DIR}/build/show_code.o' -o '${BASE_DIR}/build/show_code_asm' -no-pie && '${BASE_DIR}/build/show_code_asm'"
else
    echo "  SKIP (nasm not installed)"
    echo "Assembly|SKIP (nasm not installed)|0|-1|" >> "$RESULTS_FILE"
fi

# 7. Java (需要 javac + java)
echo -n "[7/7] Java..."
if has_cmd javac && has_cmd java; then
    mkdir -p "${BASE_DIR}/build"
    run_test "Java" "javac -d '${BASE_DIR}/build' '${BASE_DIR}/ShowCode.java' && java -cp '${BASE_DIR}/build' ShowCode"
else
    echo "  SKIP (java/javac not installed)"
    echo "Java|SKIP (java/javac not installed)|0|-1|" >> "$RESULTS_FILE"
fi

# 二进制/十六进制说明
echo "Hex (machine code)|INFO (reference only)|0|0|N/A" >> "$RESULTS_FILE"
echo "Binary (machine code)|INFO (reference only)|0|0|N/A" >> "$RESULTS_FILE"

# 统计
PASS_COUNT=$(grep -c '|PASS|' "$RESULTS_FILE" || true)
SKIP_COUNT=$(grep -c '|SKIP' "$RESULTS_FILE" || true)
FAIL_COUNT=$(grep -c '|FAIL' "$RESULTS_FILE" || true)

# 环境信息
PYTHON_VER=$(has_cmd python3 && python3 --version 2>&1 || echo "未安装")
NODE_VER=$(has_cmd node && node --version 2>&1 || echo "未安装")
DOTNET_VER=$(has_cmd dotnet && dotnet --version 2>&1 || echo "未安装")
GCC_VER=$(has_cmd gcc && gcc --version 2>&1 | head -1 || echo "未安装")
GO_VER=$(has_cmd go && go version 2>&1 || echo "未安装")
NASM_VER=$(has_cmd nasm && nasm --version 2>&1 || echo "未安装")
JAVA_VER=$(has_cmd java && java -version 2>&1 | head -1 || echo "未安装")
OS_INFO=$(uname -srm 2>/dev/null || echo "unknown")

# 生成 Markdown 报告
{
    echo "# Cheap Talk - Linux 测试运行报告"
    echo ""
    echo "- **运行时间**: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "- **操作系统**: ${OS_INFO}"
    echo "- **期望输出**: \`Talk is cheap. Show me the code.\`"
    echo ""
    echo "## 环境信息"
    echo ""
    echo "| 工具 | 版本 | 状态 |"
    echo "|------|------|------|"
    echo "| Python | ${PYTHON_VER} | $(has_cmd python3 && echo '可用' || echo '缺失') |"
    echo "| Node.js | ${NODE_VER} | $(has_cmd node && echo '可用' || echo '缺失') |"
    echo "| .NET SDK | ${DOTNET_VER} | $(has_cmd dotnet && echo '可用' || echo '缺失') |"
    echo "| GCC | ${GCC_VER} | $(has_cmd gcc && echo '可用' || echo '缺失') |"
    echo "| Go | ${GO_VER} | $(has_cmd go && echo '可用' || echo '缺失') |"
    echo "| NASM | ${NASM_VER} | $(has_cmd nasm && echo '可用' || echo '缺失') |"
    echo "| Java | ${JAVA_VER} | $(has_cmd java && echo '可用' || echo '缺失') |"
    echo ""
    echo "## 离线依赖"
    echo ""
    echo "| 平台 | 路径 | 说明 |"
    echo "|------|------|------|"
    echo "| Windows x64 | \`deps/dotnet-win-x64/csproj.exe\` | C# 自包含发布包 |"
    echo "| Linux x64 | \`deps/dotnet-linux-x64/csproj\` | C# 自包含发布包 |"
    echo ""
    echo "## 测试结果汇总"
    echo ""
    echo "| 结果 | 数量 |"
    echo "|------|:----:|"
    echo "| PASS | ${PASS_COUNT} |"
    echo "| SKIP | ${SKIP_COUNT} |"
    echo "| FAIL | ${FAIL_COUNT} |"
    echo ""
    echo "## 详细测试结果"
    echo ""
    echo "| # | 语言 | 状态 | 耗时 | 退出码 | 实际输出 |"
    echo "|---|------|------|------|:------:|----------|"
    i=0
    while IFS='|' read -r name status dur ec out; do
        i=$((i + 1))
        echo "| ${i} | ${name} | ${status} | ${dur}ms | ${ec} | ${out} |"
    done < "$RESULTS_FILE"
    echo ""
    echo "## 离线运行说明"
    echo ""
    echo "### C# (已验证离线)"
    echo ""
    echo "C# 程序通过 \`dotnet publish --self-contained\` 发布为自包含应用："
    echo ""
    echo "\`\`\`bash"
    echo "dotnet publish -c Release -r win-x64   --self-contained true -o deps/dotnet-win-x64"
    echo "dotnet publish -c Release -r linux-x64 --self-contained true -o deps/dotnet-linux-x64"
    echo "\`\`\`"
    echo ""
    echo "发布包内含完整 .NET 运行时，目标机器**无需安装任何 .NET 环境**即可运行："
    echo ""
    echo "- **Windows**: 直接执行 \`deps/dotnet-win-x64/csproj.exe\`"
    echo "- **Linux**: 执行 \`chmod +x deps/dotnet-linux-x64/csproj && ./deps/dotnet-linux-x64/csproj\`"
    echo ""
    echo "### Python / JavaScript"
    echo ""
    echo "Python 和 Node.js 版本依赖对应的解释器运行时。若目标机器离线，需提前安装 Python / Node.js。"
    echo ""
    echo "### C / Go / Assembly"
    echo ""
    echo "这三个版本需要对应的编译工具链 (gcc / go / nasm)。安装工具链后即可编译运行。"
    echo ""
    echo "## 二进制版本说明"
    echo ""
    echo "\`show_code.hex\` 和 \`show_code.bin\` 是 x86_64 机器码的可读书写形式（参考用），不能直接执行。"
    echo "要获得可执行的二进制文件，需通过 nasm 汇编 \`show_code.asm\` 后链接生成。"
} > "$REPORT_PATH"

echo ""
echo "========================================"
echo "  PASS: ${PASS_COUNT} | SKIP: ${SKIP_COUNT} | FAIL: ${FAIL_COUNT}"
echo "  Report: ${REPORT_PATH}"
echo "========================================"
