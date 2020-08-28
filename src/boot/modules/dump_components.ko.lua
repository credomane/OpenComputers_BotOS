--[[ Simple module to dump everything about components attached to a computer ]]--

local serpent = require("serpent")
local components = component.list()

local f = fs.open("/_dumps/component.list.txt", "w")
fs.write(f, serpent.block(components))
fs.close(f)

for i in pairs(components) do
    f = fs.open("/_dumps/component-" .. components[i] .. "_" .. i .. ".txt", "w")
    fs.write(f, serpent.block(component.proxy(i)))
    fs.close(f)
end

return false
