local pollnet = require("pollnet")
local ffi = require("ffi")
local json = require("json")


-- get system Sleep function
ffi.cdef[[
void Sleep(int ms);
]]

local sleep
if ffi.os == "Windows" then
  function sleep(s)
    ffi.C.Sleep(s)
  end
else
  function sleep(s)
    ffi.C.poll(nil, 0, s)
  end
end


local url = "ws://127.0.0.1:12345"
local sock = pollnet.open_ws(url)

local messages = {}

-- local status_msg = "[{\"RequestServerInfo\":{\"Id\":1,\"ClientName\":\"STALKER\",\"MessageVersion\":1}}]"
messages.RequestServerInfo = [[
[
  {
    "RequestServerInfo": {
      "Id": 1,
      "ClientName": "Anomaly",
      "MessageVersion": 1
    }
  }
]
]]

messages.StartScanning = [[
[
  {
    "StartScanning": {
      "Id": 1
    }
  }
]
]]

messages.StopScanning = [[
[
  {
    "StopScanning": {
      "Id": 1
    }
  }
]
]]

messages.TestVibrate = [[
[
  {
    "VibrateCmd": {
      "Id": 1,
      "DeviceIndex": 0,
      "Speeds": [
        {
          "Index": 0,
          "Speed": 0.2
        },
        {
          "Index": 1,
          "Speed": 0.2
        }
      ]
    }
  }
]
]]

messages.VibrateCmd = {
    VibrateCmd = {
        Id = 1,
        DeviceIndex = 0,
        Speeds = {}
    }
}

-- print(status_msg)
local req_devices = "[    {      \"StartScanning\": {        \"Id\": 2      }    }  ]"


function wait_for_reply(expected_message)
    while sock:poll() do
        local message = sock:last_message()

        if message then
            local contents = json.decode(message)

            if next(contents[1]) == expected_message then
                print(message)
                break
            end
        else
            sleep(200)
        end
    end
end

function send_vibrate_cmd()
    local msg = messages.VibrateCmd

    msg["VibrateCmd"]["Speeds"] = {
        {
            Index = 0,
            Speed = 0.2
        },
        {
            Index = 1,
            Speed = 0.2
        }
    }

    local payload = "[" .. json.encode(msg) .. "]"

    print(payload)
    sock:send(payload)

    wait_for_reply("Ok")
end

-- Register with the server
sock:send(messages.RequestServerInfo)
wait_for_reply("ServerInfo")

-- Start scanning for devices
sock:send(messages.StartScanning)
wait_for_reply("Ok")

-- TODO: Check for existing devices?

-- Grab the first device
wait_for_reply("DeviceAdded")

-- Stop scanning
sock:send(messages.StopScanning)
wait_for_reply("Ok")

-- Send test vibration
-- sock:send(messages.TestVibrate)
-- wait_for_reply("Ok")

-- send_vibrate_cmd()
send_vibrate_cmd({0.2, 0.2})

sleep(2000)

local i = 0
local connected = false

-- "main" loop, handles talking to server
-- while sock:poll() do
-- local msg = sock:last_message()
-- if msg then
--     sock:send(req_devices)
    
--     local msg_contents = json.decode(msg)
--     -- print(msg)
--     -- print(msg_contents[1] == "ServerInfo")

--     -- print(msg_contents[1].ServerInfo.ServerNamel)

--     local message = next(reply[1])
--     if (message == "ServerInfo") then
--         connected = true
--     end


--     i = i + 1
--     if (i > 4) then
--         os.exit()
--     end
-- else
--     sleep(1000)
-- end
-- end

-- print("Socket closed: ", sock:last_message())
