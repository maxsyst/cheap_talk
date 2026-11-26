/**
 * Debug version of showCode with structured logging output.
 */
const os = require("os");
const process = require("process");

function timestamp() {
    return new Date().toISOString().replace("T", " ").replace("Z", "");
}

function log(level, module, msg) {
    process.stderr.write(`${timestamp()} | ${level.padEnd(7)} | ${module} | ${msg}\n`);
}

function showCode() {
    log("DEBUG", "showCode", "Entering showCode()");
    const message = "Talk is cheap. Show me the code.";
    log("INFO", "showCode", `Message variable assigned (len=${message.length})`);
    log("DEBUG", "showCode", "Preparing to print to stdout");
    console.log(message);
    log("DEBUG", "showCode", "console.log() completed");
    log("DEBUG", "showCode", "Exiting showCode()");
}

// Entry point
log("INFO", "main", "=== Process started ===");
log("INFO", "main", `PID: ${process.pid}`);
log("INFO", "main", `Node.js: ${process.version}`);
log("INFO", "main", `Platform: ${os.platform()} ${os.arch()}`);
log("INFO", "main", `Working dir: ${process.cwd()}`);

const t0 = performance.now();
showCode();
const elapsed = (performance.now() - t0).toFixed(2);
log("INFO", "main", `=== Process finished (elapsed: ${elapsed}ms) ===`);
