local min_x = 0
local min_y = 0
local max_x = 0
local max_y = 0

local carbon_ligation_distance = 1

local carbon_waves = {
    { 0 },
    { 90, -90 },
    { 90, 0, 90 }
}

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

    if x > max_x then
        max_x = x
    end
    if y > max_y then
        max_y = y
    end
    if x < min_x then
        min_x = x
    end
    if y < min_y then
        min_y = y
    end

	::continue::
end

local cwidth = max_x + -min_x
local cheight = max_y + -min_y

local width = BORDER * 2 + cwidth
local height = BORDER * 2 + cheight

local center_x = BORDER + math.abs(min_x)
local center_y = BORDER + math.abs(min_y)

local svg = Svg:new{}

for idx, atom in ipairs(atoms) do
    local symbol = atom["symbol"]
    local charge = atom["charge"]
    local x = center_x + atom["x"]
    local y = center_y + atom["y"]

    if charge ~= 0 then
        if charge == 1 then
            charge = "+"
        end
        if charge == -1 then
            charge = "-"
        end
        svg:subtext(charge, x + ATOM_RADIUS, y - ATOM_RADIUS)
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

    svg:text(atom["symbol"], x, y)

    ::continue::
end

for _, ligation in ipairs(ligations) do
    local from_atom = atoms[ligation["atoms"][1]]
    local to_atom = atoms[ligation["atoms"][2]]

    if to_atom["symbol"] == "H" and to_atom["charge"] == 0 and from_atom["symbol"] == "C" then
        goto continue
    end

    local ax = center_x + from_atom["x"]
    local ay = center_y + from_atom["y"]
    local bx = center_x + to_atom["x"]
    local by = center_y + to_atom["y"]

    local angles = waves[ ligation["eletrons"] ]

    local a_angle = math.atan((by - ay), (bx - ax))
    local b_angle = math.pi + a_angle

    if ligation["eletrons_behaviour"] ~= "i" then
        for idx, angle in ipairs(angles) do

            local from_ATOM_RADIUS = ATOM_RADIUS
            local a_sum = angle
            if from_atom["symbol"] == "C" then
                from_ATOM_RADIUS = carbon_ligation_distance
                a_sum = carbon_waves[ ligation["eletrons"] ][idx]
            end

            local nax = ax + math.cos(a_angle - (math.pi * a_sum / 180)) * from_ATOM_RADIUS
            local nay = ay + math.sin(a_angle - (math.pi * a_sum / 180)) * from_ATOM_RADIUS

            local to_ATOM_RADIUS = ATOM_RADIUS
            local b_sum = angle
            if to_atom["symbol"] == "C" then
                to_ATOM_RADIUS = carbon_ligation_distance
                b_sum = carbon_waves[ ligation["eletrons"] ][idx]
            end

            local nbx = bx + math.cos(b_angle + (math.pi * b_sum / 180)) * to_ATOM_RADIUS
            local nby = by + math.sin(b_angle + (math.pi * b_sum / 180)) * to_ATOM_RADIUS

            svg:line(nax, nay, nbx, nby)
        end
    end

    ::continue::
end

local svg_content = svg:build(width, height)
print(svg_content)