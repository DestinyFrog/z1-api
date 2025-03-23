require "z1.tools.svg"
require "z1.sectioner"
local sqlite3 = require "lsqlite3"

local uid = arg[2]
local db = sqlite3.open("z1.sqlite3")



local stmt = assert( db:prepare("SELECT z1 FROM molecula WHERE uid = ?") )
stmt:bind_values(uid)
stmt:step()
local content = stmt:get_uvalues()
stmt:finalize()

local hadled_sections, err = HandleSections(content)
if err ~= nil then
	err:print()
	os.exit(1)
end

tags, ligations, atoms = table.unpack(hadled_sections)

local already = {}

local function calc_atoms_position(idx, dad_atom, ligation)
	for k, v in ipairs(already) do
		if idx == v then
			return
		end
	end

	local x = 0
	local y = 0

	if dad_atom ~= nil then
		local angle = ligation["angle"]
		local angle_rad = math.pi * angle / 180
		x = dad_atom["x"] + math.cos(angle_rad) * LIGATION_SIZE
		y = dad_atom["y"] + math.sin(angle_rad) * LIGATION_SIZE
	end

	atoms[idx]["x"] = x
	atoms[idx]["y"] = y
	table.insert(already, idx)

	for _, lig in ipairs(ligations) do
		if lig["atoms"][1] == idx then
			calc_atoms_position(lig["atoms"][2], atoms[idx], lig)
		end
	end
end

calc_atoms_position(1)

local export_type = arg[1]
require("z1.plugins." .. export_type)

print(svg_content)