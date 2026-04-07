function ailab
    switch $argv[1]
        case 'chat'
            echo "🗣️  Opening Open WebUI..."
            xdg-open http://127.0.0.1:3000 2>/dev/null; or echo "Open: http://YOUR_DESKTOP_IP:3000"
        
        case 'edit'
            cd ~/lab-configs
            ~/ai-tools/bin/aider --model ollama/qwen2.5:14b --openai-api-base http://localhost:11434/v1 --openai-api-key not-needed --no-auto-commits --no-show-model-warnings --dark-mode $argv[2..]
        
        case 'sysedit'
            echo "🔐 Level 3: Controlled system edit"
            ~/bin/ai-edit-system $argv[2]
        
        case 'monitor'
            echo "📊 Live GPU Stats (Ctrl+C to exit)"; radeontop
        
        case 'status'
            echo "🤖 AI Lab Stack Status"
            echo "──────────────────────"
            echo -n "Ollama:  "; systemctl is-active ollama
            echo -n "Docker:  "; systemctl is-active docker
            echo -n "API:     "; curl -sf http://127.0.0.1:8888/health >/dev/null 2>&1; and echo "active"; or echo "inactive"
        
        case 'health'
            echo "🏥 AI Lab Health Status"
            echo "───────────────────────"
            echo -n "Ollama:      "; systemctl is-active ollama
            echo -n "Docker:      "; systemctl is-active docker
            echo -n "AI API:      "; curl -sf http://127.0.0.1:8888/health >/dev/null 2>&1; and echo "active"; or echo "inactive"
            echo -n "Disk:        "; df -h / | tail -1 | awk '{print $5 " used"}'
            set gt (sensors 2>/dev/null | grep -i edge: | awk '{print $2}' | tr -d '+°C')
            test -n "$gt"; and echo "GPU Temp:    "$gt"°C"; or echo "GPU Temp:    N/A"
            echo -n "Last Backup: "; bash -c 'ls -t ~/backups/ai-lab/ 2>/dev/null | head -1'
            echo ""
            echo "Logs: tail -10 ~/logs/ai-lab-healthcheck.log"
        
        case 'backup'
            echo "📦 AI Lab Backup Status"
            echo "───────────────────────"
            echo -n "Latest: "; bash -c 'ls -t ~/backups/ai-lab/ 2>/dev/null | head -1'
            echo ""
            echo -n "Total: "; bash -c 'ls ~/backups/ai-lab/ 2>/dev/null | wc -l'
            echo ""
            echo -n "Encrypted: "; bash -c 'latest=$(ls -t ~/backups/ai-lab/ 2>/dev/null | head -1); if [ -n "$latest" ]; then ls ~/backups/ai-lab/$latest/*.gpg 2>/dev/null | wc -l; else echo 0; fi'
            echo ""
            echo "Location: ~/backups/ai-lab/"
        case 'memory'
            echo "🧠 AI Lab Memory"
            echo "────────────────"
            echo ""
            # Show memory file
            if test -f ~/lab-configs/ai-lab-memory.md
                echo "📄 Location: ~/lab-configs/ai-lab-memory.md"
                echo "📊 Size: (du -h ~/lab-configs/ai-lab-memory.md | awk '{print $1}')"
                echo "🕐 Modified: (stat -c %y ~/lab-configs/ai-lab-memory.md 2>/dev/null | cut -d. -f1)"
                echo ""
                echo "Commands:"
                echo "  Edit:      nano ~/lab-configs/ai-lab-memory.md"
                echo "  View:      cat ~/lab-configs/ai-lab-memory.md"
                echo "  In Chat:   'Reference my lab memory file'"
            else
                echo "⚠️  Memory file not found"
                echo "Create: nano ~/lab-configs/ai-lab-memory.md"
            end
        
        case 'remember'
            # Quick add to memory
            if test (count $argv) -lt 2
                echo "Usage: ailab remember 'fact to remember'"
                echo "Example: ailab remember 'Prefer qwen2.5:14b for code tasks'"
                return 1
            end
            set -l note (string join ' ' $argv[2..])
            echo "- [ ] (date +%Y-%m-%d): $note" >> ~/lab-configs/ai-lab-memory.md
            echo "✅ Added to memory: $note"
            cd ~/lab-configs && git add ai-lab-memory.md && git commit -m "Memory: $note" 2>/dev/null
        case '*'
            echo "🤖 AI Lab: chat|edit|sysedit|status|health|backup|monitor"
    end
end
