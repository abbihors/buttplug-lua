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

-- Ask for the device list after we connect
table.insert(buttplug.cb.ServerInfo, function()
    buttplug.request_device_list()
end)

-- Start scanning if the device list was empty
table.insert(buttplug.cb.DeviceList, function()
    if buttplug.count_devices() == 0 then
        buttplug.start_scanning()
    end
end)

-- Stop scanning after the first device is found
table.insert(buttplug.cb.DeviceAdded, function()
    buttplug.stop_scanning()
end)

-- Start scanning if we lose a device
table.insert(buttplug.cb.DeviceRemoved, function()
    buttplug.start_scanning()
end)

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

        -- Game doing other things, including running the thing
        if buttplug.count_devices() > 0 then
            buttplug.send_vibrate_cmd(0, { 0.2 })
            sleep(500)
            buttplug.send_vibrate_cmd(0, { 0 })
            os.exit()
        end
        
        sleep(500)
    end
end

main_loop()
