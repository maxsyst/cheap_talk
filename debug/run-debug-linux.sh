#!/usr/bin/env bash
#=============================================================================
# Debug environment runner - runs all 7 language debug versions and captures logs
# stdout = program output, stderr = debug logs
#=============================================================================

set -e
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
EXPECTED="Talk is cheap. Show me the code."
REPORT_PATH="${BASE_DIR}/debug-report-linux.md"
RESULTS_FILE="${BASE_DIR}/.debug-results-linux.tsv"
: > "$RESULTS_FILE"

has_cmd() { command -v "$1" >/dev/null 2>&1; }

run_debug() {
    local name="$1"
    local cmd="$2"
    local stdout stderr exit_code status
    local t0 t1

    mkdir -p "${BASE_DIR}/build"

    t0=$(date +%s%3N 2>/dev/null || python3 -c 'import time;print(int(time.time()*1000))')
    stderr=$(eval "$cmd" 2>&1 1>/tmp/ct_stdout_$$) || true
    stdout=$(cat /tmp/ct_stdout_$$)
    rm -f /tmp/ct_stdout_$$
    exit_code=$?
    t1=$(date +%s%3N 2>/dev/null || python3 -c 'import time;print(int(time.time()*1000))')
    local dur=$((t1 - t0))

    stdout=$(echo "$stdout" | tr -d '\r' | head -1)

    if [ "$exit_code" -eq 0 ] && [ "$stdout" = "$EXPECTED" ]; then
        status="PASS"
    elif [ "$exit_code" -ne 0 ]; then
        status="FAIL (exit $exit_code)"
    else
        status="FAIL (output mismatch)"
    fi

    echo "${name}|${status}|${dur}|${exit_code}|${stdout}" >> "$RESULTS_FILE"
    printf "  %s  %s (%dms)\n" "$name" "$status" "$dur"
}

echo "========================================"
echo "  Cheap Talk - DEBUG Environment Runner"
echo "  $(date '+%Y-%m-%d %H:%M:%S')"
echo "========================================"
echo ""

# 1. Python
echo -n "[1/7] Python (debug)..."
if has_cmd python3 || has_cmd python; then
    PY=$(has_cmd python3 && echo python3 || echo python)
    run_debug "Python" "$PY '${BASE_DIR}/show_code_debug.py'"
else
    echo "  SKIP (python not installed)"
    echo "Python|SKIP|0|-1|" >> "$RESULTS_FILE"
fi

# 2. JavaScript
echo -n "[2/7] JavaScript (debug)..."
if has_cmd node; then
    run_debug "JavaScript" "node '${BASE_DIR}/show_code_debug.js'"
else
    echo "  SKIP (node not installed)"
    echo "JavaScript|SKIP|0|-1|" >> "$RESULTS_FILE"
fi

# 3. C#
echo -n "[3/7] C# (debug)..."
if [ -d "${BASE_DIR}/csproj_debug" ]; then
    run_debug "C#" "dotnet run --project '${BASE_DIR}/csproj_debug'"
else
    echo "  SKIP (csproj_debug not found)"
    echo "C#|SKIP|0|-1|" >> "$RESULTS_FILE"
fi

# 4. C
echo -n "[4/7] C (debug)..."
if has_cmd gcc; then
    run_debug "C" "gcc -g -O0 '${BASE_DIR}/show_code_debug.c' -o '${BASE_DIR}/build/show_code_debug_c' && '${BASE_DIR}/build/show_code_debug_c'"
else
    echo "  SKIP (gcc not installed)"
    echo "C|SKIP|0|-1|" >> "$RESULTS_FILE"
fi

# 5. Go
echo -n "[5/7] Go (debug)..."
if has_cmd go; then
    run_debug "Go" "go run '${BASE_DIR}/show_code_debug.go'"
else
    echo "  SKIP (go not installed)"
    echo "Go|SKIP|0|-1|" >> "$RESULTS_FILE"
fi

# 6. Assembly
echo -n "[6/7] Assembly (debug)..."
if has_cmd nasm; then
    run_debug "Assembly" "nasm -f elf64 -g '${BASE_DIR}/show_code_debug_win.asm' -o '${BASE_DIR}/build/show_code_debug.o' && gcc -g '${BASE_DIR}/build/show_code_debug.o' -o '${BASE_DIR}/build/show_code_debug_asm' && '${BASE_DIR}/build/show_code_debug_asm'"
else
    echo "  SKIP (nasm not installed)"
    echo "Assembly|SKIP|0|-1|" >> "$RESULTS_FILE"
fi

# 7. Java
echo -n "[7/7] Java (debug)..."
if has_cmd javac && has_cmd java; then
    run_debug "Java" "javac -g -d '${BASE_DIR}/build' '${BASE_DIR}/ShowCodeDebug.java' && java -cp '${BASE_DIR}/build' ShowCodeDebug"
else
    echo "  SKIP (java/javac not installed)"
    echo "Java|SKIP|0|-1|" >> "$RESULTS_FILE"
fi

# Stats
PASS_COUNT=$(grep -c '|PASS|' "$RESULTS_FILE" || true)
FAIL_COUNT=$(grep -c '|FAIL' "$RESULTS_FILE" || true)
SKIP_COUNT=$(grep -c '|SKIP' "$RESULTS_FILE" || true)
OS_INFO=$(uname -srm 2>/dev/null || echo "unknown")

# Generate report
{
    echo "# Cheap Talk - Debug Environment Report (Linux)"
    echo ""
    echo "- **Time**: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "- **OS**: ${OS_INFO}"
    echo "- **Expected stdout**: \`Talk is cheap. Show me the code.\`"
    echo "- **Debug logs**: Written to stderr (structured: \`timestamp | LEVEL | module | message\`)"
    echo ""
    echo "## Test Summary"
    echo ""
    echo "| Result | Count |"
    echo "|--------|:-----:|"
    echo "| PASS | ${PASS_COUNT} |"
    echo "| SKIP | ${SKIP_COUNT} |"
    echo "| FAIL | ${FAIL_COUNT} |"
    echo ""
    echo "## Detailed Results"
    echo ""
    echo "| # | Language | Status | Duration | Exit Code | stdout |"
    echo "|---|----------|--------|----------|:---------:|--------|"
    i=0
    while IFS='|' read -r name status dur ec out; do
        i=$((i + 1))
        echo "| ${i} | ${name} | ${status} | ${dur}ms | ${ec} | ${out} |"
    done < "$RESULTS_FILE"
    echo ""
    echo "## Debug Environment Setup"
    echo ""
    echo "### Log Format"
    echo ""
    echo "All debug versions output structured logs to **stderr**:"
    echo ""
    echo "\`\`\`\`"
    echo "2026-11-19 10:00:00 | INFO    | main      | === Process started ==="
    echo "2026-11-19 10:00:00 | DEBUG   | show_code | Entering show_code()"
    echo "Talk is cheap. Show me the code."
    echo "2026-11-19 10:00:00 | INFO    | main      | === Process finished ==="
    echo "\`\`\`\`"
    echo ""
    echo "### VS Code Debug Configurations"
    echo ""
    echo "Located at \`.vscode/launch.json\` in project root:"
    echo ""
    echo "| Config | Language | Debugger |"
    echo "|--------|----------|----------|"
    echo "| Debug: Python | Python | debugpy |"
    echo "| Debug: JavaScript | JavaScript | Node.js |"
    echo "| Debug: Go | Go | delve |"
    echo "| Debug: Java | Java | Java debugger |"
    echo "| Debug: C# | C# | coreclr |"
    echo "| Debug: C | C | gdb (cppdbg) |"
    echo "| Debug: Assembly | Assembly | gdb (cppdbg) |"
} > "$REPORT_PATH"

echo ""
echo "========================================"
echo "  PASS: ${PASS_COUNT} | SKIP: ${SKIP_COUNT} | FAIL: ${FAIL_COUNT}"
echo "  Report: ${REPORT_PATH}"
echo "========================================"
