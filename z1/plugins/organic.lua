require "z1.tools.svg"
require "z1.tools.error"
require "z1.plugins.plugin"

OrganicPlugin = Plugin:new {
    carbon_ligation_distance = 1,

    carbon_waves = {
        { 0 },
        { 90, -90 },
        { 90, 0, 90 }
    }
}

function OrganicPlugin:build(tags, atoms, ligations)
    local err = self:measureBounds(atoms, ligations)
    if err ~= nil then return nil, err end

    local err = self:drawAtom(atoms, ligations)
    if err ~= nil then return nil, err end

    local err = self:drawLigation(atoms, ligations)
    if err ~= nil then return nil, err end

    local svg_content, err = self.svg:build(self.width, self.height)
    return svg_content, err
end

function OrganicPlugin:measureBounds(atoms, ligations)
    local min_x = 0
    local min_y = 0
    local max_x = 0
    local max_y = 0

    for idx, atom in ipairs(atoms) do
        local x = atom["x"]
        local y = atom["y"]

        if atom["symbol"] == "X" then goto continue end

        if atom["symbol"] == "H" and atom["charge"] == 0 then
            for _, lig in ipairs(ligations) do
                if lig["atoms"][2] == idx and atoms[ lig["atoms"][1] ]["symbol"] == "C" then
                    goto continue
                end
            end
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
end

function OrganicPlugin:drawAtom(atoms, ligations)
    for idx, atom in ipairs(atoms) do
        local symbol = atom["symbol"]
        local charge = atom["charge"]
        local x = self.center_x + atom["x"]
        local y = self.center_y + atom["y"]

        if charge ~= 0 then
            if charge == 1 then
                charge = "+"
            end
            if charge == -1 then
                charge = "-"
            end
            self.svg:subtext(charge, x + ATOM_RADIUS, y - ATOM_RADIUS)
        end

        if symbol == "C" then
            goto continue
        end

        if symbol == "H" and charge == 0 then
            for _, lig in ipairs(ligations) do
                if lig["atoms"][2] == idx and atoms[ lig["atoms"][1] ]["symbol"] == "C" then
                    goto continue
                end
            end
        end

        self.svg:text(atom["symbol"], x, y)

        ::continue::
    end
end

function OrganicPlugin:drawLigation(atoms, ligations)
    for _, ligation in ipairs(ligations) do
        local from_atom = atoms[ligation["atoms"][1]]
        local to_atom = atoms[ligation["atoms"][2]]

        if to_atom["symbol"] == "H" and to_atom["charge"] == 0 and from_atom["symbol"] == "C" then
            goto continue
        end

        local ax = self.center_x + from_atom["x"]
        local ay = self.center_y + from_atom["y"]
        local bx = self.center_x + to_atom["x"]
        local by = self.center_y + to_atom["y"]

        local angles = WAVES[ ligation["eletrons"] ]

        local a_angle = math.atan((by - ay), (bx - ax))
        local b_angle = math.pi + a_angle

        if ligation["eletrons_behaviour"] ~= "i" then
            for idx, angle in ipairs(angles) do

                local from_ATOM_RADIUS = ATOM_RADIUS
                local a_sum = angle
                if from_atom["symbol"] == "C" then
                    from_ATOM_RADIUS =  self.carbon_ligation_distance
                    a_sum =  self.carbon_waves[ ligation["eletrons"] ][idx]
                end

                local nax = ax + math.cos(a_angle - (math.pi * a_sum / 180)) * from_ATOM_RADIUS
                local nay = ay + math.sin(a_angle - (math.pi * a_sum / 180)) * from_ATOM_RADIUS

                local to_ATOM_RADIUS = ATOM_RADIUS
                local b_sum = angle
                if to_atom["symbol"] == "C" then
                    to_ATOM_RADIUS =  self.carbon_ligation_distance
                    b_sum =  self.carbon_waves[ ligation["eletrons"] ][idx]
                end

                local nbx = bx + math.cos(b_angle + (math.pi * b_sum / 180)) * to_ATOM_RADIUS
                local nby = by + math.sin(b_angle + (math.pi * b_sum / 180)) * to_ATOM_RADIUS

                self.svg:line(nax, nay, nbx, nby)
            end
        end

        ::continue::
    end
end