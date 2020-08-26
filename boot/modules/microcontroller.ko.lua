--[[ This is the module that controls drones. ]]--

local isMicro = component.list("microcontroller", true)()

if not isMicro then
    return false
end

_G.microcontroller = component.proxy(isMicro)

return true