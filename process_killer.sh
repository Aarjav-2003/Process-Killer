#!/bin/bash

# Threshold in % (e.g., kill if process uses more than 30% memory)
MEM_THRESHOLD=5
LOG_FILE="process_killer.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$DATE] Process Killer Started" >> $LOG_FILE

echo -e "\nTop 10 memory consuming processes:"
ps aux --sort=-%mem | awk 'NR<=10{print NR, $0}'

# Find processes using more than threshold memory
echo -e "\nScanning for processes using more than $MEM_THRESHOLD% memory..."

while read -r pid mem comm; do
    echo "Process: $comm | PID: $pid | Memory: $mem%"
    
    # Prompt before killing
    read -p "Kill this process? (y/n): " choice
    if [[ "$choice" == "y" ]]; then
        kill -9 "$pid"
        echo "[$DATE] Killed $comm (PID: $pid) using $mem%" >> $LOG_FILE
        echo "Process $pid killed."
    else
        echo "Skipped $pid"
    fi
done < <(ps -eo pid,%mem,comm --no-headers | awk -v threshold=$MEM_THRESHOLD '$2 > threshold { print $1, $2, $3 }')

echo -e "\nProcess Killer Script completed."
