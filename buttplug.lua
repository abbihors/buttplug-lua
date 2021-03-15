-- buttplug.lua -- Lua client for buttplug.io
local json = require('json')
local pollnet = require("pollnet")

local buttplug = {}

local msg_counter = 1

--
-- Buttplug messages
--

local messages = {}

messages.Ok = {
    Ok = {
        Id = 1
    }
}

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
        MaxPingTime = 100
    }
}

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

messages.VibrateCmd = {
    VibrateCmd = {
        Id = 1,
        DeviceIndex = 0,
        Speeds = {}
    }
}

--
--
--

-- TODO: Figure out what to do about opening the websocket
local url = "ws://127.0.0.1:12345"
local sock = pollnet.open_ws(url)

-- Send a message to the Buttplug Server
function send(msg)
    local message_type = next(msg)

    msg[message_type].Id = msg_counter
    msg_counter = msg_counter + 1
    
    local payload = "[" .. json.encode(msg) .. "]"
    print(payload)
    sock:send(payload)
end

function buttplug.request_server_info(client_name)
    local msg = messages.RequestServerInfo

    msg["RequestServerInfo"]["ClientName"] = client_name

    send(msg)
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
    local msg = messages.VibrateCmd

    msg["VibrateCmd"]["DeviceIndex"] = dev_index

    for i, v in ipairs(speeds) do
        msg["VibrateCmd"]["Speeds"][i] = { Index = i - 1, Speed = v}
    end

    send(msg)
end

return buttplug