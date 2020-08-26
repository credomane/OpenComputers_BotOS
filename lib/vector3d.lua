local module = {
    _version = "vector3d.lua v2020.08.25",
    _description = "3d vector library for Lua",
    _url = "",
    _license = [[MIT]]
}

-- local function for checking args are what we want
local function checkArg(n, have, ...)
    have = type(have)
    local function check(want, ...)
        if not want then
            return false
        else
            return have == want or check(...)
        end
    end
    if not check(...) then
        local msg = string.format("bad argument #%d (%s expected, got %s)",
                n, table.concat({ ... }, " or "), have)
        error(msg, 3)
    end
end


-- create the module
local vector = {}
vector.__index = vector

-- get a random function from Love2d or base lua, in that order.
local rand = math.random
if love and love.math then
    rand = love.math.random
end

-- makes a new vector
local function new(x, y, z)
    local v = {
        x = tonumber(x) or 0,
        y = tonumber(y) or 0,
        z = tonumber(z) or 0
    }
    return setmetatable(v, vector)
end

-- check if an object is a vector
local function isVector(t)
    return getmetatable(t) == vector
end

-- set the values of the vector to something new
function vector:set(x, y, z)
    if isVector(x) then
        self.x, self.y, self.z = x.x, x.y, x.z
        return self
    end
    checkArg(1, x, "number")
    checkArg(2, y, "number")
    checkArg(3, z, "number")
    self.x, self.y, self.z = x or self.x, y or self.y, z or self.z
    return self
end

-- replace the values of a vector with the values of another vector
function vector:replace(v)
    assert(isVector(v), "wrong argument type: (expected <vector>, got "..type(v)..")")
    self.x, self.y, self.z = v.x, v.y, v.z
    return self
end

-- returns a copy of a vector
function vector:clone()
    return new(self.x, self.y, self.z)
end

-- meta function to add vectors together
-- ex: (vector(5,6,7) + vector(7,6,5)) is the same as vector(12,11,12)
function vector.__add(a, b)
    assert(isVector(a), "wrong argument type: (expected <vector>, got "..type(a)..")")
    assert(isVector(b), "wrong argument type: (expected <vector>, got "..type(b)..")")
    return new(a.x + b.x, a.y + b.y, a.z + b.z)
end

-- meta function to subtract vectors
function vector.__sub(a, b)
    assert(isVector(a), "wrong argument type: (expected <vector>, got "..type(a)..")")
    assert(isVector(b), "wrong argument type: (expected <vector>, got "..type(b)..")")
    return new(a.x - b.x, a.y - b.y, a.z - b.z)
end

-- meta function to multiply vectors
function vector.__mul(a, b)
    if type(a) == 'number' then
        return new(a * b.x, a * b.y, a * b.z)
    elseif type(b) == 'number' then
        return new(a.x * b, a.y * b, a.z * b)
    else
        assert(isVector(a), "wrong argument type: (expected <vector>, got "..type(a)..")")
        assert(isVector(b), "wrong argument type: (expected <vector>, got "..type(b)..")")
        return new(a.x * b.x, a.y * b.y, a.z * b.z)
    end
end

-- meta function to divide vectors
function vector.__div(a, b)
    assert(isVector(a), "wrong argument type: (expected <vector>, got "..type(a)..")")
    checkArg(2, b, "number")
    return new(a.x / b.x, a.y / b.y, a.z / b.z)
end

-- meta function to make vectors negative
-- ex: (negative) -vector(5,6,7) is the same as vector(-5,-6,-7)
function vector.__unm(v)
    assert(isVector(v), "wrong argument type: (expected <vector>, got "..type(v)..")")
    return new(-v.x, -v.y, -v.z)
end

-- meta function to check if vectors have the same values
function vector.__eq(a, b)
    assert(isVector(a), "wrong argument type: (expected <vector>, got "..type(a)..")")
    assert(isVector(b), "wrong argument type: (expected <vector>, got "..type(b)..")")
    return a.x == b.x and a.y == b.y and a.z == b.z
end

-- meta function to change how vectors appear as string
-- ex: print(vector(2,8,3)) - this prints '(2, 8, 3)'
function vector:__tostring()
    return "(" .. self.x .. ", " .. self.y .. ", " .. self.z .. ")"
end

-- get the distance between two vectors
function vector.dist(a, b)
    assert(isVector(a), "wrong argument type: (expected <vector>, got "..type(a)..")")
    assert(isVector(b), "wrong argument type: (expected <vector>, got "..type(b)..")")
    return math.sqrt((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2 + (a.z - b.z) ^ 2)
end

-- return the dot product of the vector
function vector:dot(v)
    return self.x * v.x + self.y * v.y + self.z * v.z
end

function vector:cross(v)
    return vector.new(
            self.y * v.z - self.z * v.y,
            self.z * v.x - self.x * v.z,
            self.x * v.y - self.y * v.x
    )
end

function vector:length()
    return math.sqrt(self.x ^ 2 + self.y ^ 2 + self.z ^ 2)
end

-- normalize the vector (give it a magnitude of 1)
function vector:normalize()
    return self:mul(1 / self:length())
end

function vector:round(tolerance)
    tolerance = tolerance or 1.0
    return vector.new(
            math.floor((self.x + (tolerance * 0.5)) / tolerance) * tolerance,
            math.floor((self.y + (tolerance * 0.5)) / tolerance) * tolerance,
            math.floor((self.z + (tolerance * 0.5)) / tolerance) * tolerance
    )
end

-- return x and y of vector as a regular array
function vector:array()
    return {self.x, self.y, self.z}
end

-- return x and y of vector, unpacked from table
function vector:unpack()
    return self.x, self.y, self.z
end


-- pack up and return module
module.new = new
module.isVector = isVector

return setmetatable(module, { __call = function(_, ...)
    return new(...)
end })
