import requests

response = requests.post('https://stbureau.ru/uuid')

json = response.json()
print(json['uuid'])
