using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;

class Program
{
    // ── Unified entry point ──────────────────────────────────────────────
    // This file is the project's main entry. It calls show_code/showCode in
    // every language defined in this project and collects results.
    //
    // Languages invoked directly (in-process):
    //   - C#  → ShowCodeCSharp()
    //
    // Languages invoked via child process:
    //   - Python     → python  show_code.py
    //   - JavaScript → node    show_code.js
    //   - Go         → go run  show_code.go
    //   - C          → gcc show_code.c -o build\show_code_c.exe && run
    //   - Java       → javac ShowCode.java && java ShowCode
    //   - Assembly   → nasm + gcc link + run
    // ─────────────────────────────────────────────────────────────────────

    private const string Expected = "Talk is cheap. Show me the code.";

    private static readonly string BaseDir = AppContext.BaseDirectory;

    private static void Log(string level, string module, string msg)
    {
        string ts = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
        Console.Error.WriteLine($"{ts} | {level,-7} | {module} | {msg}");
    }

    // ── Result record ────────────────────────────────────────────────────
    private record LangResult(string Language, string Status, string Stdout, string Stderr, double ElapsedMs);

    // ═══════════════════════════════════════════════════════════════════════
    // 1. C# (in-process, direct function call)
    // ═══════════════════════════════════════════════════════════════════════
    static void ShowCodeCSharp()
    {
        Log("DEBUG", "C#", "Entering ShowCode()");
        string message = Expected;
        Log("INFO", "C#", $"Message variable assigned (len={message.Length})");
        Log("DEBUG", "C#", "Preparing to print to stdout");
        Console.WriteLine(message);
        Log("DEBUG", "C#", "Console.WriteLine() completed");
        Log("DEBUG", "C#", "Exiting ShowCode()");
    }

    // ═══════════════════════════════════════════════════════════════════════
    // 2-7. Child-process invocations
    // ═══════════════════════════════════════════════════════════════════════
    private static LangResult InvokeChild(string language, string fileName, string arguments, string workingDir)
    {
        var sw = Stopwatch.StartNew();
        try
        {
            var psi = new ProcessStartInfo
            {
                FileName = fileName,
                Arguments = arguments,
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                WorkingDirectory = workingDir,
            };
            // Inherit PATH so tools like gcc/nasm/javac are found
            foreach (DictionaryEntry entry in Environment.GetEnvironmentVariables())
            {
                string key = (string)entry.Key;
                string val = (string)entry.Value!;
                if (key.Equals("PATH", StringComparison.OrdinalIgnoreCase))
                    val = Environment.ExpandEnvironmentVariables(val);
                psi.EnvironmentVariables[key] = val;
            }

            using var proc = Process.Start(psi)!;
            string stdout = proc.StandardOutput.ReadToEnd();
            string stderr = proc.StandardError.ReadToEnd();
            proc.WaitForExit(60000);
            sw.Stop();

            string status = proc.ExitCode == 0 && stdout.Trim() == Expected
                ? "PASS" : proc.ExitCode != 0 ? $"FAIL (exit {proc.ExitCode})" : "FAIL (output mismatch)";

            return new LangResult(language, status, stdout.Trim(), stderr.Trim(), sw.Elapsed.TotalMilliseconds);
        }
        catch (Exception ex)
        {
            sw.Stop();
            return new LangResult(language, $"ERROR: {ex.Message}", "", "", sw.Elapsed.TotalMilliseconds);
        }
    }

    // ── Build a shell command string for compile-then-run languages ──────
    private static LangResult InvokeShell(string language, string script, string workingDir)
    {
        var sw = Stopwatch.StartNew();
        try
        {
            // Write a temp .bat file
            string batFile = Path.Combine(Path.GetTempPath(), $"cheap_talk_entry_{Guid.NewGuid():N}.bat");
            File.WriteAllText(batFile, "@echo off\r\n" + script, System.Text.Encoding.ASCII);

            var psi = new ProcessStartInfo
            {
                FileName = "cmd.exe",
                Arguments = $"/c \"{batFile}\"",
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                WorkingDirectory = workingDir,
            };
            foreach (DictionaryEntry entry in Environment.GetEnvironmentVariables())
            {
                string key = (string)entry.Key;
                string val = (string)entry.Value!;
                // Expand %VAR% references (e.g. %JAVA_HOME%\bin) so cmd.exe child finds tools
                if (key.Equals("PATH", StringComparison.OrdinalIgnoreCase))
                    val = Environment.ExpandEnvironmentVariables(val);
                psi.EnvironmentVariables[key] = val;
            }

            using var proc = Process.Start(psi)!;
            string stdout = proc.StandardOutput.ReadToEnd();
            string stderr = proc.StandardError.ReadToEnd();
            proc.WaitForExit(60000);
            sw.Stop();

            File.Delete(batFile);

            string status = proc.ExitCode == 0 && stdout.Trim() == Expected
                ? "PASS" : proc.ExitCode != 0 ? $"FAIL (exit {proc.ExitCode})" : "FAIL (output mismatch)";

            return new LangResult(language, status, stdout.Trim(), stderr.Trim(), sw.Elapsed.TotalMilliseconds);
        }
        catch (Exception ex)
        {
            sw.Stop();
            return new LangResult(language, $"ERROR: {ex.Message}", "", "", sw.Elapsed.TotalMilliseconds);
        }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // Main — orchestrates all 7 language calls
    // ═══════════════════════════════════════════════════════════════════════
    static void Main(string[] args)
    {
        // Resolve project root: walk up from bin/.../ to the cheap_talk dir
        string root = BaseDir;
        while (!File.Exists(Path.Combine(root, "Program.cs")) && !File.Exists(Path.Combine(root, "csproj", "Program.cs")))
            root = Directory.GetParent(root)!.FullName;
        // root is now the cheap_talk directory
        string srcDir = File.Exists(Path.Combine(root, "show_code.py"))
            ? root
            : Directory.GetParent(root)!.FullName;

        string buildDir = Path.Combine(srcDir, "build");
        Directory.CreateDirectory(buildDir);

        Log("INFO", "main", "╔════════════════════════════════════════════════════╗");
        Log("INFO", "main", "║  Unified Entry Point — calling all 7 languages      ║");
        Log("INFO", "main", "╚════════════════════════════════════════════════════╝");
        Log("INFO", "main", $"PID: {Environment.ProcessId}");
        Log("INFO", "main", $".NET: {Environment.Version}");
        Log("INFO", "main", $"Platform: {Environment.OSVersion.VersionString}");
        Log("INFO", "main", $"Source dir: {srcDir}");
        Log("INFO", "main", $"Expected output: \"{Expected}\"");
        Log("INFO", "main", "");

        var results = new List<LangResult>();
        var totalSw = Stopwatch.StartNew();

        // ── 1. C# (direct in-process call) ────────────────────────────────
        Log("INFO", "main", "[1/7] C# (in-process)...");
        var csharpSw = Stopwatch.StartNew();
        // Redirect stdout so we can verify the output
        var savedOut = Console.Out;
        var csharpStdout = new StringWriter();
        Console.SetOut(csharpStdout);
        ShowCodeCSharp();
        Console.SetOut(savedOut);
        csharpSw.Stop();
        {
            string outStr = csharpStdout.ToString().Trim();
            string status = outStr == Expected ? "PASS" : "FAIL (output mismatch)";
            results.Add(new LangResult("C#", status, outStr, "(in-process, logs on stderr)", csharpSw.Elapsed.TotalMilliseconds));
        }
        Log("INFO", "main", $"  → {results[^1].Status} ({results[^1].ElapsedMs:F0}ms)");

        // ── 2. Python ──────────────────────────────────────────────────────
        Log("INFO", "main", "[2/7] Python...");
        string pyPath = FindExecutable("python") ?? FindExecutable("python3");
        if (pyPath != null)
            results.Add(InvokeChild("Python", pyPath, $"\"{Path.Combine(srcDir, "show_code.py")}\"", srcDir));
        else
            results.Add(new LangResult("Python", "SKIP (python not found)", "", "", 0));
        Log("INFO", "main", $"  → {results[^1].Status} ({results[^1].ElapsedMs:F0}ms)");

        // ── 3. JavaScript ──────────────────────────────────────────────────
        Log("INFO", "main", "[3/7] JavaScript...");
        string nodePath = FindExecutable("node");
        if (nodePath != null)
            results.Add(InvokeChild("JavaScript", nodePath, $"\"{Path.Combine(srcDir, "show_code.js")}\"", srcDir));
        else
            results.Add(new LangResult("JavaScript", "SKIP (node not found)", "", "", 0));
        Log("INFO", "main", $"  → {results[^1].Status} ({results[^1].ElapsedMs:F0}ms)");

        // ── 4. Go ──────────────────────────────────────────────────────────
        Log("INFO", "main", "[4/7] Go...");
        string goPath = FindExecutable("go");
        if (goPath != null)
            results.Add(InvokeChild("Go", goPath, $"run \"{Path.Combine(srcDir, "show_code.go")}\"", srcDir));
        else
            results.Add(new LangResult("Go", "SKIP (go not found)", "", "", 0));
        Log("INFO", "main", $"  → {results[^1].Status} ({results[^1].ElapsedMs:F0}ms)");

        // ── 5. C (compile + run) ───────────────────────────────────────────
        Log("INFO", "main", "[5/7] C...");
        string gccPath = FindExecutable("gcc");
        if (gccPath != null)
        {
            string cExe = Path.Combine(buildDir, "show_code_c.exe");
            string cScript = $"gcc \"{Path.Combine(srcDir, "show_code.c")}\" -o \"{cExe}\" && \"{cExe}\"";
            results.Add(InvokeShell("C", cScript, srcDir));
        }
        else
            results.Add(new LangResult("C", "SKIP (gcc not found)", "", "", 0));
        Log("INFO", "main", $"  → {results[^1].Status} ({results[^1].ElapsedMs:F0}ms)");

        // ── 6. Assembly (nasm + gcc link + run) ────────────────────────────
        Log("INFO", "main", "[6/7] Assembly...");
        string nasmPath = FindExecutable("nasm");
        if (nasmPath != null && gccPath != null)
        {
            string asmObj = Path.Combine(buildDir, "show_code_win.obj");
            string asmExe = Path.Combine(buildDir, "show_code_asm.exe");
            string asmScript = $"nasm -f win64 \"{Path.Combine(srcDir, "show_code_win.asm")}\" -o \"{asmObj}\" && gcc \"{asmObj}\" -o \"{asmExe}\" && \"{asmExe}\"";
            results.Add(InvokeShell("Assembly", asmScript, srcDir));
        }
        else
            results.Add(new LangResult("Assembly", "SKIP (nasm/gcc not found)", "", "", 0));
        Log("INFO", "main", $"  → {results[^1].Status} ({results[^1].ElapsedMs:F0}ms)");

        // ── 7. Java (compile + run) ────────────────────────────────────────
        Log("INFO", "main", "[7/7] Java...");
        string javacPath = FindExecutable("javac");
        string javaPath = FindExecutable("java");
        if (javacPath != null && javaPath != null)
        {
            string javaScript = $"javac -d \"{buildDir}\" \"{Path.Combine(srcDir, "ShowCode.java")}\" && java -cp \"{buildDir}\" ShowCode";
            results.Add(InvokeShell("Java", javaScript, srcDir));
        }
        else
            results.Add(new LangResult("Java", "SKIP (java/javac not found)", "", "", 0));
        Log("INFO", "main", $"  → {results[^1].Status} ({results[^1].ElapsedMs:F0}ms)");

        totalSw.Stop();

        // ── Summary ────────────────────────────────────────────────────────
        Log("INFO", "main", "");
        Log("INFO", "main", "══════════════════════════════════════════════════════");
        int pass = 0, skip = 0, fail = 0;
        foreach (var r in results)
        {
            if (r.Status == "PASS") pass++;
            else if (r.Status.StartsWith("SKIP")) skip++;
            else fail++;
        }

        // Print summary table to stdout
        Console.WriteLine();
        Console.WriteLine("┌──────────────────────────────────────────────────────────────────┐");
        Console.WriteLine("│          Unified Entry — All Language Results                   │");
        Console.WriteLine("├────────────┬──────────┬────────────────────┬──────────────────────┤");
        Console.WriteLine("│ Language   │ Status   │ Elapsed (ms)       │ stdout               │");
        Console.WriteLine("├────────────┼──────────┼────────────────────┼──────────────────────┤");
        foreach (var r in results)
        {
            Console.WriteLine($"│ {r.Language,-10} │ {r.Status,-8} │ {r.ElapsedMs,18:F0} │ {Truncate(r.Stdout, 20),-20} │");
        }
        Console.WriteLine("└────────────┴──────────┴────────────────────┴──────────────────────┘");
        Console.WriteLine();
        Console.WriteLine($"  PASS: {pass}  |  SKIP: {skip}  |  FAIL: {fail}  |  Total elapsed: {totalSw.Elapsed.TotalMilliseconds:F0}ms");
        Console.WriteLine();

        // Return exit code: 0 if all pass, 1 if any fail/skip
        Environment.ExitCode = (fail > 0) ? 1 : 0;
    }

    // ── Helpers ───────────────────────────────────────────────────────────
    private static string? FindExecutable(string name)
    {
        // Expand environment variables like %JAVA_HOME% in PATH
        string? rawPath = Environment.GetEnvironmentVariable("PATH");
        string? javaHome = Environment.GetEnvironmentVariable("JAVA_HOME");
        if (!string.IsNullOrEmpty(javaHome))
            rawPath = $"%JAVA_HOME%\\bin;{rawPath}";
        // Use Environment.ExpandEnvironmentVariables to resolve %VAR% references
        rawPath = Environment.ExpandEnvironmentVariables(rawPath ?? "");

        var paths = rawPath.Split(Path.PathSeparator);
        var exts = Environment.OSVersion.Platform == PlatformID.Win32NT
            ? new[] { ".exe", ".bat", ".cmd", "" }
            : new[] { "" };
        foreach (var dir in paths)
        {
            if (string.IsNullOrWhiteSpace(dir)) continue;
            foreach (var ext in exts)
            {
                string full = Path.Combine(dir.Trim('"'), name + ext);
                if (File.Exists(full)) return full;
            }
        }
        return null;
    }

    private static string Truncate(string s, int max)
    {
        if (string.IsNullOrEmpty(s)) return "(empty)";
        return s.Length <= max ? s : s[..max] + "...";
    }
}
