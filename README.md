AI LAB - COMPLETE DOCUMENTATION
A private, offline, GPU-accelerated AI automation lab with Proxmox integration

================================================================================
TABLE OF CONTENTS
================================================================================

1. Overview
2. Architecture
3. Network Map
4. Quick Start
5. Command Reference
6. Configuration Files
7. Security
8. Backup & Recovery
9. Troubleshooting
10. Maintenance

================================================================================
1. OVERVIEW
================================================================================

This AI Lab provides 4 levels of AI assistance for managing self-hosted 
infrastructure:

Level 1: Chat Interface           -> ailab chat
Level 2: Git-Tracked Config Edit  -> ailab edit FILE
Level 3: System File Editing      -> ailab sysedit FILE
Level 4: Automation + Proxmox     -> ailab proxmox status

KEY FEATURES:
- Private & Offline (All AI runs locally via Ollama)
- GPU-Accelerated (AMD RX 6700 XT 12GB VRAM)
- Git-Tracked (All config changes versioned)
- Encrypted Backups (GPG-encrypted daily)
- Remote Access (Tailscale secure access)
- Health Monitoring (Automated checks with Telegram alerts)
- Proxmox Integration (Control VMs via API)
- Conversation Memory (AI remembers lab context)

================================================================================
2. ARCHITECTURE
================================================================================

+------------------------------------------------------------------+
|                      YOUR AI LAB                                 |
+------------------------------------------------------------------+
|                                                                  |
|  +-------------+    +-------------+    +-------------------+     |
|  |   Desktop   |    |   Proxmox   |    |     OPNsense      |     |
|  | 10.10.10.XXX|    | 10.10.10.2  |    |   10.10.10.1      |     |
|  |             |    |             |    |   (Gateway)       |     |
|  | - Fish Shell|    | - VMs       |    | - Firewall Rules  |     |
|  | - ailab CLI |    | - Jellyfin  |    | - DHCP            |     |
|  | - Open WebUI|    | - Backups   |    |                   |     |
|  | - Ollama    |    |             |    |                   |     |
|  +------+------+    +------+------+    +---------+---------+     |
|         |                  |                  |                   |
|         +------------------+------------------+                   |
|                            |                                      |
|         +------------------v------------------+                   |
|         |      Tailscale (Remote Access)      |                   |
|         +-------------------------------------+                   |
|                                                                  |
+------------------------------------------------------------------+

SERVICES:
Service         Port    Status Command
Ollama          11434   systemctl status ollama
Open WebUI      3000    systemctl status open-webui
AI Actions API  8888    systemctl status ai-actions-api
Docker          -       systemctl status docker
Proxmox API     8006    ailab proxmox health

================================================================================
3. NETWORK MAP
================================================================================

Device          IP              Purpose
OPNsense        10.10.10.1      Gateway, Firewall, DHCP
Proxmox         10.10.10.2      VM Host
Desktop         10.10.10.XXX    AI Lab Host
Tailscale       TAILSCALE_IP    Remote access IP

FIREWALL RULES (OPNsense):
Rule                        Source          Destination     Port    Purpose
Allow AI Lab to Proxmox     10.10.10.0/24   10.10.10.2      8006    Proxmox API
Allow LAN to Any            LAN net         any             any     General LAN

================================================================================
4. QUICK START
================================================================================

START ALL SERVICES:
  sudo systemctl start ollama
  sudo systemctl start open-webui
  sudo systemctl start ai-actions-api
  ailab health

OPEN CHAT INTERFACE:
  ailab chat
  OR
  xdg-open http://127.0.0.1:3000

REMOTE ACCESS (via Tailscale):
  WebUI: http://TAILSCALE_IP:3000
  API:   http://TAILSCALE_IP:8888

================================================================================
5. COMMAND REFERENCE
================================================================================

MAIN AILAB COMMANDS:
ailab chat              Open WebUI chat interface
ailab edit FILE         Git-tracked config editing (Level 2)
ailab sysedit FILE      System file editing with backup (Level 3)
ailab status            Quick service status check
ailab health            Full health dashboard
ailab backup            Backup status
ailab memory            View/edit AI memory
ailab remember 'fact'   Add note to AI memory
ailab monitor           Live GPU stats
ailab proxmox health    Check Proxmox API connection
ailab proxmox status    List all Proxmox VMs
ailab proxmox start ID  Start a VM
ailab proxmox stop ID   Stop a VM

DIRECT SCRIPT ACCESS:
~/bin/ailab-proxmox.sh        Proxmox API helper
~/bin/ai-lab-healthcheck.sh   Health monitoring
~/bin/ai-lab-backup.sh        Backup automation
~/bin/ai-lab-alert.sh         Telegram alerts

================================================================================
6. CONFIGURATION FILES
================================================================================

KEY DIRECTORIES:
~/lab-configs/              Git-tracked configurations
~/ai-tools/                 Python venv (aider, etc.)
~/ai-actions/               Level 4 automation scripts
~/ai-api/                   API server and credentials
~/backups/ai-lab/           Encrypted backups
~/logs/                     System logs
~/.config/fish/conf.d/      Fish shell functions

CRITICAL FILES:
~/ai-api/.env                       API tokens, Proxmox credentials
~/.config/fish/conf.d/ai-lab.fish   Main ailab function
~/lab-configs/ai-lab-memory.md      AI conversation memory
~/bin/ailab-proxmox.sh              Proxmox integration

ENVIRONMENT VARIABLES (.env):
  AI_API_TOKEN=your-token-here
  ALLOWED_ACTIONS=hello_world,restart_service,proxmox_status
  
  PROXMOX_HOST=10.10.10.2
  PROXMOX_NODE=promox
  PROXMOX_USER=root@pam
  PROXMOX_TOKEN=root@pam!ai-lab-bot=uuid-here
  
  TELEGRAM_BOT_TOKEN=your-bot-token
  TELEGRAM_CHAT_ID=your-chat-id

================================================================================
7. SECURITY
================================================================================

SECURITY MEASURES:
Encrypted Backups       GPG encryption with your GPG key
API Authentication      Bearer tokens for all API calls
Firewall Rules          OPNsense restricts API access to LAN
Git Tracking            All config changes audited
Proxmox Token Scope     PVEAuditor (read-only) unless elevated
File Permissions        .env files chmod 600
Remote Access           Tailscale (encrypted, authenticated)

SECURITY CHECKLIST:
[ ] .env files are chmod 600
[ ] GPG secret key backed up securely
[ ] Proxmox token has minimal permissions
[ ] OPNsense firewall rules restrict API access
[ ] Telegram bot token stored encrypted
[ ] Regular backup verification

GPG KEY BACKUP:
  gpg --export-secret-keys -a "YOUR_EMAIL" > ~/backups/gpg-secret.asc
  chmod 600 ~/backups/gpg-secret.asc
  gpg --import ~/backups/gpg-secret.asc

================================================================================
8. BACKUP & RECOVERY
================================================================================

BACKUP SCHEDULE:
Type            Frequency       Location
Config Backups  Daily           ~/backups/ai-lab/
GPG Key         Manual          ~/backups/gpg-secret.asc
Full System     Weekly          External drive

MANUAL BACKUP:
  ~/bin/ai-lab-backup.sh
  ailab backup
  ls -lt ~/backups/ai-lab/ | head -5

RECOVERY STEPS:
  1. List available backups: ls -lt ~/backups/ai-lab/
  2. Decrypt a backup: gpg --decrypt ~/backups/ai-lab/DATE/config.tar.gz.gpg > config.tar.gz
  3. Extract: tar -xzf config.tar.gz -C ~/
  4. Restore .env files: cp ~/backups/ai-api.env ~/ai-api/.env
  5. Reload functions: source ~/.config/fish/conf.d/ai-lab.fish

================================================================================
9. TROUBLESHOOTING
================================================================================

COMMON ISSUES:
Problem                     Solution
ailab command not found     source ~/.config/fish/conf.d/ai-lab.fish
Proxmox auth failure        Recreate token in Proxmox UI, update .env
Backup fails                Check GPG key, verify disk space
API returns 401             Check AI_API_TOKEN in .env
Telegram alerts not working Verify bot token and chat ID
GPU temp shows N/A          Check sensors output, update path

DEBUG COMMANDS:
  ailab health
  tail -20 ~/logs/ai-lab-healthcheck.log
  ~/bin/ailab-proxmox.sh debug
  curl -H "Authorization: Bearer $(grep AI_API_TOKEN ~/ai-api/.env | cut -d= -f2)" http://127.0.0.1:8888/health
  functions ailab | head -20

RESET PROCEDURES:
  cp ~/.config/fish/conf.d/ai-lab.fish.bak ~/.config/fish/conf.d/ai-lab.fish
  source ~/.config/fish/conf.d/ai-lab.fish
  sudo systemctl restart ollama open-webui ai-actions-api

================================================================================
10. MAINTENANCE
================================================================================

WEEKLY TASKS:
  1. Verify backups: ailab backup
  2. Check health logs: tail -50 ~/logs/ai-lab-healthcheck.log
  3. Review git changes: cd ~/lab-configs && git status
  4. Check disk space: df -h /
  5. Update AI memory: ailab memory

MONTHLY TASKS:
Task                    Command
Update Ollama models    ollama pull qwen2.5:14b
Review firewall rules   OPNsense UI > Firewall > Rules
Verify GPG key backup   gpg --list-secret-keys
Test recovery           Restore from backup to test directory
Review Telegram alerts  Check alert history

UPDATE PROCEDURES:
  ollama pull qwen2.5:14b
  ollama pull llama3.2:3b
  sudo pacman -Syu
  cd ~/ai-tools && source venv/bin/activate && pip install --upgrade -r requirements.txt
  source ~/.config/fish/conf.d/ai-lab.fish

================================================================================
SUPPORT & RESOURCES
================================================================================

LOG LOCATIONS:
Health Checks     ~/logs/ai-lab-healthcheck.log
Backups           ~/logs/ai-lab-backup.log
Alerts            ~/logs/ai-lab-alerts.log
AI Audit          ~/lab-configs/.ai-audit.log
API Server        journalctl -u ai-actions-api -f

USEFUL COMMANDS:
  tail -f ~/logs/ai-lab-*.log
  grep -i "error|fail" ~/logs/*.log
  systemctl status ollama open-webui ai-actions-api docker
  ~/bin/ailab-proxmox.sh debug

================================================================================
VERSION HISTORY
================================================================================

Version   Date        Changes
1.0       2026-04-04  Initial setup complete
1.1       2026-04-04  Proxmox integration added
1.2       2026-04-04  Conversation memory implemented
1.3       2026-04-04  Documentation complete

================================================================================
CREDITS
================================================================================

Built by:     YOUR_USERNAME
OS:           CachyOS (Arch-based)
Shell:        Fish
AI Model:     qwen2.5:14b via Ollama
GPU:          AMD RX 6700 XT (12GB)

================================================================================
LICENSE
================================================================================

Personal Use Only - Keep your tokens, keys, and credentials secure.

Last Updated: 2026-04-04
Document Version: 1.3

================================================================================
QUICK REFERENCE CARD
================================================================================

+----------------------------------------------------------+
|                   AI LAB QUICK REF                       |
+----------------------------------------------------------+
| ailab chat           > Open WebUI                        |
| ailab health         > Check all services                |
| ailab backup         > Backup status                     |
| ailab proxmox status > List VMs                          |
| ailab memory         > View AI memory                    |
|                                                            |
| Proxmox: 10.10.10.2:8006                                 |
| WebUI:   10.10.10.XXX:3000                               |
| Remote:  TAILSCALE_IP:3000                               |
+----------------------------------------------------------+

Made with love for the self-hosted community
