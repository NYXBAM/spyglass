import yaml
import requests


def check_api(url, expected_key=None):
    try:
        response = requests.get(url, timeout=10)
        data = response.json()
        if expected_key is not None:
            return expected_key in data
        return response.status_code == 200
    except (requests.RequestException, ValueError):
        return False

def check_api_value(url, key, expected_value):
    try:
        response = requests.get(url, timeout=10)
        data = response.json()
        return data.get(key) == expected_value
    except (requests.RequestException, ValueError):
        return False


## Check if the API data is fresh (for my specific own use). 


def check_api_freshness(url, max_seconds):
    try:
        response = requests.get(url, timeout=10)
        data = response.json()
        return data.get("secondsSinceData", float('inf')) < max_seconds
    except (requests.RequestException, ValueError):
        return False

