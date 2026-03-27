import requests

url = "https://api.github.com"

response = requests.get(url)

print(response.json())