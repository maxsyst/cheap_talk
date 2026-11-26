#!/usr/bin/env python3
"""Debug version of show_code with structured logging output."""

import logging
import os
import sys
import time
from datetime import datetime

# Configure logging with timestamp, level, module, message
logging.basicConfig(
    level=logging.DEBUG,
    format="%(asctime)s | %(levelname)-7s | %(name)s | %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger("show_code")


def show_code():
    logger.debug("Entering show_code()")
    message = "Talk is cheap. Show me the code."
    logger.info("Message variable assigned (len=%d)", len(message))
    logger.debug("Preparing to print to stdout")
    print(message)
    logger.debug("print() completed")
    logger.debug("Exiting show_code()")


if __name__ == "__main__":
    logger.info("=== Process started ===")
    logger.info("PID: %d", os.getpid())
    logger.info("Python: %s", sys.version.split()[0])
    logger.info("Platform: %s", sys.platform)
    logger.info("Working dir: %s", os.getcwd())
    t0 = time.perf_counter()
    show_code()
    elapsed = (time.perf_counter() - t0) * 1000
    logger.info("=== Process finished (elapsed: %.2fms) ===", elapsed)
