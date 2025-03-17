require "svg"
local sqlite3 = require "lsqlite3"

BORDER = 12
LIGATION_SIZE = 26
ATOM_RADIUS = 7
distance_between_ligations = 20

waves = {
	{ 0 },
	{ distance_between_ligations / 2, -distance_between_ligations / 2 },
	{ distance_between_ligations, 0, -distance_between_ligations }
}

local eletrons_type = {
	["-"] = 1,
	["="] = 2,
	["%"] = 3
}

function handle_err(err, status_code)
	if status_code == nil then
		status_code = 404
	end

	io.output(io.stderr)
	io.write(status_code.."|"..err)
	os.exit(1)
end

local uid = arg[2]
local db = sqlite3.open("z1.sqlite3")
local stmt = assert( db:prepare("SELECT z1 FROM molecula WHERE uid = ?") )
stmt:bind_values(uid)
stmt:step()
local content = stmt:get_uvalues()
stmt:finalize()

local sections = {}
for s in content:gmatch("[^$]+") do
	table.insert(sections, s)
end

local section_tags = sections[1]
local section_atms = sections[2]
local section_ligs = sections[3]

local function handle_section_tags(section)
	local tags = {}
	for line in section_tags:gmatch("[^%s]+") do
		table.insert(tags, line)
	end
	return tags
end

function handle_pattern(pattern, repet)
	local pattern_file = io.open("./pattern/" .. pattern .. ".pre.z1", "r")
	if pattern_file == nil then
		return handle_err("Pattern '" .. pattern .. "' not found")
	end

	local pattern_content = pattern_file:read("*a")
	pattern_file:close()

	if repet == nil then repet = 1 end

	local pattern_ligs = {}
	for i = 1, repet do
		local pat = handle_section_ligations(pattern_content)
		for _, l in ipairs(pat) do
			table.insert(pattern_ligs, l)
		end
	end
	return pattern_ligs
end

function handle_ligation(params)
	local ligations = {}

	local angle = tonumber(params[1])

	if angle == nil then
		local pattern = params[1]

		local pattern_ligations = handle_pattern(pattern, tonumber(params[2]))
		for _, pattern_ligation in ipairs(pattern_ligations) do
			table.insert(ligations, pattern_ligation)
		end
	else
		local eletrons = eletrons_type[params[2]]
		local eletrons_behaviour = params[3]

		if eletrons == nil then
			eletrons = 1
			eletrons_behaviour = params[2]
		end

		local ligation = {
			angle = angle,
			eletrons = eletrons,
			eletrons_behaviour = eletrons_behaviour
		}

		table.insert(ligations, ligation)
	end

	return ligations
end

function handle_section_ligations(section)
	local ligations = {}
	for line in section:gmatch("[^\n]+") do
		local params = {}
		for param in line:gmatch("[^%s]+") do
			table.insert(params, param)
		end

		local ligs = handle_ligation(params)
		for _, lig in ipairs(ligs) do
			table.insert(ligations, lig)
		end
	end
	return ligations
end

tags = handle_section_tags(section_tags)
ligations = handle_section_ligations(section_ligs)

local function handle_section_atoms(section)
	local atoms = {}
	for line in section_atms:gmatch("[^\n]+") do
		local params = {}
		for param in line:gmatch("[^%s]+") do
			table.insert(params, param)
		end

		local symbol = params[1]
		if symbol:match("[A-Z][a-z]?") == nil then
			handle_err("symbol '" .. params[1] .. "' invalid")
		end

		local start_ligation_index = 1
		local charge = 0
		if params[2]:match("[-|+][0-9]") ~= nil then
			start_ligation_index = 2
			local charge = tonumber(params[2])
			if charge == nil then
				handle_err("charge '" .. charge .. "' invalid")
			end
		end

		local ligs = {}
		for k, v in ipairs(params) do
			if k > start_ligation_index then
				local lig = tonumber(v)
				if lig == nil then
					handle_err("ligation '" .. lig .. "' invalid")
				end

				if ligations[lig]["atoms"] == nil then
					ligations[lig]["atoms"] = { #atoms + 1 }
				else
					table.insert(ligations[lig]["atoms"], #atoms + 1)
				end

				table.insert(ligs, lig)
			end
		end

		local atom = {
			symbol = symbol,
			charge = charge,
			ligations = ligs
		}
		table.insert(atoms, atom)
	end
	return atoms
end

atoms = handle_section_atoms(section_atms)

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
require("plugins/" .. export_type .. ".lua")