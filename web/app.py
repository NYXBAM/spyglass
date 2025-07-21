from flask import Flask, render_template
from datetime import datetime, timedelta
from logger.logger import get_logs, init_db, get_uptime_data, get_latest_statuses
from flask import jsonify, request


app = Flask(__name__)

@app.route("/")
def index():
    logs = get_latest_statuses()
    return render_template("status.html", logs=logs)

@app.route("/uptime")
def uptime_page():
    return render_template("uptimes.html")

@app.route("/uptime-data")
def uptime_data():
    logs = get_uptime_data()
    return jsonify(logs)

@app.route('/api/logs')
def api_logs():
    limit = int(request.args.get('limit', 3))
    logs = get_logs(limit)
    result = []
    for ts, target, status, message in logs:
        result.append({
            "timestamp": ts,
            "target": target,
            "status": status,
            "message": message
        })
    return jsonify(result)

if __name__ == "__main__":
    init_db()
    app.run(host="0.0.0.0", port=5555, debug=True)
