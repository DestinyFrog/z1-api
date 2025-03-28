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

for k, name in ipairs(names) do
	local stmt = assert( db:prepare("INSERT INTO molecula (uid, name, z1, organic) VALUES (:uid, :name, :z1, :organic)") )

	local file = io.open("./z1/examples/".. name, "r")
	if file == nil then
		print(name.." not found")
		os.exit(0)
	end
	local content = file:read("*a")

	local tags = file:read()
	local organic = tags

	file:close()

	local rname = name:gsub(".z1", "")

	stmt:bind_names {
		uid = uuid.v4(),
		name = rname,
		z1 = content,
		organic = organic,
	}

	stmt:step()
	stmt:reset()

	print("INSERT: "..name)
end