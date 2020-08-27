--[[ This is the module that controls drones. ]]--

local isDrone = component.list("drone", true)()

if not isDrone then
    return false
end

_G.drone = component.proxy(isDrone)

local vector = require("vector3d")
local gps = require("gps")

local omove = drone.move -- Going to override the original drone.move but we still need original to actually move

local statusText = {
    l1 = "",
    l2 = "",
    wrap = true,
    debuglog = false
}

drone.pos = vector(0, 0, 0)
drone.home = vector(0, 0, 0)

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
    if statusText.debuglog then
        log(statusText.l1 .. " " .. statusText.l2)
    end
end

drone.status("Setting up Drone")

function drone.getPosition()
    return vector(drone.pos)
end

function drone.setPosition(pos)
    if not vector.isVector(pos) then
        error("pos is not a vector", 3)
    end
    drone.pos:set(pos)
end

function drone.changePosition(pos)
    if not vector.isVector(pos) then
        error("pos is not a vector", 3)
    end
    drone.pos:set(drone.pos + pos)
end

function drone.gps()
    local x, y, z
    local tries = 10
    repeat
        x, y, z = gps.locate(5)
        tries = tries - 1
        if tries < 0 then
            drone.status("GPS failed", "10 tries")
            break
        end
    until x ~= nil
    local pos = vector(x, y, z)
    drone.setPosition(pos)
    return pos
end

function drone.distanceFrom(pos)
    if not vector.isVector(pos) then
        error("pos is not a vector", 3)
    end
    return math.floor(math.sqrt((pos.x - drone.pos.x) ^ 2 + (pos.y - drone.pos.y) ^ 2 + (pos.z - drone.pos.z) ^ 2) * 100) / 100
end

function drone.setHomeAt(pos)
    if not vector.isVector(pos) then
        error("pos is not a vector", 3)
    end
    drone.home:set(pos)
end

--Moves drone by passed vector
function drone.move(pos)
    if not vector.isVector(pos) then
        error("pos is not a vector", 3)
    end
    drone.changePosition(pos)
    omove(pos:unpack())
end

--Moves drone by passed vector using drone.home as offset
function drone.moveTo(pos)
    if not vector.isVector(pos) then
        error("pos is not a vector", 3)
    end
    local dest = drone.home + pos
    local moveOffset = dest - drone.pos
    drone.changePosition(moveOffset)
    omove(moveOffset:unpack())
end

--Moves drone by passed vector using drone.home as offset
-- and attempts to wait for drone to get there before returning
function drone.moveToSync(pos)
    if not vector.isVector(pos) then
        error("pos is not a vector", 3)
    end

    drone.moveTo(pos)

    local dest = drone.home + pos
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

if gps then
    drone.status("GPS locate");
    local pos = drone.gps()
    drone.status(tostring(pos))
end

return true
