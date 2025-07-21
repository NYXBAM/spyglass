# 🛰 Spyglass

Your lightweight Python-based monitoring tool with alerts via Telegram — perfect for self-hosted, plug-and-play uptime tracking.

![Python](https://img.shields.io/badge/python-3.7%2B-green)
![License](https://img.shields.io/badge/license-MIT-blue)
![Platform](https://img.shields.io/badge/platform-linux%20%7C%20raspberry--pi-lightgrey)
![Status](https://img.shields.io/badge/status-beta-orange)


---

## 🚀 Features

- ✅ **Ping & HTTP(s) Monitoring**  
  Monitor servers, devices, websites, or services with ease.
  
- 🔔 **Instant Telegram Alerts**  
  Get notified immediately if a service goes down or recovers.

- 🌐 **Web Dashboard (optional)**  
  Lightweight Flask dashboard to view real-time status and logs.

- 🪵 **SQLite & File Logging**  
  Track historical uptime and events locally.

- 🧩 **Plugin System**  
  Easily extend functionality with custom checkers or alerts.

- 🧠 **Simple Config**  
  Human-readable `.yaml` configuration.

---

## 🛠 Installation

   ```bash
   git clone https://github.com/NYXBAM/spyglass.git
   cd spyglass

   nano .env # put your telegram token and chat_id
   # TELEGRAM_BOT_TOKEN=YouToken
   # TELEGRAM_CHAT_ID=YouChatID

   nano config.yaml # see example

   chmod +x deploy.sh 
   nano deploy.sh # change u path 

   # start 
   ./deploy.sh

   ```

## Example Config

```yaml
check_interval: 60

telegram_alerts: true 

targets:
  - name: Google
    type: ping
    host: 8.8.8.8

  - name: Localhost
    type: http
    url: http://127.0.0.1


```

### 🧑‍💻 Contributing

Pull requests are welcome! Feel free to open issues for bugs, features or improvements.

### 📄 License

This project is licensed under the MIT License.
