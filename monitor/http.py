import requests

# HTTP CHECK SERVICES 

def check_http(url):
    try:
        response = requests.get(url, timeout=5)
        return response.status_code == 200
    except requests.RequestException:
        return False