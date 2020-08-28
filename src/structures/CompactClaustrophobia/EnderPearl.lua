local structure = {}
local sides = require("sides")
local vector = require("vector3d")

--The cube this structure fits into.
structure.size = vector(3, 3, 3)

--What materials does this structure need?
structure.materials = {}
structure.materials[1] = { item = "minecraft:obsidian", count = 26 }
structure.materials[2] = { item = "minecraft:blockRedstone", count = 1 }
structure.materials[3] = { item = "minecraft:dustRedstone", count = 1 }

--How should the drone/robot go about building this structure?
structure.buildsteps = {
    { type = "move", position = vector(0, 1, 0) },
    { type = "place", item = "minecraft:obsidian", side = sides.up },
    { type = "place", item = "minecraft:obsidian", side = sides.down },
    { type = "move", position = vector(1, 1, 0) },
    { type = "place", item = "minecraft:obsidian", side = sides.west },
    { type = "place", item = "minecraft:obsidian", side = sides.up },
    { type = "place", item = "minecraft:obsidian", side = sides.down },
    { type = "move", position = vector(2, 1, 0) },
    { type = "place", item = "minecraft:obsidian", side = sides.west },
    { type = "place", item = "minecraft:obsidian", side = sides.up },
    { type = "place", item = "minecraft:obsidian", side = sides.down },
    { type = "move", position = vector(2, 1, 1) },
    { type = "place", item = "minecraft:obsidian", side = sides.north },
    { type = "place", item = "minecraft:obsidian", side = sides.up },
    { type = "place", item = "minecraft:obsidian", side = sides.down },
    { type = "move", position = vector(1, 1, 1) },
    { type = "place", item = "minecraft:obsidian", side = sides.east },
    { type = "place", item = "minecraft:obsidian", side = sides.up },
    { type = "place", item = "minecraft:obsidian", side = sides.down },
    { type = "move", position = vector(0, 1, 1) },
    { type = "place", item = "minecraft:blockRedstone", side = sides.east },
    { type = "place", item = "minecraft:obsidian", side = sides.up },
    { type = "place", item = "minecraft:obsidian", side = sides.down },
    { type = "move", position = vector(0, 1, 2) },
    { type = "place", item = "minecraft:obsidian", side = sides.north },
    { type = "place", item = "minecraft:obsidian", side = sides.up },
    { type = "place", item = "minecraft:obsidian", side = sides.down },
    { type = "move", position = vector(1, 1, 2) },
    { type = "place", item = "minecraft:obsidian", side = sides.west },
    { type = "place", item = "minecraft:obsidian", side = sides.up },
    { type = "place", item = "minecraft:obsidian", side = sides.down },
    { type = "move", position = vector(2, 1, 2) },
    { type = "place", item = "minecraft:obsidian", side = sides.west },
    { type = "place", item = "minecraft:obsidian", side = sides.up },
    { type = "place", item = "minecraft:obsidian", side = sides.down },
    { type = "move", position = vector(3, 1, 2) },
    { type = "place", item = "minecraft:obsidian", side = sides.west },
    { type = "move", position = vector(3, 1, -1) },
    { type = "move", position = vector(1, 1, -2) },
    { type = "drop", item = "minecraft:dustRedstone", count = 1, side = sides.south },
}

return structure
