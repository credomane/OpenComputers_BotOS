local name = drone.name()

return loadfile("/devices/drone/" .. name .. ".lua")

