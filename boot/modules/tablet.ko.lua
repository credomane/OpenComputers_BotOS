--[[ This is the module that controls drones. ]]--

local isTablet = component.list("tablet", true)()

if not isTablet then
    return false
end

_G.drone = component.proxy(isTablet)

return true