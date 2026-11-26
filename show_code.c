/* Show me the code - with structured debug logging to stderr.
 * Cross-platform: works on both Windows and Linux. */
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>

#ifdef _WIN32
#include <windows.h>
#define GET_PID() ((int)GetCurrentProcessId())
#define GET_CWD(buf, size) GetCurrentDirectoryA(size, buf)
typedef unsigned long long perf_counter_t;
static double get_elapsed_ms(perf_counter_t t0, perf_counter_t t1) {
    LARGE_INTEGER freq;
    QueryPerformanceFrequency(&freq);
    return (double)(t1 - t0) * 1000.0 / freq.QuadPart;
}
static void perf_now(perf_counter_t *t) {
    LARGE_INTEGER li;
    QueryPerformanceCounter(&li);
    *t = li.QuadPart;
}
#else
#include <sys/time.h>
#define GET_PID() ((int)getpid())
#define GET_CWD(buf, size) getcwd(buf, size)
typedef struct timeval perf_counter_t;
static double get_elapsed_ms(perf_counter_t t0, perf_counter_t t1) {
    return (double)(t1.tv_sec - t0.tv_sec) * 1000.0 + (double)(t1.tv_usec - t0.tv_usec) / 1000.0;
}
static void perf_now(perf_counter_t *t) {
    gettimeofday(t, NULL);
}
#endif

static void log_msg(const char *level, const char *module, const char *msg) {
    time_t now = time(NULL);
    struct tm *tm_info = localtime(&now);
    char ts[20];
    strftime(ts, sizeof(ts), "%Y-%m-%d %H:%M:%S", tm_info);
    fprintf(stderr, "%s | %-7s | %s | %s\n", ts, level, module, msg);
}

void show_code(void) {
    log_msg("DEBUG", "show_code", "Entering show_code()");
    const char *message = "Talk is cheap. Show me the code.";
    char buf[128];
    sprintf(buf, "Message variable assigned (len=%zu)", strlen(message));
    log_msg("INFO", "show_code", buf);
    log_msg("DEBUG", "show_code", "Preparing to print to stdout");
    printf("%s\n", message);
    fflush(stdout);
    log_msg("DEBUG", "show_code", "printf() completed");
    log_msg("DEBUG", "show_code", "Exiting show_code()");
}

int main(void) {
    log_msg("INFO", "main", "=== Process started ===");
    char buf[256];
    sprintf(buf, "PID: %d", GET_PID());
    log_msg("INFO", "main", buf);
#ifdef _WIN32
    log_msg("INFO", "main", "Platform: Windows x64 (MinGW GCC)");
#else
    log_msg("INFO", "main", "Platform: Linux x64 (GCC)");
#endif

    char cwd[4096];
    if (GET_CWD(cwd, sizeof(cwd))) {
        sprintf(buf, "Working dir: %s", cwd);
    } else {
        sprintf(buf, "Working dir: (unknown)");
    }
    log_msg("INFO", "main", buf);

    perf_counter_t t0, t1;
    perf_now(&t0);
    show_code();
    perf_now(&t1);
    sprintf(buf, "=== Process finished (elapsed: %.2fms) ===", get_elapsed_ms(t0, t1));
    log_msg("INFO", "main", buf);

    return 0;
}
