--- config
lasttemp=-999
-- GPIO2
pin = 4                             
contentLength = 0   
-- user:password (pimatic) in BASE64; ex. "dXNlcjpwYXNzd29yZA=="
base64login = "base64string"   
-- pimatic server IP
pimaticServer = "192.168.0.123"  
pimaticPort = "80"  
-- Pimatic variable which should be updated
variableName = "outside-wifi-temp"
-- send data every X seconds
interval = 300

--- Get temperature from DS18B20 
function getTemp()
    t = require("ds18b20")
    t.setup(pin)
    addrs = t.addrs()
    if (addrs ~= nil) then
      print("Total DS18B20 sensors: "..table.getn(addrs))
    end

    -- read temperature and set variable
    print("Temperature: "..t.read().."°C")
    lasttemp = t.read()
    
    -- Don't forget to release it after use
    t = nil
    ds18b20 = nil
    package.loaded["ds18b20"]=nil
end    
--- calc content-length
function calcLength(type)
    print(type)
    contentLength = string.len(type) + 40
    print("Content-Length: "..contentLength)
    
end

--- send data
function sendData(type, name)
    calcLength(type)
    print("Sending data ...")
    conn=net.createConnection(net.TCP, 0) 
    conn:on("receive", function(conn, payload) print(payload) end)
    conn:connect(pimaticPort,pimaticServer)
    conn:send("PATCH /api/variables/"..name.." HTTP/1.1\r\n")
    conn:send("Authorization: Basic "..base64login.."\r\n")
    conn:send("Host: "..pimaticServer.."\r\n")
    conn:send("Content-Type:application/json\r\n")
    conn:send("Content-Length: "..contentLength.."\r\n\r\n")
    conn:send("\{\"type\"\: \"value\"\, \"valueOrExpression\"\: "..type.."\}")
    ---
    conn:on("sent",function(conn)
        print("Closing connection")
        conn:close()
    end)
    conn:on("disconnection", function(conn)
        print("Got disconnection...")
    end)
    ---
    
end

--- main loop 
tmr.alarm(0, (interval*1000), 1, function() 
    getTemp()
    -- filter false values (sometimes higher than 85 etc..
    if (lasttemp <= 40 and lasttemp >= -40) then
      sendData(lasttemp, variableName)
    end
    
end )

