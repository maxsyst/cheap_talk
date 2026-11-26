package main

import (
	"fmt"
	"log"
	"os"
	"runtime"
	"time"
)

func init() {
	log.SetFlags(log.LstdFlags)
	log.SetPrefix("")
}

func showCode() {
	log.Println("[DEBUG] Entering showCode()")
	message := "Talk is cheap. Show me the code."
	log.Printf("[INFO] Message variable assigned (len=%d)\n", len(message))
	log.Println("[DEBUG] Preparing to print to stdout")
	fmt.Println(message)
	log.Println("[DEBUG] fmt.Println() completed")
	log.Println("[DEBUG] Exiting showCode()")
}

func main() {
	log.Println("[INFO] === Process started ===")
	log.Printf("[INFO] PID: %d\n", os.Getpid())
	log.Printf("[INFO] Go: %s\n", runtime.Version())
	log.Printf("[INFO] Platform: %s/%s\n", runtime.GOOS, runtime.GOARCH)
	dir, _ := os.Getwd()
	log.Printf("[INFO] Working dir: %s\n", dir)

	t0 := time.Now()
	showCode()
	elapsed := time.Since(t0)
	log.Printf("[INFO] === Process finished (elapsed: %.2fms) ===\n", float64(elapsed.Microseconds())/1000.0)
}
