import sqlite3
from pathlib import Path
from datetime import datetime, timedelta
from flask import jsonify 

DB_FILE = "/home/python-scripts/spyglass/logs.db"

def init_db():
    Path("logger").mkdir(exist_ok=True)
    conn = sqlite3.connect(DB_FILE)
    cursor = conn.cursor()
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT NOT NULL,
        target TEXT NOT NULL,
        status TEXT NOT NULL,      -- "up" / "down"
        message TEXT
    )
    """)
    conn.commit()
    conn.close()


def log_event(target: str, status: str, message: str = ""):
    timestamp = datetime.now().isoformat()
    conn = sqlite3.connect(DB_FILE)
    cursor = conn.cursor()
    cursor.execute("""
    INSERT INTO logs (timestamp, target, status, message)
    VALUES (?, ?, ?, ?)
    """, (timestamp, target, status, message))
    conn.commit()
    conn.close()

def get_latest_statuses():
    conn = sqlite3.connect(DB_FILE)
    cursor = conn.cursor()
    cursor.execute("""
    SELECT l.timestamp, l.target, l.status, l.message
    FROM logs l
    INNER JOIN (
        SELECT target, MAX(timestamp) as max_ts
        FROM logs
        GROUP BY target
    ) grouped ON l.target = grouped.target AND l.timestamp = grouped.max_ts
    ORDER BY l.target
    """)
    rows = cursor.fetchall()
    conn.close()
    return rows


def get_logs(limit=100):
    conn = sqlite3.connect(DB_FILE)
    cursor = conn.cursor()
    cursor.execute("""
    SELECT timestamp, target, status, message
    FROM logs
    ORDER BY timestamp DESC
    LIMIT ?
    """, (limit,))
    rows = cursor.fetchall()
    conn.close()
    return rows

def get_uptime_data(hours=24):
    conn = sqlite3.connect("logs.db")
    cur = conn.cursor()
    
    time_from = (datetime.utcnow() - timedelta(hours=hours)).isoformat() + "Z"  
    cur.execute("SELECT timestamp, target, status FROM logs WHERE timestamp > ?", (time_from,))
    data = cur.fetchall()
    conn.close()
    
    result = []
    for ts, target, status in data:
        result.append({
            "timestamp": ts + "Z",  
            "target": target,
            "status": status
        })
    return result