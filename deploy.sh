#!/bin/bash

set -e

cd /home/python-scripts/spyglass || exit 1

VENV_DIR="venv"
SESSION_1="spyglass"
SESSION_2="flask_app"
PYTHON_SCRIPT_1="python3 main.py"
PYTHON_SCRIPT_2="python3 -m web.app"
export PATH="/usr/bin:/bin:/usr/local/bin:$PATH"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log() {
    echo -e "${CYAN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

if [ ! -d "$VENV_DIR" ]; then
    log "${YELLOW}Virtual environment not found, creating...${NC}"
    python3 -m venv "$VENV_DIR"
fi

source "$VENV_DIR/bin/activate"
log "${GREEN}Virtual environment activated.${NC}"

log "Checking for remote updates..."
git fetch origin master || { log "${RED}Git fetch failed!${NC}"; exit 1; }

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/master)
BASE=$(git merge-base HEAD origin/master)

if [ "$LOCAL" = "$REMOTE" ]; then
    log "${GREEN}No changes detected.${NC}"
else
    if [ "$LOCAL" = "$BASE" ]; then
        
        log "${YELLOW}Update detected! Pulling...${NC}"
        
        PULL_OUTPUT=$(git pull --no-edit origin master)
        log "$PULL_OUTPUT"

       
        if echo "$PULL_OUTPUT" | grep -q "Already up to date."; then
            log "${GREEN}No new changes after pull.${NC}"
        else
            log "Installing/updating dependencies..."
            pip3 install --upgrade pip
            pip3 install -r requirements.txt

            log "Restarting screen sessions after update..."
            screen -S "$SESSION_1" -X quit || true
            sleep 1
            screen -dmS "$SESSION_1" $PYTHON_SCRIPT_1

            screen -S "$SESSION_2" -X quit || true
            sleep 1
            screen -dmS "$SESSION_2" $PYTHON_SCRIPT_2

            log "${GREEN}✅ Updated and restarted.${NC}"
        fi
    elif [ "$REMOTE" = "$BASE" ]; then
        
        log "${GREEN}Local repository is ahead of remote. No pull needed.${NC}"
    else
        
        log "${RED}Local and remote branches have diverged! Manual intervention required.${NC}"
        exit 1
    fi
fi

restart_screen() {
    local name="$1"
    local cmd="$2"

    if screen -list | grep -q "$name"; then
        PID=$(pgrep -f "SCREEN.*$name.*python3")
        if [ -n "$PID" ]; then
            log "${GREEN}✅ $name is running (PID $PID)${NC}"
        else
            log "${YELLOW}⚠️ '$name' screen exists but python3 not running — restarting...${NC}"
            screen -S "$name" -X quit || true
            sleep 1
            screen -dmS "$name" $cmd
            log "${GREEN}🔁 $name restarted.${NC}"
        fi
    else
        log "${RED}🟥 '$name' screen not found — starting...${NC}"
        screen -dmS "$name" $cmd
        log "${GREEN}✅ $name started.${NC}"
    fi
}


restart_screen "$SESSION_1" "$PYTHON_SCRIPT_1"
restart_screen "$SESSION_2" "$PYTHON_SCRIPT_2"
