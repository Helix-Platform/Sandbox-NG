## Management Context Information in Python
### Requirements

Create and start a Context Broker through the Helix Sandbox Dashboard

### NGSI-LD Standard

Data model recommend that use the ngsi-ld standards to create an entity, for example:

If you have two iot devices, you can describe them as follows:

IoT device 1

    type: "iot_device"

    id: "urn:ngsi-ld:iot:001"

IoT device 2

    type: "iot_device"

    id: "urn:ngsi-ld:iot:002"
    
IoT device n

    type: "iot_device"

    id: "urn:ngsi-ld:iot:00n"

### Creating a context entity
```
import json
import requests
url = 'http://<helix_ip>:1026/v2/entities'
head = {"Content-Type": "application/json"}
d= '{ "id": "urn:ngsi-ld:iot:001", "type" : "iot_device", "level" : { "value" : "0", "type" : "integer" }}'
response = requests.post(url, data = d, headers = head)
print (response)
```
### Sending data to context entity
```
import json
import requests
head = {"Content-Type": "application/json"}   
d = '{ "level" : { "value" : "0", "type" : "integer" } }'
url = 'http://<helix_ip>:1026/v2/entities/urn:ngsi-ld:iot:001/attrs'
response = requests.post(url, data=d, headers=head)
print (response)
```
### Receiving data from context entity
```
import json
import requests
url = 'http://<helix_ip>:1026/v2/entities/urn:ngsi-ld:iot:001/attrs/level'
response = requests.get(url)
data = response.json()
value = str(data['value'])
valued = int(value)
print (valued)
