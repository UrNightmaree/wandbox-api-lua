local hreq = require 'http.request'
local hder = require 'http.headers'
local json = require 'dkjson'

local I = require 'inspect'

local m_POST = hder.new()
m_POST:upsert(':method','POST')

local upref = 'https://wandbox.org/api'

local function compileString(opts)
	if not opts.code then
		return nil,'No source found, "opts.code" is empty!'
	end

	local list = require 'compiler'()
	
	local found = false
	for _,cmp in pairs(list) do
		print(cmp.name)
		if cmp.name:lower() == opts.compiler:lower() then
			found = true; break
		end
	end

	if not found then
		return nil,'Invalid compiler passed in "opts.compiler"'
	else
		local postd = json.encode(opts)

		local uri = hreq.new_from_uri(upref..'/compile.json',m_POST)
		uri.headers:upsert('content-type','application/json')
		uri.headers:upsert('content-length',#postd)
		uri:set_body(json.encode(opts))
		
		local start = os.time()
		if opts.timeout and (os.time() - start) > opts.timeout then
			return nil,'Request timed out'
		end

		local _,stm = uri:go()
		local data = stm:get_body_as_string()

		return json.decode(data)
	end
end

return compileString
