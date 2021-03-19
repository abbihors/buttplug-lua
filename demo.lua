-- local pollnet = require("pollnet")
-- local json = require("json")
local buttplug = require("buttplug")

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

local scanning = false

-- Get a device from the Buttplug server
function get_device()
    -- Not connected yet
    if not buttplug.got_server_info then
        return
    end

    -- Try the device list first
    if not buttplug.got_device_list then
        buttplug.request_device_list()
    elseif not scanning then
        -- If device list was empty, start scanning
        buttplug.start_scanning()
        scanning = true
    end
end

-- "Simulated" game loop
function main_loop()
    buttplug.connect("example-app", "ws://127.0.0.1:12345")

    -- Each "tick" of your script
    while true do
        local err = buttplug.get_and_handle_message()
        if err ~= nil then
            print("error: couldn't connect to server")
            return
        end

        if scanning and buttplug.has_devices() then
            buttplug.stop_scanning()
            scanning = false
        elseif not buttplug.has_devices() then    
            get_device()
        end

        -- Game doing other things, including running the thing
        if buttplug.has_devices() then
            buttplug.send_vibrate_cmd(0, { 0.2 })
        end
        
        sleep(500)
    end
end

main_loop()

sleep(1000)
print('exited')
