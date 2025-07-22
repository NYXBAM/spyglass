import subprocess

def check_ping(host):
    result = subprocess.run(["ping", "-c", "3", host], stdout=subprocess.DEVNULL)
    return result.returncode == 0
