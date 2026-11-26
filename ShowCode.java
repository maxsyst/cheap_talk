// Show me the code - with structured debug logging to stderr.
import java.time.Instant;
import java.time.Duration;
import java.lang.management.ManagementFactory;

public class ShowCode {

    private static void log(String level, String module, String msg) {
        String ts = Instant.now().toString().replace("T", " ").replace("Z", "");
        System.err.printf("%s | %-7s | %s | %s%n", ts, level, module, msg);
    }

    public static void showCode() {
        log("DEBUG", "showCode", "Entering showCode()");
        String message = "Talk is cheap. Show me the code.";
        log("INFO", "showCode", String.format("Message variable assigned (len=%d)", message.length()));
        log("DEBUG", "showCode", "Preparing to print to stdout");
        System.out.println(message);
        log("DEBUG", "showCode", "System.out.println() completed");
        log("DEBUG", "showCode", "Exiting showCode()");
    }

    public static void main(String[] args) {
        String pid = ManagementFactory.getRuntimeMXBean().getName();
        log("INFO", "main", "=== Process started ===");
        log("INFO", "main", "PID: " + pid);
        log("INFO", "main", "Java: " + System.getProperty("java.version"));
        log("INFO", "main", "Platform: " + System.getProperty("os.name") + " " + System.getProperty("os.arch"));
        log("INFO", "main", "Working dir: " + System.getProperty("user.dir"));

        Instant t0 = Instant.now();
        showCode();
        double elapsedMs = Duration.between(t0, Instant.now()).toNanos() / 1_000_000.0;
        log("INFO", "main", String.format("=== Process finished (elapsed: %.2fms) ===", elapsedMs));
    }
}
