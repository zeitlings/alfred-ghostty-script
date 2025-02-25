#!/bin/zsh

TEST_VERY_SHORT="ls"

TEST_MEDIUM='echo "Starting mock process" && sleep 2 && echo "Processing files in directory" && sleep 1 && echo "Mock operation completed successfully" | grep "completed"'

TEST_LONG='for i in {1..5}; do echo "Processing mock item $i"; sleep 0.5; echo "Item $i status: $([ $((RANDOM % 2)) -eq 0 ] && echo '\''SUCCESS'\'' || echo '\''PENDING'\'')"; done | grep -v "PENDING" && echo "Mock data pipeline completed with $(( RANDOM % 100 )) records processed"'

TEST_VERY_LONG='mock_var="sample_data" && echo "Initializing mock environment with $mock_var" && for region in north south east west; do echo "Connecting to mock-server-$region"; sleep 0.3; echo "Server $region reports: $([ $((RANDOM % 3)) -eq 0 ] && echo '\''HIGH_LOAD'\'' || echo '\''NORMAL'\'')"; done | grep -v "HIGH_LOAD" | while read line; do echo "Logging: $line"; done && echo "Mock timestamp: $(date +%s)" && echo "Mock configuration: verbose=true debug=false region=us-west logging=minimal" | sed '\''s/=/ -> /g'\'' && echo "Mock execution completed with exit code: $((RANDOM % 5))" | tee >(cat > /dev/null) && echo "All mock operations finalized without modifying any real files"'

TEST_VERY_VERY_LONG='echo "Starting comprehensive mock diagnostic suite $(date)" && echo "=======================================" && echo "Phase 1: System Environment Simulation" && for environment_var in USER HOME PATH SHELL LANG TERM DISPLAY LOGNAME; do echo "Checking mock $environment_var: OK"; sleep 0.1; done && echo "Environment validation complete" && echo "=======================================" && echo "Phase 2: Network Simulation" && for protocol in HTTP HTTPS FTP SSH DNS SMTP DHCP NTP; do status=$((RANDOM % 10)); echo "Testing mock $protocol connection"; sleep 0.2; echo "Protocol $protocol: $((100 - status))% packet delivery"; [ $status -lt 2 ] && echo "$protocol optimal" || echo "$protocol acceptable"; done && echo "Network simulation complete" && echo "=======================================" && echo "Phase 3: Storage Analysis Simulation" && for filesystem in root home var usr tmp opt; do capacity=$((RANDOM % 100)); echo "Mock filesystem /$filesystem usage: ${capacity}%"; [ $capacity -gt 90 ] && echo "WARNING: Low space on /$filesystem" || echo "Space on /$filesystem acceptable"; sleep 0.15; done && echo "Storage simulation complete" && echo "=======================================" && echo "Phase 4: Process Monitoring Simulation" && for process_name in apache mysql postgres nginx mongodb redis python java nodejs php; do pid=$((RANDOM % 30000 + 1000)); mem=$((RANDOM % 2000 + 50)); cpu=$((RANDOM % 100)); echo "Mock process $process_name (PID: $pid) using ${mem}MB RAM and ${cpu}% CPU"; [ $cpu -gt 80 ] && echo "High CPU detected for $process_name" || echo "$process_name running normally"; sleep 0.1; done && echo "Process simulation complete" && echo "=======================================" && echo "Phase 5: Security Check Simulation" && for security_aspect in firewall antivirus permissions encryption certificates updates backups passwords; do score=$((RANDOM % 100)); echo "Mock $security_aspect check: $score/100"; [ $score -lt 70 ] && echo "Action recommended for $security_aspect" || echo "$security_aspect status acceptable"; sleep 0.15; done && echo "Security simulation complete" && echo "=======================================" && echo "Phase 6: Performance Benchmark Simulation" && for benchmark in disk_read disk_write memory_read memory_write cpu_single cpu_multi gpu_compute network_throughput; do score=$((RANDOM % 1000 + 500)); echo "Mock $benchmark benchmark score: $score"; [ $score -lt 800 ] && echo "$benchmark below expected range" || echo "$benchmark within expected parameters"; sleep 0.2; done && echo "Benchmark simulation complete" && echo "=======================================" && echo "Phase 7: Log Analysis Simulation" && for log_type in system application security network access error performance audit; do entries=$((RANDOM % 1000 + 50)); issues=$((RANDOM % 20)); echo "Analyzing mock $log_type logs: found $entries entries with $issues potential issues"; [ $issues -gt 10 ] && echo "High issue count in $log_type logs" || echo "$log_type logs acceptable"; sleep 0.15; done && echo "Log simulation complete" && echo "=======================================" && echo "Mock diagnostic summary:" && total_checks=$((RANDOM % 100 + 200)); passed=$((RANDOM % 50 + 150)); warnings=$((RANDOM % 30)); failures=$((RANDOM % 10)); echo "Total checks: $total_checks" && echo "Passed: $passed" && echo "Warnings: $warnings" && echo "Failures: $failures" && echo "Overall health score: $(( (passed * 100) / total_checks ))%" && echo "Mock diagnostic completed at $(date)" && echo "=======================================" && echo "No actual system files or configurations were modified during this simulation"'

abort_test() {
    local exit_code=$1
    local message=$2
    echo "\n\n⚠️  $message"
    echo "Aborting tests..."
    sleep 1
    echo "Test run aborted at $(date)"
    exit $exit_code
}

# Set up trap to catch Ctrl+C (SIGINT) and other exit signals
trap 'abort_test 130 "Interrupted by user (Ctrl+C)"' INT
trap 'abort_test 143 "Terminated (SIGTERM)"' TERM

# Non-blocking keyboard input check
check_for_abort() {
    # Check if any key has been pressed
    if read -t 0.1 -k 1 key; then
        abort_test 0 "Aborted by user"
    fi
}

countdown() {
    local seconds=$1
    local message=${2:-"Continuing in"}
    local completion_message=${3:-"completed!"}

    echo "$message $seconds seconds (press any key to abort)"

    local start_time=$(date +%s)
    local end_time=$((start_time + seconds))
    local current_time=$start_time
    local last_displayed=$seconds

    while [[ $current_time -lt $end_time ]]; do
        local remaining=$((end_time - current_time))

        if [[ $remaining -ne $last_displayed ]]; then
            printf "\r%s %d seconds..." "$message" $remaining
            last_displayed=$remaining
        fi

        check_for_abort
        sleep 0.1
        current_time=$(date +%s)
    done

    printf "\r%s                     \n" "$completion_message"
}

run_alfred_test() {
    local test_name=$1
    local test_command=$2
    local wait_time=$3

    echo "\n== Running Test: $test_name =="
    echo "Command length: $(echo "$test_command" | wc -c) characters"

    echo -n ">$test_command" | pbcopy

    osascript -e 'tell application id "com.runningwithcrayons.Alfred" to search'
    osascript -e 'tell application "System Events"
        keystroke "v" using {command down}
        delay 0.5
        keystroke return
    end tell'

    echo "Command submitted to Alfred.\nWaiting for completion..."
    countdown $wait_time "Waiting" "Test completed!"
}

echo "==================================="
echo "   Alfred Ghostty Integration Test"
echo "==================================="

echo "\nThis script will run 5 shell command tests through Alfred."
echo "Please ensure Alfred is properly configured to handle shell commands."
echo "You can abort the tests at any time by pressing ANY key."
echo "Ready to begin? (y/n): "
read response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo "Exiting script."
    exit 0
fi

countdown 3 "Starting tests in" "Starting tests now!"

run_alfred_test "1. Very Short" "$TEST_VERY_SHORT" 3
echo "\nContinuing to next test..."
countdown 5 "Next test in" "starting now!"

run_alfred_test "2. Medium" "$TEST_MEDIUM" 5
echo "\nContinuing to next test..."
countdown 5 "Next test in" "starting now!"

run_alfred_test "3. Long" "$TEST_LONG" 5
echo "\nContinuing to next test..."
countdown 5 "Next test in" "starting now!"

run_alfred_test "4. Very Long" "$TEST_VERY_LONG" 5
echo "\nContinuing to next test..."
countdown 5 "Next test in" "starting now!"

run_alfred_test "5. Very Very Long" "$TEST_VERY_VERY_LONG" 5

echo "\n==================================="
echo "All tests completed!"
echo "==================================="
echo "\nTest Results Summary:"
echo "✓ Very Short test"
echo "✓ Medium test"
echo "✓ Long test"
echo "✓ Very Long test"
echo "✓ Very Very Long test"
