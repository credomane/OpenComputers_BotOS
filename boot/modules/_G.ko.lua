--[[ Custom global functions that don't belong anywhere else ]]--

local y = 1
local last_sleep = computer.uptime()
local screen = component.list("screen", true)()
local gpu = screen and component.list("gpu", true)()
if gpu then
    gpu = component.proxy(gpu)
    if not gpu.getScreen() and screen then
        gpu.bind(screen)
    end
    local w, h = gpu.maxResolution()
    gpu.setResolution(w, h)
    gpu.setBackground(0x000000)
    gpu.setForeground(0xFFFFFF)
    gpu.fill(1, 1, w, h, " ")
end

function _G.log(msg)
    if gpu then
        local w, h = gpu.getResolution(w, h)
        gpu.set(1, y, msg)
        if y == h then
            gpu.copy(1, 2, w, h - 1, 0, -1)
            gpu.fill(1, h, w, 1, " ")
        else
            y = y + 1
        end
        if fs and not fs.isReadOnly() then
            local f = fs.open("/logs/boot.log", "a")
            fs.write(f, "[ " .. os.date() .. " ] " .. tostring(msg) .. "\n");
            fs.close(f)
        end
    end
    -- boot can be slow in some environments, protect from timeouts
    if computer.uptime() - last_sleep > 1 then
        local signal = table.pack(computer.pullSignal(0))
        -- there might not be any signal
        if signal.n > 0 then
            -- push the signal back in queue for the system to use it
            computer.pushSignal(table.unpack(signal, 1, signal.n))
        end
        last_sleep = computer.uptime()
    end
end

return true