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
    local sock = buttplug.connect("ws://127.0.0.1:12345")

    -- abstract this into an init or something
    buttplug.request_server_info(client_name)

    -- Each "tick" of your script
    while true do
        buttplug.get_and_handle_messages()

        -- maybe just do like, if no device, get device
        -- which makes sure we got server info etc.

        -- Don't do anything until we get server info
        if buttplug.got_server_info then
            -- If we don't have devices, let's get some
            if (not buttplug.has_device()) and (not buttplug.scanning) then
                print('no devices, gonna look for some')

                buttplug.scan_for_devices()
            end
        end

        -- Game doing other things, including running the thing
        buttplug.send_vibrate_cmd(0, {0.2, 0.2})
        sleep(500)
    end
end

main_loop()

sleep(1000)
print('exited')

-- wait_for_reply("Ok")

-- -- TODO: Check for existing devices?

-- -- Grab the first device
-- wait_for_reply("DeviceAdded")

-- -- Stop scanning
-- buttplug.stop_scanning()
-- wait_for_reply("Ok")

-- -- Send test vibration
-- -- sock:send(messages.TestVibrate)
-- -- wait_for_reply("Ok")

-- -- send_vibrate_cmd()
-- buttplug.send_vibrate_cmd(0, { 0.2, 0.2 })

-- sleep(2000)
-- buttplug.send_stop_all_devices_cmd()


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
