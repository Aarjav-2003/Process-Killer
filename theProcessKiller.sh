#!/bin/bash

# === CONFIGURATIONS ===
MEM_THRESHOLD=10        # in %
CPU_THRESHOLD=10        # in %
AUTO_MODE=true          # set to false for manual prompt
LOG_FILE="process_killer_log.txt"
QUARANTINE_DIR="/opt/quarantine"
KNOWN_THREATS=("crypto" "miner" "reverse_shell" "bot.py" "wget" "curl" "nc")
EMAIL_ALERT=false       # set true if you configure email
EMAIL_TO="your_email@example.com"

# === SETUP ===
DATE=$(date '+%Y-%m-%d %H:%M:%S')
mkdir -p "$QUARANTINE_DIR"
touch "$LOG_FILE"

echo "Launching..." && sleep 0.5
toilet -f mono12 -F metal "Process Killer"

echo "[$DATE] Process Killer Started" >> $LOG_FILE
echo -e "\nTop 10 memory consuming processes:"
ps aux --sort=-%mem | awk 'NR<=10{print NR, $0}'

echo -e "\nScanning for processes using more than $MEM_THRESHOLD% memory or $CPU_THRESHOLD% CPU...\n"

# === SCAN & ACTION ===
while read -r pid cpu mem comm; do

    # Skip if no PID (process might have ended)
    [[ -z "$pid" ]] && continue

    # Check thresholds
    cpu_check=$(echo "$cpu > $CPU_THRESHOLD" | bc)
    mem_check=$(echo "$mem > $MEM_THRESHOLD" | bc)

    if [[ $cpu_check -eq 1 || $mem_check -eq 1 ]]; then

        cmd_path=$(readlink -f /proc/"$pid"/exe 2>/dev/null)
        suspicious=false

        echo "Process: $comm | PID: $pid | CPU: $cpu% | Memory: $mem%"

        # === THREAT DETECTION ===
        for threat in "${KNOWN_THREATS[@]}"; do
            [[ "$comm" == *"$threat"* ]] && suspicious=true
        done

        [[ "$cmd_path" == *"/tmp/"* ]] && suspicious=true
        [[ "$comm" =~ ^(kthreadd|init|systemd|cron)$ && "$USER" != "root" ]] && suspicious=true

        if [ "$AUTO_MODE" = true ]; then
            if [ "$suspicious" = true ]; then
                echo "Suspicious process detected: $comm (PID $pid)" >> $LOG_FILE

                # Quarantine
                if [ -n "$cmd_path" ] && [ -f "$cmd_path" ]; then
                    cp "$cmd_path" "$QUARANTINE_DIR/$(basename "$cmd_path")-PID$pid"
                    chmod 000 "$QUARANTINE_DIR"/*
                    echo "Quarantined binary from $cmd_path" >> $LOG_FILE
                fi
            fi

            echo "[$DATE] Auto-killed PID $pid ($comm) - CPU: $cpu%, MEM: $mem%" >> $LOG_FILE
            #echo "Auto-killed $pid"
            if kill -0 "$pid" 2>/dev/null; then
                kill -9 "$pid"
                echo "Auto-killed $pid"
                #Email Alert
                echo "Process $process_name with PID $pid was killed due to high resource usage." | mail -s "Process Auto-Killed Alert" flowingmate18@gmail.com
            else
                echo "PID $pid already terminated"
            fi


            # Optional Email Alert
            if [ "$EMAIL_ALERT" = true ]; then
                echo -e "Suspicious process auto-killed:\nPID: $pid\nCMD: $comm\nCPU: $cpu%\nMEM: $mem%" \
                | mail -s "[ALERT] Process Killed on $(hostname)" "$EMAIL_TO"
            fi

        else
            read -p "Kill this process? (y/n): " choice
            if [[ "$choice" == "y" ]]; then
                kill -9 "$pid" && echo "[$DATE] Killed PID $pid ($comm) - CPU: $cpu%, MEM: $mem%" >> $LOG_FILE
                echo "Killed $pid"
            else
                echo "Skipped $pid"
            fi
        fi
    fi
done < <(ps -eo pid,%cpu,%mem,comm --no-headers)

#Behavior based detection

#Detect Execution from Suspicious Directories
cmd_path=$(readlink -f /proc/$pid/exe 2>/dev/null)

if [[ "$cmd_path" == /tmp/* || "$cmd_path" == /dev/shm/* ]]; then
    suspicious=true
    echo "Executed from suspicious location: $cmd_path" >> $LOG_FILE
fi

#Detect Reverse Shell Patterns (Open Network Ports)
if lsof -Pan -p "$pid" -i | grep -qE 'TCP.*(4444|5555|1337)'; then
    suspicious=true
    echo "Suspicious network activity (possible reverse shell) for PID $pid" >> $LOG_FILE
fi



#Track Access to Sensitive Files
if lsof -p "$pid" 2>/dev/null | grep -qE '/etc/passwd|.bash_history'; then
    suspicious=true
    echo "Sensitive file access by PID $pid" >> $LOG_FILE
fi

#Detect Shells Spawned in Unusual Ways
if [[ "$comm" =~ bash|sh|zsh|python|perl ]] && [[ "$(ps -o tty= -p $pid)" == "?" ]]; then
    suspicious=true
    echo "Background shell detected (no TTY): PID $pid" >> $LOG_FILE
fi


echo -e "\n[$DATE] Process Killer Script completed." >> $LOG_FILE
echo -e "\nProcess Killer Script completed."
LOG_FILE=~/process_killer_log.txt

echo "[$(date)] Process: $PROC_NAME | PID: $PID | CPU: $CPU | Memory: $MEM%" >> $LOG_FILE
