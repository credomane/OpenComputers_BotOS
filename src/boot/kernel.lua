--[[ Credomane's BotOS kernel ]]--

--Everything in this file is "compiled" into the kernel
--All other "kernel" things are shoved off into modules

_G._OSVERSION = "BotOS 0.0.1"

_G.fs = component.proxy(computer.getBootAddress())

--[[ These contain lib stuff used by require() ]]--
local loaded = {}
local libPaths = {
    "/lib/?.lua",
}

--[[ Crash the system in a slightly prettier fashion. Not necessary, but nice to have. ]]--
function _G.crash(reason)
    checkArg(1, reason, "string", "nil")
    reason = reason or "No reason given"
    log("==== crash " .. os.date() .. " ====")
    log("crash reason: " .. reason)
    local traceback = debug.traceback()
    traceback = traceback:gsub("\t", "  ")
    for line in traceback:gmatch("[^\n]+") do
        log(line)
    end
    log("==== end crash message ====")
    while true do
        -- Freeze the system
        computer.pullSignal()
    end
end

--[[ Setup loadfile, dofile, and require here ]]--

function _G.loadfile(file, mode, env)
    checkArg(1, file, "string")
    checkArg(2, mode, "string", "nil")
    checkArg(3, env, "table", "nil")
    mode = mode or "bt"
    env = env or _G

    if not fs.exists(file) then
        return nil, "File not found: '" .. file .. "'"
    end
    local handle = fs.open(file)
    local buffer = ""
    repeat
        local data = fs.read(handle, math.huge)
        buffer = buffer .. (data or "")
    until not data
    fs.close(handle)
    return load(buffer, "=" .. file, mode, env)
end

function _G.dofile(file)
    checkArg(1, file, "string")
    local ok, err = loadfile(file)
    if not ok then
        return nil, err
    end
    return ok()
end

function _G.require(lib)
    checkArg(1, lib, "string")
    if loaded[lib] then
        return loaded[lib]
    else
        for i = 1, #libPaths, 1 do
            local filePath = libPaths[i]:gsub("%?", lib)
            if fs.exists(filePath) then
                local ok, err = dofile(filePath)
                if not ok then
                    if err ~= nil then
                        crash("Lib failed to load: '" .. lib .. "' " .. err)
                    else
                        crash("Lib failed to load: '" .. lib .. "' No reason given.")
                    end
                end
                loaded[lib] = ok
                return ok
            else
                crash("Lib not found: " .. lib)
            end
        end
    end
end

function _G.loadmodule(module)
    checkArg(1, module, "string")
    module = module .. ".ko"
    if loaded[module] ~= nil then
        return loaded[module]
    else
        local filePath = "/boot/modules/" .. module .. ".lua"
        if fs.exists(filePath) then
            local ok, err = dofile(filePath)
            --Modules add things to existing globals.
            --They return true if they did something and false if they did not.
            --Anything else is an error condition
            if type(ok) ~= "boolean" then
                if err ~= nil then
                    crash("Module load failed: '" .. module .. "' " .. err)
                else
                    crash("Module load failed: '" .. module .. "' Didn't return proper value.")
                end
            end
            loaded[module] = ok
            return loaded[module]
        else
            crash("Module not found: " .. module)
        end
    end
end

--[[ Setup the stuff we want on the global variable. ]]--
loadmodule("_G")
--loadmodule("dump_components")

log("Starting " .. _OSVERSION)
log(computer.freeMemory() .. "/" .. computer.totalMemory() .. " RAM")
log(computer.energy() .. "/" .. computer.maxEnergy() .. " Energy")

--[[ Load all the modules ]]--
--loadmodule("computer")
loadmodule("os")

--[[ What device type are we?]]--
_G.isDrone = loadmodule("drone")
_G.isRobot = loadmodule("robot")
_G.isMicro = loadmodule("microcontroller")
_G.isTablet = loadmodule("tablet")
_G.isDesktop = not (isDrone or isRobot or isMicro or isTablet)

local osfile

if isDrone then
    osfile = require("drone")
end

while true do
    local ok, err = osfile()
    if not ok then
        crash(err)
    end
end
