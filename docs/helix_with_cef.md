## CEF Context Broker Tutorial for Helix Sandbox

Click <a href="https://github.com/Helix-Platform/Sandbox-NG/blob/master/postman/helix_postman_collection.json">here</a> to access the Postman collection! 

## About

This tutorial can help you to understand the most popular REST methods used on CEF Context Broker:

#### :one: Get Version:

```console
curl --location --request GET 'http://{{url}}:1026/version'
```

The response will look similar to the following:

```json
{
  "orion": {
    "version": "2.4.0-next",
    "uptime": "0 d, 0 h, 1 m, 34 s",
    "git_hash": "4f26834ca928e468b091729d93dabd22108a2690",
    "compile_time": "Tue Mar 31 16:21:23 UTC 2020",
    "compiled_by": "root",
    "compiled_in": "3369cff2fa4c",
    "release_date": "Tue Mar 31 16:21:23 UTC 2020",
    "doc": "https://fiware-orion.rtfd.io/"
  }
}
```

### Provisioning a entitie (temperature and humidity sensor) 

It is common good practice to use URNs following the NGSI-LD
[specification](https://www.etsi.org/deliver/etsi_gs/CIM/001_099/009/01.01.01_60/gs_CIM009v010101p.pdf) when creating
entities. Furthermore it is easier to understand meaningful names when defining data attributes. These mappings can be
defined by provisioning a device individually.

#### :two: Creating an entitie:

```console
curl --location --request POST 'http://{{url}}:1026/v2/entities' \
--header 'Content-Type: application/json' \
--header 'fiware-service: helixiot' \
--header 'fiware-servicepath: /' \
--data-raw '{
  "id": "urn:ngsi-ld:entity:001",
  "type": "iot",
  "temperature": {
  "type": "float",
  "value": 0
    }
,
  "humidity": {
  "type": "float",
  "value": 0
	}
}
'
```

The response will look similar to the following:

```status 201
201 - Created
```

#### :three: Viewing information:

```console
curl --location --request GET 'http://{{url}}:1026/v2/entities' \
--header 'Accept: application/json' \
--header 'fiware-service: helixiot' \
--header 'fiware-servicepath: /'
```

The response will look similar to the following:

```json
[
    {
        "id": "urn:ngsi-ld:entity:001",
        "type": "iot",
        "humidity": {
            "type": "float",
            "value": 0,
            "metadata": {}
        },
        "temperature": {
            "type": "float",
            "value": 0,
            "metadata": {}
        }
    }
]
```

#### :four: Updating attributes:

```console
curl --location --request POST 'http://{{url}}:1026/v2/entities/urn:ngsi-ld:entity:001/attrs' \
--header 'Content-Type: application/json' \
--header 'fiware-service: helixiot' \
--header 'fiware-servicepath: /' \
--data-raw '{
  "temperature": {
  "type": "float",
  "value": 88
    }
,
  "humidity": {
  "type": "float",
  "value": 20
	}
}
'
```

The response will look similar to the following:

```status 204
204 - No Content
```

#### :five: Updating attributes selectively (attribute = temperature):

```console
curl --location --request PUT 'http://{{url}}:1026/v2/entities/urn:ngsi-ld:entity:001/attrs/temperature/value' \
--header 'fiware-service: helixiot' \
--header 'fiware-servicepath: /' \
--header 'Content-Type: text/plain' \
--data-raw '95'
```

The response will look similar to the following:

```status 204
204 - No Content
```

#### :six: Updating attributes selectively (attribute = humidity):

```console
curl --location --request PUT 'http://{{url}}:1026/v2/entities/urn:ngsi-ld:entity:001/attrs/humidity/value' \
--header 'fiware-service: helixiot' \
--header 'fiware-servicepath: /' \
--header 'Content-Type: text/plain' \
--data-raw '95'
```

The response will look similar to the following:

```status 204
204 - No Content
```

#### :seven: Deleting the entitie:

```console
curl --location --request DELETE 'http://{{url}}:1026/v2/entities/urn:ngsi-ld:entity:001' \
--header 'fiware-service: helixiot' \
--header 'fiware-servicepath: /'
```

The response will look similar to the following:

```status 204
204 - No Content
```

## Reference

This tutorial was adapted from the [Fiware Foundation](https://fiware-orion.readthedocs.io/en/master/)


#### © Helix Platform 2021, All rights reserved.
