--[[ This is the module that controls drones. ]]--

local isRobot = component.list("robot", true)()

if not isRobot then
    return false
end

_G.robot = component.proxy(isRobot)

return true