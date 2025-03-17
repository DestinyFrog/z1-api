local min_x = 0
local min_y = 0
local max_x = 0
local max_y = 0

local eletrons_radius = 1
local distance_between_eletrons = 20
local lewis_atom_radius = 9

local lewis_waves = {
    { 0 },
    { distance_between_eletrons/2, - distance_between_eletrons/2 },
    { distance_between_eletrons, 0, -distance_between_eletrons }
}

for _, atom in ipairs(atoms) do
    local x = atom["x"]
    local y = atom["y"]

	if atom["symbol"] == "X" then goto continue end

    if x > max_x then max_x = x end
    if y > max_y then max_y = y end
    if x < min_x then min_x = x end
    if y < min_y then min_y = y end

	::continue::
end

local cwidth = max_x + -min_x
local cheight = max_y + -min_y

local width = BORDER * 2 + cwidth
local height = BORDER * 2 + cheight

local center_x = BORDER + math.abs(min_x)
local center_y = BORDER + math.abs(min_y)

local svg = Svg:new{}

for _, atom in ipairs(atoms) do
    local symbol = atom["symbol"]
    local x = center_x + atom["x"]
    local y = center_y + atom["y"]

	if symbol == "X" then goto continue end

    svg:text(atom["symbol"], x, y)

    local charge = atom["charge"]

    if charge ~= 0 then
        if charge == 1 then charge = "+" end
        if charge == -1 then charge = "-" end
        svg:subtext(charge, x + lewis_atom_radius, y - lewis_atom_radius)
    end

	::continue::
end

for _, ligation in ipairs(ligations) do
    local from_atom = atoms[ligation["atoms"][1]]
    local to_atom = atoms[ligation["atoms"][2]]

    local ax = center_x + from_atom["x"]
    local ay = center_y + from_atom["y"]
    local bx = center_x + to_atom["x"]
    local by = center_y + to_atom["y"]

    local angles = lewis_waves[ ligation["eletrons"] ]

    local a_angle = math.atan((by - ay), (bx - ax))
    local b_angle = math.pi + a_angle

    if ligation["eletrons_behaviour"] ~= "i" then
        for _, angle in ipairs(angles) do
			local nax = ax + math.cos(a_angle - (math.pi * angle / 180)) * lewis_atom_radius
			local nay = ay + math.sin(a_angle - (math.pi * angle / 180)) * lewis_atom_radius
			svg:circle(nax, nay, eletrons_radius)

			if to_atom["symbol"] ~= "X" then
        	    local nbx = bx + math.cos(b_angle + (math.pi * angle / 180)) * lewis_atom_radius
    	        local nby = by + math.sin(b_angle + (math.pi * angle / 180)) * lewis_atom_radius
    	        svg:circle(nbx, nby, eletrons_radius)
			end
        end
    end

	::continue::
end

local svg_content = svg:build(width, height)
print(svg_content)