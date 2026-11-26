using System;
using System.Diagnostics;

class Program
{
    private static void Log(string level, string module, string msg)
    {
        string ts = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
        Console.Error.WriteLine($"{ts} | {level,-7} | {module} | {msg}");
    }

    static void ShowCode()
    {
        Log("DEBUG", "ShowCode", "Entering ShowCode()");
        string message = "Talk is cheap. Show me the code.";
        Log("INFO", "ShowCode", $"Message variable assigned (len={message.Length})");
        Log("DEBUG", "ShowCode", "Preparing to print to stdout");
        Console.WriteLine(message);
        Log("DEBUG", "ShowCode", "Console.WriteLine() completed");
        Log("DEBUG", "ShowCode", "Exiting ShowCode()");
    }

    static void Main()
    {
        Log("INFO", "main", "=== Process started ===");
        Log("INFO", "main", $"PID: {Environment.ProcessId}");
        Log("INFO", "main", $".NET: {Environment.Version}");
        Log("INFO", "main", $"Platform: {Environment.OSVersion.VersionString}");
        Log("INFO", "main", $"Working dir: {Environment.CurrentDirectory}");

        var sw = Stopwatch.StartNew();
        ShowCode();
        sw.Stop();
        Log("INFO", "main", $"=== Process finished (elapsed: {sw.Elapsed.TotalMilliseconds:F2}ms) ===");
    }
}
