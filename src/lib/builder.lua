--[[ Builder for structures ]]--
local module = {
    _version = "builder.lua v2020.08.25",
    _description = "3d structure builder for OpenComputers",
    _url = "",
    _license = [[MIT]]
}

local vector = require("vector3d")
local sides = require("sides")

local builder = {}
builder.__index = builder

--Creates a new builder
local function new(machine)
    local b = {
        machine = machine,
        structure = { },
        size = vector(0, 0, 0),
        original_home = vector(0, 0, 0),
    }
    return setmetatable(b, builder)
end

-- check if an object is a vector
local function isBuilder(t)
    return getmetatable(t) == builder
end

function builder:setHomeAt(v)
    if not vector.isVector(v) then
        return false
    end
    self.original_home:set(self.machine.getHome())
    self.machine.setHomeAt(v)
end

function builder:restoreHome()
    self.machine.setHomeAt(self.original_home)
end

--Sets the size of the expected build area
function builder:setSize(size)
    if not vector.isVector(size) then
        return false
    end
    self.size:set(size)
    return true
end

--Make sure the structure fits in te build area and center on x,0,z for coolness.
function builder:checkSizes()
    if not vector.isVector(self.size) then
        return false, "Builder's size is not a vector"
    end
    if not vector.isVector(self.structure.size) then
        return false, "Structure's size is not a vector"
    end
    local size = self.size - self.structure.size
    if size.x < 0 or size.y < 0 or size.z < 0 then
        return false, "Structure is larger than build area"
    end
    return true
end

--Set a structure
function builder:setStructure(structure)
    self.structure = structure
end

--Loads a structure
function builder:loadStructure(structure)
    self.structure = require(structure)
end

-- Goes through Drone/Robot inventory and drops everything to selected side
function builder:removeMaterials(side)
    for i = 1, self.machine.inventorySize() do
        if (self.machine.count(i) > 0) then
            self.machine.select(i)
            self.machine.drop(side, self.machine.count(i))
        end
    end
end

--Picks up materials. WARNING this function assumes material on <side> matches what materials[<matNum>] wants.
-- If materials wants more than a stack everything will break.
-- If you have an inventory controller upgrade use getMaterials instead!
function builder:getMaterialsDumb(side, matNum)
    self.machine.select(matNum)
    self.machine.suck(side, self.structure.materials[matNum].count)
end

function builder:getMaterials(side)
    self.machine.select(self.machine.inventorySize())
    self.machine.suck(side, self.machine.count(1))

    for i = 1, self.structure.materials do
        if (self.machine.count(i) == 0) then

            self.machine.suck(side, self.machine.count(i))
        end
    end
end

function builder:getSlot(material)
    local i = 1
    for mat in pairs(self.structure.materials) do
        if material == self.structure.materials[mat].item then
            return i
        end
        i = i + 1
    end
    return nil
end

function builder:buildIt()
    for i = 1, #self.structure.buildsteps do
        local action = self.structure.buildsteps[i]
        if action.type == "move" then
            self.machine.moveToSync(action.position)
        elseif action.type == "place" then
            local side = action.side or sides.front
            local item = action.item or nil
            local face = action.face or nil
            local sneak = action.sneak or false
            local slot = self:getSlot(item) or 1
            self.machine.select(slot)
            self.machine.place(side, face, sneak)
        elseif action.type == "drop" then
            local side = action.side or sides.front
            local item = action.item or nil
            local count = action.count or 1
            local slot = self:getSlot(item) or 1
            self.machine.select(slot)
            self.machine.drop(side, count)
        elseif action.type == "suck" then
        end
    end
end

-- pack up and return module
module.new = new
module.isBuilder = isBuilder

return setmetatable(module, { __call = function(_, ...)
    return new(...)
end })
