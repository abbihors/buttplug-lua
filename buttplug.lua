-- minimal buttplug client
local json = require('json')

local client_name = "Lua"
local msg_counter = 1

--
--
-- Buttplug messages
--
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
--
--

function send(msg)
    local message_type = next(msg)

    msg[message_type].Id = msg_counter
    msg_counter = msg_counter + 1
    
    local payload = "[" .. json.encode(msg) .. "]"
    print(payload)
    -- sock:send(payload)
end

-- Sends a vibrate command to device with the index `dev_index`.
-- `speeds` is a table with 1 vibration value per motor e.g. { 0.2, 0.2
-- } would set both motors on a device with 2 motors to 0.2
function send_vibrate_cmd(dev_index, speeds)
    local msg = messages.VibrateCmd

    msg["VibrateCmd"]["DeviceIndex"] = dev_index

    for i, v in ipairs(speeds) do
        msg["VibrateCmd"]["Speeds"][i] = { Index = i - 1, Speed = v}
    end

    send(msg)
end

send_vibrate_cmd(0, { 0.2, 0.2 })

-- sends this message and increments id
-- buttplug.send(RequestServerInfo)
-- send(messages.RequestServerInfo)
-- send(messages.ServerInfo)

-- print(json.encode(RequestServerInfo))

-- local reply = json.decode('[{"ServerInfo":{"MaxPingTime":100,"MessageVersion":1,"Id":2}}]')

-- print(reply[1].ServerInfo)
-- if (reply )

-- local m = next(reply[1])

-- print(m == "ServerInfo")
-- print(reply[1][m]["Id"])
-- print(reply[1][m].Id)
-- print(reply[1][0])