import requests
import yaml
from datetime import datetime


with open("config.yaml") as f:
    config = yaml.safe_load(f)


def send_webhook(target: dict, status: str):
    urls = config.get("webhooks", [])
    for webhook in urls:
        try:
            payload_template = webhook.get("payload", {})
            if not isinstance(payload_template, dict):
                print(f"[Webhook] Skipped: payload not dict in {webhook}")
                continue

            payload = {
                k: v.format(
                    name=target.get("name", ""),
                    host=target.get("host", ""),
                    type=target.get("type", ""),
                    status=status,
                    timestamp=datetime.utcnow().isoformat()
                )
                for k, v in payload_template.items()
            }

            print(f"[Webhook] Sending to {webhook['url']} with payload:")
            print(payload)

            response = requests.post(webhook["url"], json=payload, timeout=5)
            print(f"[Webhook] Status: {response.status_code}")

        except Exception as e:
            print(f"[Webhook] Error: {e}")
