--[[ GPU , screen, KB setup here ]]--

local w, h
local screen = component.list("screen", true)()
local gpu = screen and component.list("gpu", true)()
if gpu then
    gpu = component.proxy(gpu)
    if not gpu.getScreen() then
        gpu.bind(screen)
    end
    w, h = gpu.maxResolution()
    gpu.setResolution(w, h)
    gpu.setBackground(0x000000)
    gpu.setForeground(0xFFFFFF)
    gpu.fill(1, 1, w, h, " ")
end
return gpu
