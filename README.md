# esp8266-pimatic Weather Sensor
Send ds18b20 temperature data to pimatic server using an esp8266


Setup
---------------

ESP8266
- Add WiFi credentials to init.lua
- Add PIN, base64login, pimaticServer, pimaticPort, variableName to main.lua

Pimatic
- pimatic has to have one variable named accordingly to your setting in main.lua
- to show the data on the homescreen add a VariablesDevice in pimatic

```
    {
      "id": "esp01-outside-wifi-temp-device",
      "name": "Outside",
      "class": "VariablesDevice",
      "variables": [
        {
          "name": "outsideTemp",
          "expression": "$variableName",
          "type": "number",
          "unit": "°C"
        }
      ]
    }
```


ToDo: Integrate this into the esp8266 433mhz node (WIP) for pimatic
