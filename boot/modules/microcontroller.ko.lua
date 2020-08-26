--[[ This is the module that controls drones. ]]--

local isMicro = component.list("microcontroller", true)()

if not isMicro then
    return false
end

_G.drone = component.proxy(isMicro)

return true