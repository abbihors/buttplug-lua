local pollnet = require("pollnet")
local ffi = require("ffi")
-- local json = require("json")
local buttplug = require("buttplug")

local client_name = "Anomaly Demo"

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

-- local url = "ws://127.0.0.1:12345"
-- local sock = pollnet.open_ws(url)

local sock = buttplug.connect("ws://127.0.0.1:12345")

function wait_for_reply(expected_message)
    -- while sock:poll() do
    --     local message = sock:last_message()

    --     if message then
    --         local contents = json.decode(message)

    --         if next(contents[1]) == expected_message then
    --             print(message)
    --             break
    --         end
    --     else
    --         sleep(200)
    --     end
    -- end
    sleep(1000)
end

-- Register with the server
-- sock:send(messages.RequestServerInfo)
buttplug.request_server_info(client_name)
wait_for_reply("ServerInfo")

-- Start scanning for devices
buttplug.start_scanning()
wait_for_reply("Ok")

-- TODO: Check for existing devices?

-- Grab the first device
wait_for_reply("DeviceAdded")

-- Stop scanning
buttplug.stop_scanning()
wait_for_reply("Ok")

-- Send test vibration
-- sock:send(messages.TestVibrate)
-- wait_for_reply("Ok")

-- send_vibrate_cmd()
buttplug.send_vibrate_cmd(0, { 0.2, 0.2 })

sleep(2000)

-- local i = 0
-- local connected = false

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
