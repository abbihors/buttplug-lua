-- buttplug.lua -- Lua client for buttplug.io
local json = require("json")
local pollnet = require("pollnet")

local buttplug = {}

--
-- Buttplug messages
--

local messages = {}

-- Status messages

messages.Ok = {
    Ok = {
        Id = 1
    }
}

messages.Error = {
    Error = {
        Id = 0,
        ErrorMessage = "",
        ErrorCode = 0
    }
}

-- Handshake messages

messages.RequestServerInfo = {
    RequestServerInfo = {
        Id = 1,
        ClientName = "",
        MessageVersion = 1
    }
}

messages.ServerInfo = {
    ServerInfo = {
        Id = 1,
        ServerName = "",
        MessageVersion = 1,
        MaxPingTime = 0
    }
}

-- Enumeration messages

messages.RequestDeviceList = {
    RequestDeviceList = {
        Id = 1
    }
}

messages.DeviceList = {
    DeviceList = {
        Id = 1,
        Devices = {}
    }
}

messages.StartScanning = {
    StartScanning = {
        Id = 1
    }
}

messages.StopScanning = {
    StopScanning = {
        Id = 1
    }
}

messages.DeviceAdded = {
    DeviceAdded = {
        Id = 0,
        DeviceName = "",
        DeviceIndex = 0,
        DeviceMessages = {}
    }
}

messages.DeviceRemoved = {
    DeviceRemoved = {
        Id = 0,
        DeviceIndex = 0
    }
}

-- Generic device messages

messages.StopAllDevices = {
    StopAllDevices = {
        Id = 1
    }
}

messages.VibrateCmd = {
    VibrateCmd = {
        Id = 1,
        DeviceIndex = 0,
        Speeds = {}
    }
}

--
-- Global variables
--


buttplug.msg_counter = 1
buttplug.devices = {}
buttplug.got_server_info = false
buttplug.scanning = false

--
--
--

-- Send a message to the Buttplug Server
local function send(msg)
    local message_type = next(msg)

    msg[message_type].Id = buttplug.msg_counter
    buttplug.msg_counter = buttplug.msg_counter + 1
    
    local payload = "[" .. json.encode(msg) .. "]"
    print("> " .. payload)
    buttplug.sock:send(payload)
end

-- Connect to websocket address, returns open socket
function buttplug.connect(websocket_address)
    buttplug.sock = pollnet.open_ws(websocket_address)
    return buttplug.sock
end

function buttplug.request_server_info(client_name)
    local msg = messages.RequestServerInfo

    msg["RequestServerInfo"]["ClientName"] = client_name

    send(msg)
end


function buttplug.request_device_list()
    send(messages.RequestDeviceList)
end

function buttplug.start_scanning()
    send(messages.StartScanning)
end

function buttplug.stop_scanning()
    send(messages.StopScanning)
end

-- Sends a vibrate command to device with the index `dev_index`.
-- `speeds` is a table with 1 vibration value per motor e.g. { 0.2, 0.2
-- } would set both motors on a device with 2 motors to 0.2
function buttplug.send_vibrate_cmd(dev_index, speeds)
    if (not buttplug.has_device()) then
        -- print('no device, exit')
        return
    end

    local msg = messages.VibrateCmd

    msg["VibrateCmd"]["DeviceIndex"] = dev_index

    for i, v in ipairs(speeds) do
        msg["VibrateCmd"]["Speeds"][i] = { Index = i - 1, Speed = v }
    end

    send(msg)
end

function buttplug.send_stop_all_devices_cmd()
    if (not buttplug.has_device()) then
        print('no device, exit')
        return
    end

    send(messages.StopAllDevices)
end

function buttplug.has_device()
    return table.getn(buttplug.devices) > 0
end

function buttplug.handle_message(raw_message)
    local msg = json.decode(raw_message)[1]
    local msg_type = next(msg)
    local msg_contents = msg[msg_type]

    -- if ServerInfo, set flag
    if (msg_type == "ServerInfo") then
        buttplug.got_server_info = true
    end

    -- if DeviceList, add any devices
    if (msg_type == "DeviceList") then
        local devices = msg_contents["Devices"]

        for i, v in ipairs(devices) do
            print(v)
        end
    end

    -- if DeviceAdded, add the device
    if (msg_type == "DeviceAdded") then
        local dev_index = msg_contents["DeviceIndex"]
        
        buttplug.devices[dev_index + 1] = {
            index = msg_contents["DeviceIndex"],
            name = msg_contents["DeviceName"],
            messages = msg_contents["DeviceMessages"]
        }

        buttplug.scanning = false
        send(messages.StopScanning)
    end

    -- if DeviceRemoved, remove the device
    if (msg_type == "DeviceRemoved") then
        local index = msg_contents["DeviceIndex"]
        print("Removing device: " .. index)
    end
end

function buttplug.get_and_handle_messages()
    local sock_status = buttplug.sock:poll()

    local message = buttplug.sock:last_message()

    if message then
        print("< " .. message)

        buttplug.handle_message(message)
    end

    return sock_status, message
end

function buttplug.scan_for_devices()
    buttplug.scanning = true
    send(messages.StartScanning)
end

function buttplug.init()
    -- open connection
    -- check for existing devices
    -- start scanning
    -- get first device    
end

return buttplug
