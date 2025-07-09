# log_analyzer.py

from collections import Counter
import re
from datetime import datetime

import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
LOG_PATH = os.path.join(BASE_DIR, 'process_killer.log')


def parse_log_line(line):
    match = re.search(r'\[(.*?)\] Process: (.*?) \| PID: (\d+) \| CPU: ([\d.]+) \| Memory: ([\d.]+)%', line)
    if match:
        timestamp_str, proc, pid, cpu, mem = match.groups()
        timestamp = datetime.strptime(timestamp_str, "%a %b %d %H:%M:%S %Z %Y")
        return {
            'timestamp': timestamp,
            'process': proc,
            'pid': int(pid),
            'cpu': float(cpu),
            'memory': float(mem)
        }
    return None

def analyze_log():
    import os

    if not os.path.exists(LOG_PATH):
        print(f"[ERROR] Log file does not exist: {LOG_PATH}")
        exit(1)

    with open(LOG_PATH, 'r') as file:
        lines = file.readlines()

    entries = [parse_log_line(line) for line in lines if parse_log_line(line)]

    top_processes = Counter([e['process'] for e in entries]).most_common(5)

    print("\n🔍 Top 5 Killed Processes:")
    for proc, count in top_processes:
        print(f"{proc}: {count} times")

    total_kills = len(entries)
    print(f"\n📊 Total Processes Killed: {total_kills}")

    # Optional: time-based pattern (hourly distribution)
    hourly = Counter([e['timestamp'].hour for e in entries])
    print("\n🕒 Kill Count by Hour:")
    for hour in sorted(hourly):
        print(f"{hour}:00 - {hourly[hour]} kills")

if __name__ == "__main__":
    analyze_log()


