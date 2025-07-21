import subprocess

def check_ping(host):
    result = subprocess.run(["ping", "-c", "1", host], stdout=subprocess.DEVNULL)
    return result.returncode == 0
