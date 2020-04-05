# Helix IoT MQTT

## About

Helix IoT MQTT is a modular component that allows MQTT protocol-based IoT devices to transmit data to Helix Sandbox. The
UltraLight 2.0 IoT Agent is configured to communicate with a set of cell phone IoT devices from [IoT MQTT Panel](https://play.google.com/store/apps/details?id=snr.lab.iotmqttpanel.prod&hl=pt_BR) using [Eclipse Mosquitto™](https://mosquitto.org/) an open source MQTT message broker. This module can be installed on the edge on a [Raspberry Pi](https://github.com/telefonicaid/fiware-orion/blob/master/docker/raspberry_pi.md).

## Checking the IoT Agent Health

You can check if the IoT Agent is running by making an HTTP request to the exposed port:

#### :one: Request:

```console
curl -X GET \
  'http://<HELIX_IOT_IP>:4041/iot/about'
```

The response will look similar to the following:

```json
{
    "libVersion": "2.6.0-next",
    "port": "4041",
    "baseRoot": "/",
    "version": "1.6.0-next"
}
```


## Connecting IoT Devices

The IoT Agent acts as a middleware between the IoT devices and the context broker. It therefore needs to be able to
create context data entities with unique IDs. Once a service has been provisioned and an unknown device makes a
measurement the IoT Agent add this to the context using the supplied `<device-id>` (unless the device is recognized and
can be mapped to a known ID.

There is no guarantee that every supplied IoT device `<device-id>` will always be unique, therefore all provisioning
requests to the IoT Agent require two mandatory headers:

-   `fiware-service` header is defined so that entities for a given service can be held in a separate mongoDB database.
-   `fiware-servicepath` can be used to differentiate between arrays of devices.

For example within a smart city application you would expect different `fiware-service` headers for different
departments (e.g. parks, transport, refuse collection etc.) and each `fiware-servicepath` would refer to specific park
and so on. This would mean that data and devices for each service can be identified and separated as needed, but the
data would not be siloed - for example data from a **Smart Bin** within a park can be combined with the **GPS Unit** of
a refuse truck to alter the route of the truck in an efficient manner.

The **Smart Bin** and **GPS Unit** are likely to come from different manufacturers and it cannot be guaranteed that
there is no overlap within `<device-id>`s used. The use of the `fiware-service` and `fiware-servicepath` headers can
ensure that this is always the case, and allows the context broker to identify the original source of the context data.

### Provisioning a Service Group for MQTT

Invoking group provision is always the first step in connecting devices. For MQTT communication, provisioning supplies
the authentication key so the IoT Agent will know which **topic** it must subscribe to.

It is possible to set up default commands and attributes for all devices as well, but this is not done within this
tutorial as we will be provisioning each device separately.

This example provisions an anonymous group of devices. It tells the IoT Agent that a series of devices will be
communicating by sending messages to the `/iot` **topic**

The `resource` attribute is left blank since HTTP communication is not being used. The URL location of `cbroker` is an
optional attribute - if it is not provided, the IoT Agent uses the default context broker URL as defined in the
configuration file, however it has been added here for completeness.

#### :two: Request:

```console
curl -iX POST \
  'http://<HELIX_IOT_IP>:4041/iot/services' \
  -H 'Content-Type: application/json' \
  -H 'fiware-service: helixiot' \
  -H 'fiware-servicepath: /' \
  -d '{
 "services": [
   {
     "apikey":      "iot",
     "cbroker":     "http://<HELIX_SANDBOX_IP>:1026",
     "entity_type": "Thing",
     "resource":    ""
   }
 ]
}'
```

### Provisioning a Sensor

It is common good practice to use URNs following the NGSI-LD
[specification](https://www.etsi.org/deliver/etsi_gs/CIM/001_099/009/01.01.01_60/gs_CIM009v010101p.pdf) when creating
entities. Furthermore it is easier to understand meaningful names when defining data attributes. These mappings can be
defined by provisioning a device individually.

Three types of measurement attributes can be provisioned:

-   `attributes` are active readings from the device
-   `lazy` attributes are only sent on request - The IoT Agent will inform the device to return the measurement
-   `static_attributes` are as the name suggests static data about the device (such as relationships) passed on to the
    context broker.

> **Note**: in the case where individual `id`s are not required, or aggregated data is sufficient the `attributes` can
> be defined within the provisioning service rather than individually.

#### :three: Request:

```console
curl -iX POST \
  'http://<HELIX_IOT_IP>:4041/iot/devices' \
  -H 'Content-Type: application/json' \
  -H 'fiware-service: helixiot' \
  -H 'fiware-servicepath: /' \
  -d '{
 "devices": [
   {
     "device_id":   "motion001",
     "entity_name": "urn:ngsi-ld:Motion:001",
     "entity_type": "Motion",
     "protocol":    "PDI-IoTA-UltraLight",
     "transport":   "MQTT",
     "timezone":    "America/Sao_Paulo",
     "attributes": [
       { "object_id": "c", "name": "count", "type": "Integer" }
     ]
   }
 ]
}
'
```

In the request we are associating the device `motion001` with the URN `urn:ngsi-ld:Motion:001` and mapping the device
reading `c` with the context attribute `count` (which is defined as an `Integer`). 

The addition of the `transport=MQTT` attribute in the body of the request is sufficient to tell the IoT Agent that it
should subscribe to the `/<api-key>/<device-id>` **topic** to receive measurements.

You can simulate a dummy IoT device measurement coming from the **Motion Sensor** device `motion001`, by posting an MQTT
message to the following **topic**

You can see that a measurement has been recorded, by retrieving the entity data from the context broker. Don't forget to
add the `fiware-service` and `fiware-service-path` headers.

#### :four: Request:

```console
curl -X GET \
  'http://<HELIX_SANDBOX_IP>:1026/v2/entities/urn:ngsi-ld:Motion:001?type=Motion' \
  -H 'fiware-service: helixiot' \
  -H 'fiware-servicepath: /'
```

#### Response:

```json
{
    "id": "urn:ngsi-ld:Motion:001",
    "type": "Motion",
    "TimeInstant": {
        "type": "DateTime",
        "value": "2019-06-26T15:15:27.00Z",
        "metadata": {}
    },
    "count": {
        "type": "Integer",
        "value": " ",
        "metadata": {}
    }
}
```

The response shows that the **Motion Sensor** device with `id=motion001` has been successfully identified by the IoT
Agent and mapped to the entity `id=urn:ngsi-ld:Motion:001`. This new entity has been created within the context data.
The `c` attribute from the dummy device measurement request has been mapped to the more meaningful `count` attribute
within the context. As you will notice, a `TimeInstant` attribute has been added to both the entity and the metadata of
the attribute - this represents the last time the entity and attribute have been updated, and is automatically added to
each new entity because the `IOTA_TIMESTAMP` environment variable was set when the IoT Agent was started up.

### Provisioning an Actuator

Provisioning an actuator is similar to provisioning a sensor. The `transport=MQTT` attribute defines the communications
protocol to be used. For MQTT communications, the `endpoint` attribute is not required as there is no HTTP URL where the
device is listening for commands. The array of commands is mapped to directly to messages sent to the
`/<api-key>/<device-id>/cmd` **topic** The `commands` array includes a list of each command that can be invoked.

The example below provisions a bell with the `deviceId=bell001`.

#### :five: Request:

```console
curl -iX POST \
  'http://<HELIX_IOT_IP>:4041/iot/devices' \
  -H 'Content-Type: application/json' \
  -H 'fiware-service: helixiot' \
  -H 'fiware-servicepath: /' \
  -d '{
  "devices": [
    {
      "device_id": "bell001",
      "entity_name": "urn:ngsi-ld:Bell:001",
      "entity_type": "Bell",
      "protocol": "PDI-IoTA-UltraLight",
      "transport": "MQTT",
      "commands": [
        { "name": "ring", "type": "command" }
       ]
    }
  ]
}
'
```

Before we wire-up the context broker, we can test that a command can be sent from the IoT Agent to a device by making a
REST request directly to the IoT Agent's North Port using the `/v1/updateContext` endpoint. It is this endpoint that
will eventually be invoked by the context broker once we have connected it up. To test the configuration you can run the
command directly as shown:

#### :six: Request:

```console
curl -iX POST \
  'http://<HELIX_IOT_IP>:4041/v1/updateContext' \
  -H 'Content-Type: application/json' \
  -H 'fiware-service: helixiot' \
  -H 'fiware-servicepath: /' \
  -d '{
    "contextElements": [
        {
            "type": "Bell",
            "isPattern": "false",
            "id": "urn:ngsi-ld:Bell:001",
            "attributes": [
                { "name": "ring", "type": "command", "value": "" }
            ]
        }
    ],
    "updateAction": "UPDATE"
}'
```

#### Response:

```json
{
    "contextResponses": [
        {
            "contextElement": {
                "attributes": [
                    {
                        "name": "ring",
                        "type": "command",
                        "value": ""
                    }
                ],
                "id": "urn:ngsi-ld:Bell:001",
                "isPattern": false,
                "type": "Bell"
            },
            "statusCode": {
                "code": 200,
                "reasonPhrase": "OK"
            }
        }
    ]
}
```

The result of the command to ring the bell can be read by querying the entity within the Orion Context Broker.

#### :seven: Request:

```console
curl -X GET \
  'http://<HELIX_SANDBOX_IP>:1026/v2/entities/urn:ngsi-ld:Bell:001?type=Bell&options=keyValues' \
  -H 'fiware-service: helixiot' \
  -H 'fiware-servicepath: /'
```

#### Response:

```json
{
    "id": "urn:ngsi-ld:Bell:001",
    "type": "Bell",
    "TimeInstant": {
        "type": "DateTime",
        "value": "2019-06-26T15:29:52.00Z",
        "metadata": {}
    },
    "ring_info": {
        "type": "commandResult",
        "value": " ",
        "metadata": {}
    },
    "ring_status": {
        "type": "commandStatus",
        "value": "PENDING",
        "metadata": {
            "TimeInstant": {
                "type": "DateTime",
                "value": "2019-06-26T15:29:52.00Z"
            }
        }
    },
    "ring": {
        "type": "command",
        "value": "",
        "metadata": {}
    }
}
```

The `TimeInstant` shows last the time any command associated with the entity has been invoked. The result of `ring`
command can be seen in the value of the `ring_info` attribute.

### Provisioning a Smart Door

Provisioning a device which offers both commands and measurements is merely a matter of making an HTTP POST request with
both `attributes` and `command` attributes in the body of the request. Once again the `transport=MQTT` attribute defines
the communications protocol to be used, and no `endpoint` attribute is required as there is no HTTP URL where the device
is listening for commands.

#### :eight: Request:

```console
curl -iX POST \
  'http://<HELIX_IOT_IP>:4041/iot/devices' \
  -H 'Content-Type: application/json' \
  -H 'fiware-service: helixiot' \
  -H 'fiware-servicepath: /' \
  -d '{
  "devices": [
    {
      "device_id": "door001",
      "entity_name": "urn:ngsi-ld:Door:001",
      "entity_type": "Door",
      "protocol": "PDI-IoTA-UltraLight",
      "transport": "MQTT",
      "commands": [
        {"name": "unlock","type": "command"},
        {"name": "open","type": "command"},
        {"name": "close","type": "command"},
        {"name": "lock","type": "command"}
       ],
       "attributes": [
        {"object_id": "s", "name": "state", "type":"Text"}
       ]
    }
  ]
}
'
```

### Provisioning a Smart Lamp

Similarly, a **Smart Lamp** with two commands (`on` and `off`) and two attributes can be provisioned as follows:

#### :nine: Request:

```console
curl -iX POST \
  'http://<HELIX_IOT_IP>:4041/iot/devices' \
  -H 'Content-Type: application/json' \
  -H 'fiware-service: helixiot' \
  -H 'fiware-servicepath: /' \
  -d '{
  "devices": [
    {
      "device_id": "lamp001",
      "entity_name": "urn:ngsi-ld:Lamp:001",
      "entity_type": "Lamp",
      "protocol": "PDI-IoTA-UltraLight",
      "transport": "MQTT",
      "commands": [
        {"name": "on","type": "command"},
        {"name": "off","type": "command"}
       ],
       "attributes": [
        {"object_id": "s", "name": "state", "type":"Text"},
        {"object_id": "l", "name": "luminosity", "type":"Integer"}
       ]
    }
  ]
}
'
```

The full list of provisioned devices can be obtained by making a GET request to the `/iot/devices` endpoint.

#### :one::zero: Request:

```console
curl -X GET \
  'http://<HELIX_IOT_IP>:4041/iot/devices' \
  -H 'fiware-service: helixiot' \
  -H 'fiware-servicepath: /'
```

## Enabling Context Broker Commands

Having connected up the IoT Agent to the IoT devices, we now need to inform the Orion Context Broker that the commands
are available. In other words we need to register the IoT Agent as a
[Context Provider](https://github.com/FIWARE/tutorials.Context-Providers/) for the command attributes.

Once the commands have been registered it will be possible to ring the **Bell**, open and close the **Smart Door** and
switch the **Smart Lamp** on and off by sending requests to the Orion Context Broker, rather than sending UltraLight 2.0
requests directly the IoT devices as we did in the [previous tutorial](https://github.com/FIWARE/tutorials.IoT-Sensors)

All the communications leaving and arriving at the North port of the IoT Agent use the standard NGSI syntax. The
transport protocol used between the IoT devices and the IoT Agent is irrelevant to this layer of communication.
Effectively the IoT Agent is offering a simplified facade pattern of well-known endpoints to actuate any device.

Therefore this section of registering and invoking commands **duplicates** the instructions found in the
[previous tutorial](https://github.com/FIWARE/tutorials.IoT-Agent)

### Registering a Bell Command

The **Bell** entity has been mapped to `id="urn:ngsi-ld:Bell:001"` with an entity `type="Bell"`. To register the command
we need to inform Orion that the URL `http://<HELIX_SANDBOX_IP>:1026/v1` is able to provide the missing `ring` attribute. This will
then be forwarded on to the IoT Agent. As you see this is an NGSI v1 endpoint and therefore the `legacyForwarding`
attribute must also be set.

#### :one::one: Request:

```console
curl -iX POST \
  'http://<HELIX_SANDBOX_IP>:1026/v2/registrations' \
  -H 'Content-Type: application/json' \
  -H 'fiware-service: helixiot' \
  -H 'fiware-servicepath: /' \
  -d '{
  "description": "Bell Commands",
  "dataProvided": {
    "entities": [
      {
        "id": "urn:ngsi-ld:Bell:001", "type": "Bell"
      }
    ],
    "attrs": ["ring"]
  },
  "provider": {
    "http": {"url": "http://<HELIX_IOT_IP>:4041"},
    "legacyForwarding": true
  }
}'
```

### Ringing the Bell

To invoke the `ring` command, the `ring` attribute must be updated in the context.

#### :one::two: Request:

```console
curl -iX PATCH \
  'http://<HELIX_SANDBOX_IP>:1026/v2/entities/urn:ngsi-ld:Bell:001/attrs' \
  -H 'Content-Type: application/json' \
  -H 'fiware-service: helixiot' \
  -H 'fiware-servicepath: /' \
  -d '{
  "ring": {
      "type" : "command",
      "value" : ""
  }
}'
```

If you are viewing the device monitor page, you can also see the state of the bell change.


### Registering Smart Door Commands

The **Smart Door** entity has been mapped to `id="urn:ngsi-ld:Door:001"` with an entity `type="Door"`. To register the
commands we need to inform Orion that the URL `http://orion:1026/v1` is able to provide the missing attributes. This
will then be forwarded on to the IoT Agent. As you see this is an NGSI v1 endpoint and therefore the `legacyForwarding`
attribute must also be set.

#### :one::three: Request:

```console
curl -iX POST \
  'http://<HELIX_SANDBOX_IP>:1026/v2/registrations' \
  -H 'Content-Type: application/json' \
  -H 'fiware-service: helixiot' \
  -H 'fiware-servicepath: /' \
  -d '{
  "description": "Door Commands",
  "dataProvided": {
    "entities": [
      {
        "id": "urn:ngsi-ld:Door:001", "type": "Door"
      }
    ],
    "attrs": [ "lock", "unlock", "open", "close"]
  },
  "provider": {
    "http": {"url": "http://<HELIX_IOT_IP>:4041"},
    "legacyForwarding": true
  }
}'
```

### Opening the Smart Door

To invoke the `open` command, the `open` attribute must be updated in the context.

#### :one::four: Request:

```console
curl -iX PATCH \
  'http://<HELIX_SANDBOX_IP>:1026/v2/entities/urn:ngsi-ld:Lamp:001/attrs' \
  -H 'Content-Type: application/json' \
  -H 'fiware-service: helixiot' \
  -H 'fiware-servicepath: /' \
  -d '{
  "open": {
      "type" : "command",
      "value" : ""
  }
}'
```

### Registering Smart Lamp Commands

The **Smart Lamp** entity has been mapped to `id="urn:ngsi-ld:Lamp:001"` with an entity `type="Lamp"`. To register the
commands we need to inform Orion that the URL `http://orion:1026/v1` is able to provide the missing attributes. This
will then be forwarded on to the IoT Agent. As you see this is an NGSI v1 endpoint and therefore the `legacyForwarding`
attribute must also be set.

#### :one::five: Request:

```console
curl -iX POST \
  'http://<HELIX_SANDBOX_IP>:1026/v2/registrations' \
  -H 'Content-Type: application/json' \
  -H 'fiware-service: helixiot' \
  -H 'fiware-servicepath: /' \
  -d '{
  "description": "Lamp Commands",
  "dataProvided": {
    "entities": [
      {
        "id": "urn:ngsi-ld:Lamp:001","type": "Lamp"
      }
    ],
    "attrs": [ "on", "off" ]
  },
  "provider": {
    "http": {"url": "http://<HELIX_IOT_IP>:4041"},
    "legacyForwarding": true
  }
}'
```

### Switching on the Smart Lamp

To switch on the **Smart Lamp**, the `on` attribute must be updated in the context.

#### :one::six: Request:

```console
curl -iX PATCH \
  'http://<HELIX_SANBOX_IP>:1026/v2/entities/urn:ngsi-ld:Lamp:001/attrs' \
  -H 'Content-Type: application/json' \
  -H 'fiware-service: helixiot' \
  -H 'fiware-servicepath: /' \
  -d '{
  "on": {
      "type" : "command",
      "value" : ""
  }
}'
```

## Reference

This tutorial is adapted from [Fiware Foundation](https://github.com/FIWARE/tutorials.IoT-over-MQTT)


#### © Helix Platform 2020, All rights reserved.
