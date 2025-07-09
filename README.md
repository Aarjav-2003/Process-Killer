# 🛡️ Process Killer & Behavior-Based Threat Analyzer

A **Bash-based process monitoring and killer script** with a Python-powered **log analyzer**, built for system resource protection and **cyber threat detection** using behavioral indicators.

> ⚙️ Designed with automation, suspicious behavior detection, and optional email alerts to guard systems against rogue processes, malware behavior, and high-resource abuse.



## 📌 Key Features

- ✅ **CPU & Memory Threshold Monitoring**
- 🔍 **Behavioral Detection**: suspicious execution paths, reverse shells, shell abuse
- 🧠 **Known Threat Pattern Detection** (curl, miner, nc, etc.)
- 🗃️ **Quarantine Malicious Binaries**
- 📬 **Email Alerts** (optional)
- 📊 **Python Log Analyzer**:
  - Top 5 killed processes
  - Total kills
  - Time-based hourly patterns



## 🧠 Cybersecurity Concepts Used

| Concept | Applied In |
|--------|------------|
| **Threat Intelligence** | Recognizes known tool names like `curl`, `bot.py`, `nc`, etc. |
| **Vulnerability Mitigation** | Automatically kills rogue or over-consuming processes |
| **Behavior-Based Detection** | Detects reverse shells, suspicious directories (`/tmp/`, `/dev/shm/`) |
| **Incident Response** | Email alerts + quarantine for further analysis |
| **Privilege Escalation Mitigation** | Prevents unknown binaries from running silently |
| **Logging & Forensics** | Full process logs with timestamps for later analysis |
| **Automation & Hardening** | Cron/daemon compatibility for 24/7 defense |



## 🛠️ Setup Instructions

### 1. Clone or Download the Repo
```bash
git clone https://github.com/yourname/process-killer-analyzer.git
cd process-killer-analyzer
```
### 2. Configure the Bash Script
Edit the following variables in process_killer.sh as per your system:
```bash
MEM_THRESHOLD=10
CPU_THRESHOLD=10
EMAIL_TO="your_email@example.com"
EMAIL_ALERT=true     # only if mailutils is configured
```
> ⚠️ You may need to install bc, mailutils, or lsof depending on your Linux distro.
### 3. Run the Bash Script
```bash
chmod +x process_killer.sh
./process_killer.sh
```
### 4. Run the Log Analyzer
Make sure Python 3 is installed. Then:
```bash
python3 log_analyzer.py
```
> By default, it reads process_killer.log from the same directory.





