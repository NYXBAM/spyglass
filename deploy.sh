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

pip3 install --upgrade pip || exit 1
pip3 install -r requirements.txt --upgrade || exit 1
echo "[CI] $(date) — Dependencies installed."


echo "[CI] $(date) — Checking for updates..."
git fetch origin master || exit 1

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/master)


check_and_restart_screen() {
    local session_name=$1
    local script_path=$2

    if screen -list | grep -q "$session_name"; then
        PID=$(pgrep -f "SCREEN.*$session_name.*python3")
        if [ -n "$PID" ]; then
            echo "[CI] ✅ $session_name is running (PID $PID)"
        else
            echo "[CI] ⚠️ '$session_name' screen exists but python3 is not running — restarting..."
            screen -S "$session_name" -X quit
            sleep 1
            screen -dmS "$session_name" python3 "$script_path"
            echo "[CI] 🔁 $session_name restarted."
        fi
    else
        echo "[CI] 🟥 '$session_name' screen session not found — starting..."
        screen -dmS "$session_name" python3 "$script_path"
        echo "[CI] ✅ $session_name started."
    fi
}

if [ "$LOCAL" = "$REMOTE" ]; then
    echo "[CI] $(date) — No changes in code."
    check_and_restart_screen "spyglass" "main.py"
    check_and_restart_screen "flask_app" ""web/app.py""
    exit 0
else
    echo "[CI] $(date) — Update detected! Pulling changes..."
    git pull --no-edit origin master || exit 1
    pip3 install -r requirements.txt --upgrade || exit 1
    echo "[CI] $(date) — Dependencies updated."
    echo "[CI] $(date) — Restarting screen sessions..."
    for session in "spyglass" "flask_app"; do
        screen -S "$session" -X quit
        sleep 1
        if [ "$session" = "spyglass" ]; then
            screen -dmS "$session" python3 main.py
        else
            screen -dmS "$session" python3 -m web.app
        fi
    done

    echo "[CI] $(date) — ✅ Updated and restarted."
fi