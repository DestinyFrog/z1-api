local sqlite3 = require "lsqlite3"
local uuid = require "uuid"

uuid.set_rng(uuid.rng.urandom())

local db = sqlite3.open("z1.sqlite3")

names = {}

local comando = string.format('ls "%s"', "./z1/examples")
local handle = io.popen(comando)
if handle then
	for nomeArquivo in handle:lines() do
		table.insert(names, nomeArquivo)
	end
	handle:close()
else
	print("Erro ao acessar a pasta.")
end

print("INSERT INTO molecula (uid, name, z1, organic, term) VALUES ")

for k, name in ipairs(names) do
	local file = io.open("./z1/examples/".. name, "r")
	if file == nil then
		print(name.." not found")
		os.exit(0)
	end
	local content = file:read("*a")
	file:close()

	-- NAME
	local rname = name:gsub(".z1", "")

	-- TERM
	local terms = {}

	local params = {}
	for param in content:gmatch("[^$]+") do
		table.insert(params, param)
	end
	local section = params[2]
	for line in section:gmatch("[^\n]+") do
		local s = {}
		for l in line:gmatch("[^%s]+") do
			table.insert(s, l)
		end

		if s[1] ~= 'X' then
			table.insert(terms, s[1])
		end
	end

	-- ORGANIC
	local organic = 'organic'
	if string.find(params[1], "inorganic") then
		organic = 'inorganic'
	end

	table.sort(terms, function(a, b) return a:upper() < b:upper() end)
	local term = table.concat(terms, "")
	
	local stmt = assert( db:prepare("INSERT INTO molecula (uid, name, z1, organic, term) VALUES (:uid, :name, :z1, :organic, :term)") )
	stmt:bind_names {
		uid = uuid.v4(),
		name = rname,
		z1 = content,
		organic = organic,
		term = term
	}

	stmt:step()
	stmt:reset()

	print("INSERT: "..name)
end