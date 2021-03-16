-- local pollnet = require("pollnet")
-- local json = require("json")
local buttplug = require("buttplug")

local client_name = "Anomaly Demo"

-- get system Sleep function
local ffi = require("ffi")

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

-- "Simulated" game loop
function main_loop()
    -- check sock health in connect
    local sock = buttplug.connect("ws://127.0.0.1:12345")

    -- abstract this into an init or something
    buttplug.request_server_info(client_name)

    -- Each "tick" of your script
    while true do
        buttplug.get_and_handle_message()

        if not buttplug.has_devices then
            buttplug.get_devices()
        end

        -- Game doing other things, including running the thing
        buttplug.send_vibrate_cmd(0, {0.2, 0.2})
        sleep(500)
    end
end

main_loop()

sleep(1000)
print('exited')
