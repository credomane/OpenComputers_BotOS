--[[ This is the module that controls drones. ]]--

local isDrone = component.list("drone", true)()

if not isDrone then
    return false
end

_G.drone = component.proxy(isDrone)

local omove = drone.move -- Going to override the original drone.move but we still need original to actually move

local statusText = {
    l1 = "",
    l2 = "",
    wrap = true
}

drone.pos = checkPos({ 0, 0, 0 })
drone.zero = checkPos({ 0, 0, 0 })

function drone.status(l1, l2)
    checkArg(1, l1, "string", "number", "nil")
    checkArg(2, l2, "string", "number", "nil")

    if l1 == nil and l2 == nil then
        return
    end

    if l1 ~= nil then
        l1 = tostring(l1)
    end
    if l2 ~= nil then
        l2 = tostring(l2)
    end

    if l1 ~= nil and l2 == nil and statusText.wrap then
        statusText.l1 = string.sub(l1:sub(1, 10) .. "          ", 1, 10)
        statusText.l2 = string.sub(l1:sub(11, 20) .. "          ", 1, 10)
    end

    if l1 ~= nil then
        statusText.l1 = string.sub(l1 .. "          ", 1, 10)
    end

    if l2 ~= nil then
        statusText.l2 = string.sub(l2 .. "          ", 1, 10)
    end

    drone.setStatusText(statusText.l1 .. "\n" .. statusText.l2);
end

drone.status("Setting up Drone")

function drone.getPosition()
    return checkPos(drone.pos)
end

function drone.setPosition(pos)
    checkArg(1, pos, "table")
    drone.pos = checkPos(pos)
end

function drone.changePosition(pos)
    checkArg(1, pos, "table")
    pos = checkPos(pos)
    drone.pos.x = drone.pos.x + pos.x
    drone.pos.y = drone.pos.y + pos.y
    drone.pos.z = drone.pos.z + pos.z
end

function drone.gps()
    local x, y, z = gps.locate(2);
    local pos = checkPos({ x, y, z })
    drone.setPosition(pos)
    return pos
end

function drone.distanceFrom(pos)
    checkArg(1, pos, "table")
    pos = checkPos(pos)
    return math.floor(math.sqrt((pos.x - drone.pos.x) ^ 2 + (pos.y - drone.pos.y) ^ 2 + (pos.z - drone.pos.z) ^ 2) * 100) / 100
end

function drone.setZeroAt(pos)
    checkArg(1, pos, "table")
    pos = checkPos(pos)
    drone.zero.x = pos.x
    drone.zero.y = pos.y
    drone.zero.z = pos.z
end

function drone.moveTo(pos)
    checkArg(1, pos, "table")
    pos = checkPos(pos)
    local newX = drone.zero.z + pos.x
    local newY = drone.zero.y + pos.y
    local newZ = drone.zero.z + pos.z
    drone.move(newX - drone.pos.x, newY - drone.pos.y, newZ - drone.pos.z)
end

function drone.moveToSync(pos)
    checkArg(1, pos, "table")
    pos = checkPos(pos)

    local dest = checkPos({
        drone.zero.x + pos.x,
        drone.zero.y + pos.y,
        drone.zero.z + pos.z
    })

    local newX = drone.zero.x + pos.x
    local newY = drone.zero.y + pos.y
    local newZ = drone.zero.z + pos.z
    omove(newX - drone.pos.x, newY - drone.pos.y, newZ - drone.pos.z)

    local distance = drone.distanceFrom(dest)
    local lastDistance = distance

    while distance > 0.1 do
        os.sleep(1)
        drone.gps()
        distance = drone.distanceFrom(dest)
        if math.floor(distance) == math.floor(lastDistance) and distance > 0.1 then
            --Drone is stuck! Make some noise and flash the lights then shutdown
            omove(0, 0, 0)
            drone.gps()
            local light = drone.getLightColor()
            drone.status("I am STUCK!!!", distance)
            drone.setLightColor(0xFF0000)
            computer.beep(2000, 3)
            drone.setLightColor(0x990000)
            computer.beep(1000, 1)
            drone.setLightColor(0xFF0000)
            computer.beep(2000, 3)
            drone.setLightColor(0x990000)
            computer.beep(1000, 1)
            drone.setLightColor(0xFF0000)
            computer.beep(2000, 2)
            drone.setLightColor(light)
            computer.shutdown()
            return false
        end
        lastDistance = distance
    end

    return true
end

function drone.move(pos)
    checkArg(1, pos, "table")
    pos = checkPos(pos)
    omove(pos.x, pos.y, pos.z)
end

if gps then
    drone.status("GPS locate");
    local pos = drone.gps()
    drone.status(pos.x .. "," .. pos.y .. "," .. pos.z)
end

return true