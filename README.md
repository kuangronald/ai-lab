AI Lab - Self-Hosted AI Automation

[![Status](https://img.shields.io/badge/status-complete-success)](https://github.com/kuangronald/ai-lab)
[![License](https://img.shields.io/badge/license-personal-blue)](https://github.com/kuangronald/ai-lab)
[![Stars](https://img.shields.io/github/stars/kuangronald/ai-lab)](https://github.com/kuangronald/ai-lab)

A private, offline, GPU-accelerated AI automation system with full infrastructure integration

================================================================================
TABLE OF CONTENTS
================================================================================

1. Overview
2. Features
3. Architecture
4. Quick Start
5. Command Reference
6. Configuration
7. Security
8. Backup & Recovery
9. Troubleshooting

================================================================================
1. OVERVIEW
================================================================================

This AI Lab provides 4 levels of AI assistance for managing self-hosted infrastructure:

Level 1: Chat Interface              -> ailab chat
Level 2: Git-Tracked Config Editing  -> ailab edit FILE
Level 3: System File Editing         -> ailab sysedit FILE
Level 4: Infrastructure Automation   -> ailab proxmox status

================================================================================
2. FEATURES
================================================================================

- 100% Local & Private    All AI runs offline via Ollama
- GPU-Accelerated         AMD RX 6700 XT (12GB VRAM)
- Encrypted Backups       GPG-encrypted daily backups
- Health Monitoring       Automated checks with Telegram alerts
- Proxmox Integration     Control VMs via API
- Conversation Memory     AI remembers lab context
- Git-Tracked             All config changes versioned & audited
- Remote Access           Tailscale for secure remote management

================================================================================
3. ARCHITECTURE
================================================================================

+------------------------------------------------------------------+
|                      AI LAB STACK                                |
+------------------------------------------------------------------+
|                                                                  |
|  +-------------+    +-------------+    +-------------------+     |
|  |   Desktop   |    |   Proxmox   |    |     OPNsense      |     |
|  |  (AI Host)  |    |  (VM Host)  |    |   (Firewall)      |     |
|  |             |    |             |    |                   |     |
|  | - Ollama    |    | - VMs       |    | - Firewall Rules  |     |
|  | - WebUI     |    | - Services  |    | - DHCP            |     |
|  | - API       |    | - Backups   |    | - Routing         |     |
|  +------+------+    +------+------+    +---------+---------+     |
|         |                  |                  |                   |
|         +------------------+------------------+                   |
|                            |                                      |
|         +------------------v------------------+                   |
|         |      Tailscale (Remote Access)      |                   |
|         +-------------------------------------+                   |
|                                                                  |
+------------------------------------------------------------------+

CORE SERVICES:
Service         Port    Purpose
Ollama          11434   Local LLM inference
Open WebUI      3000    Chat interface
AI Actions API  8888    Automation API
Proxmox API     8006    VM management

================================================================================
4. QUICK START
================================================================================

PREREQUISITES:
- CachyOS/Arch Linux
- AMD GPU (or NVIDIA with CUDA)
- Proxmox VE (optional)
- Tailscale account

INSTALLATION:
  # 1. Install Ollama
  curl -fsSL https://ollama.com/install.sh | sh

  # 2. Pull AI model
  ollama pull qwen2.5:14b

  # 3. Install Open WebUI
  docker run -d -p 3000:8080 \
    --add-host=host.docker.internal:host-gateway \
    -v open-webui:/app/backend/data \
    --name open-webui --restart always \
    ghcr.io/open-webui/open-webui:main

  # 4. Clone this repo
  git clone https://github.com/kuangronald/ai-lab.git
  cd ai-lab

  # 5. Configure
  cp examples/.env.example ~/ai-api/.env
  nano ~/ai-api/.env  # Edit with your values

  # 6. Install dependencies
  ./setup.sh

BASIC COMMANDS:
  ailab health              # Check system health
  ailab chat                # Open WebUI chat interface
  ailab proxmox status      # List Proxmox VMs
  ailab backup              # View backup status

================================================================================
5. COMMAND REFERENCE
================================================================================

MAIN COMMANDS:
ailab chat              Open WebUI chat interface
ailab edit FILE         Git-tracked config editing
ailab sysedit FILE      System file editing with backup
ailab status            Quick service status
ailab health            Full health dashboard
ailab backup            Backup status
ailab memory            View/edit AI memory
ailab monitor           Live GPU stats

PROXMOX INTEGRATION:
ailab proxmox health    Check Proxmox API connection
ailab proxmox status    List all VMs
ailab proxmox start ID  Start a VM
ailab proxmox stop ID   Stop a VM

================================================================================
6. CONFIGURATION
================================================================================

ENVIRONMENT VARIABLES (~/ai-api/.env):
  # AI API
  AI_API_TOKEN=your-api-token-here
  ALLOWED_ACTIONS=hello_world,restart_service,proxmox_status

  # Proxmox API
  PROXMOX_HOST=10.10.10.2
  PROXMOX_NODE=promox
  PROXMOX_USER=root@pam
  PROXMOX_TOKEN=root@pam!ai-lab-bot=YOUR_TOKEN_UUID_HERE

  # Telegram Alerts
  TELEGRAM_BOT_TOKEN=your-bot-token-here
  TELEGRAM_CHAT_ID=your-chat-id-here

KEY DIRECTORIES:
~/lab-configs/              Git-tracked configurations
~/ai-tools/                 Python virtual environment
~/ai-actions/               Automation scripts
~/ai-api/                   API server & credentials
~/backups/ai-lab/           Encrypted backups

================================================================================
7. SECURITY
================================================================================

SECURITY MEASURES:
Encrypted Backups       GPG encryption
API Authentication      Bearer tokens
Firewall Rules          OPNsense restrictions
Git Tracking            Full audit trail
Token Scope             Minimal permissions
Remote Access           Tailscale (encrypted)

BEST PRACTICES:
1. Never commit .env files
2. Scope API tokens minimally
3. Encrypt all backups before storage
4. Audit all config changes via git
5. Restrict firewall access to LAN only

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

RECOVERY:
  1. List backups: ls -lt ~/backups/ai-lab/
  2. Decrypt: gpg --decrypt ~/backups/ai-lab/DATE/config.tar.gz.gpg > config.tar.gz
  3. Extract: tar -xzf config.tar.gz -C ~/
  4. Restore: cp ~/backups/ai-api.env ~/ai-api/.env
  5. Reload: source ~/.config/fish/conf.d/ai-lab.fish

================================================================================
9. TROUBLESHOOTING
================================================================================

COMMON ISSUES:
Problem                     Solution
ailab command not found     source ~/.config/fish/conf.d/ai-lab.fish
Proxmox auth failure        Recreate token in Proxmox UI
Backup fails                Check GPG key & disk space
API returns 401             Verify AI_API_TOKEN in .env
GPU temp shows N/A          Check sensors output

DEBUG COMMANDS:
  ailab health
  tail -20 ~/logs/ai-lab-healthcheck.log
  ~/bin/ailab-proxmox.sh debug
  curl -H "Authorization: Bearer $(grep AI_API_TOKEN ~/ai-api/.env | cut -d= -f2)" http://127.0.0.1:8888/health

================================================================================
BUILT WITH
================================================================================

OS:           CachyOS (Arch-based)
Shell:        Fish
AI:           Ollama + qwen2.5:14b
GPU:          AMD RX 6700 XT (12GB)
Hypervisor:   Proxmox VE
Firewall:     OPNsense
Remote:       Tailscale

================================================================================
LICENSE
================================================================================

Personal Use Only - This is my personal infrastructure automation setup.
Feel free to use ideas and patterns for your own projects.

================================================================================

Made with love for the self-hosted community

Star this repo if you found it useful!
