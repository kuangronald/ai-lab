#!/bin/bash
# ~/bin/ailab-proxmox.sh - Proxmox API Helper

# Hardcoded values (users replace UUID only)
PROXMOX_HOST="10.10.10.2"
PROXMOX_NODE="promox"
PROXMOX_USER="root@pam"
PROXMOX_TOKEN_UUID="YOUR_TOKEN_UUID_HERE"

AUTH_HEADER="Authorization: PVEAPIToken=${PROXMOX_USER}!ai-lab-bot=${PROXMOX_TOKEN_UUID}"
API="https://${PROXMOX_HOST}:8006/api2/json"

call() {
    curl -4sk -m 10 -H "$AUTH_HEADER" "$1" 2>/dev/null
}

case "$1" in
    health)
        resp=$(call "${API}/version")
        if echo "$resp" | grep -q '"version"'; then
            ver=$(echo "$resp" | sed -n 's/.*"version":"\([^"]*\)".*/\1/p')
            echo "✅ Connected (Proxmox $ver)"
        else
            echo "❌ Failed - Response: '$resp'"
        fi
        ;;
    status)
        echo "📊 VM Status:"
        resp=$(call "${API}/nodes/${PROXMOX_NODE}/qemu")
        if echo "$resp" | grep -q '"vmid"'; then
            echo "$resp" | tr ',' '\n' | grep -E '"vmid"|"name"|"status"' | \
                sed 's/.*"//; s/".*//' | paste - - - | sed 's/^/  /'
        else
            echo "  (no VMs or permission denied)"
            echo "  Debug: '$resp'"
        fi
        ;;
    start)
        call "${API}/nodes/${PROXMOX_NODE}/qemu/$2/status/start" >/dev/null
        echo "✅ Starting VM $2"
        ;;
    stop)
        call "${API}/nodes/${PROXMOX_NODE}/qemu/$2/status/stop" >/dev/null
        echo "✅ Stopping VM $2"
        ;;
    debug)
        echo "=== Debug ==="
        echo "Host: $PROXMOX_HOST"
        echo "Node: $PROXMOX_NODE"
        echo "Auth: $AUTH_HEADER"
        echo "Version: $(call "${API}/version")"
        ;;
    *)
        echo "🔧 Proxmox Helper"
        echo "Usage: ailab-proxmox.sh {health|status|start|stop|debug} [vmid]"
        ;;
esac
