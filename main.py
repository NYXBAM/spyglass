import time
from monitor.ping import check_ping
from monitor.http import check_http
from notifier.telegram import send_telegram_alert
import yaml
import os
from dotenv import load_dotenv
from logger.logger import init_db, log_event
from logger.webhook import send_webhook

load_dotenv()
init_db()

with open("config.yaml") as f:
    config = yaml.safe_load(f)



def run_check(target):
    if target["type"] == "ping":
        return check_ping(target["host"])
    elif target["type"] == "http":
        return check_http(target["url"])
    return False

last_status = {}
# TEST PROD CI/CD 
while True:
    for t in config["targets"]:
        name = t["name"]
        current_ok = run_check(t)
        log_event(name, "up" if current_ok else "down", "Status")
        last_ok = last_status.get(name, None)
        if last_ok is None or last_ok != current_ok:
            if not current_ok:
                print(f"❗ {name} FAILED!")
                
                
                if config["telegram_alerts"]:
                    send_telegram_alert(f"❗ {name} DOWN!")
                if config["webhooks_alerts"]:
                    send_webhook(t, "down")
            
            else:
                print(f"✅ {name} is back online!")
                
                if config["telegram_alerts"]:
                    send_telegram_alert(f"✅ {name} is back online!")
        
                if config["webhooks_alerts"]:
                    send_webhook(t, "up")
            last_status[name] = current_ok
    time.sleep(config["check_interval"])

