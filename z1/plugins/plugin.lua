require "z1.tools.svg"
require "z1.tools.error"

Plugin = {
    BORDER = 20,
    svg = Svg:new()
}

function Plugin:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Plugin:build(tags, atoms, ligations)
    local err = self:measureBounds(atoms)
    if err ~= nil then return nil, err end

    local err = self:drawAtom(atoms)
    if err ~= nil then return nil, err end

    local err = self:drawLigation(atoms, ligations)
    if err ~= nil then return nil, err end

    local svg_content, err = self.svg:build(self.width, self.height)
    return svg_content, err
end

function Plugin:drawAtom(atoms)
    return Error:new {
        message = "Method drawAtom not Implemented"
    }
end

function Plugin:drawLigation(atoms, ligations)
    return Error:new {
        message = "Method drawLigation not Implemented"
    }
end

function Plugin:measureBounds(atoms)
    local min_x = 0
    local min_y = 0
    local max_x = 0
    local max_y = 0
    
    for _, atom in ipairs(atoms) do
        local x = atom["x"]
        local y = atom["y"]
    
        if atom["symbol"] == "X" then
            goto continue
        end
    
        if x > max_x then max_x = x end
        if y > max_y then max_y = y end
        if x < min_x then min_x = x end
        if y < min_y then min_y = y end
    
        ::continue::
    end
    
    local cwidth = max_x + -min_x
    local cheight = max_y + -min_y
    
    self.width = self.BORDER * 2 + cwidth
    self.height = self.BORDER * 2 + cheight
    
    self.center_x = self.BORDER + math.abs(min_x)
    self.center_y = self.BORDER + math.abs(min_y)

    return nil
end