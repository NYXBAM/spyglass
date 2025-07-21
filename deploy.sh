#!/bin/bash

cd /home/python-scripts/spyglass || exit 1

export PATH="/usr/bin:/bin:/usr/local/bin:$PATH"

VENV_DIR="venv"
if [ ! -d "$VENV_DIR" ]; then
    echo "[CI] $(date) — Virtual environment not found, creating..."
    python3 -m venv "$VENV_DIR" || exit 1
fi

source "$VENV_DIR/bin/activate" || exit 1
echo "[CI] $(date) — Virtual environment activated."

echo "[CI] $(date) — Checking for updates..."
git fetch origin master || exit 1

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/master)

check_and_restart_screen() {
    local session_name=$1
    local script_cmd=$2

    if screen -list | grep -q "$session_name"; then
        PID=$(pgrep -f "SCREEN.*$session_name.*python3")
        if [ -n "$PID" ]; then
            echo "[CI] ✅ $session_name is running (PID $PID)"
        else
            echo "[CI] ⚠️ '$session_name' screen exists but python3 is not running — restarting..."
            screen -S "$session_name" -X quit
            sleep 1
            screen -dmS "$session_name" $script_cmd
            echo "[CI] 🔁 $session_name restarted."
        fi
    else
        echo "[CI] 🟥 '$session_name' screen session not found — starting..."
        screen -dmS "$session_name" $script_cmd
        echo "[CI] ✅ $session_name started."
    fi
}

if [ "$LOCAL" = "$REMOTE" ]; then
    echo "[CI] $(date) — No changes in code."
else
    echo "[CI] $(date) — Update detected! Pulling changes..."
    git pull --no-edit origin master || exit 1

    echo "[CI] $(date) — Installing/updating dependencies..."
    pip3 install --upgrade pip || exit 1
    pip3 install -r requirements.txt --upgrade || exit 1
    echo "[CI] $(date) — Dependencies updated."
    
    echo "[CI] $(date) — Restarting screen sessions..."
    screen -S "spyglass" -X quit
    sleep 1
    screen -dmS "spyglass" python3 main.py

    screen -S "flask_app" -X quit
    sleep 1
    screen -dmS "flask_app" python3 -m web.app

    echo "[CI] $(date) — ✅ Updated and restarted."
    exit 0
fi

# Перевірка, якщо вже все оновлено — просто переконатись, що процеси працюють
check_and_restart_screen "spyglass" "python3 main.py"
check_and_restart_screen "flask_app" "python3 -m web.app"
