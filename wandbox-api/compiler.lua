local hder = require 'http.headers'
local hreq = require 'http.request'
local json = require 'cjson'

local upref = 'https://wandbox.org/api'

local h_POST = hder.new()
h_POST:upsert(':method','POST')

local c = function(lang)
	local _,stm = hreq.new_from_uri(upref..'/list.json'):go()
	local body = stm:get_body_as_string()
	
	local list = {}
	local dList = json.decode(body)

	if lang then
		for _,cmp in pairs(dList) do
			if cmp.language:lower() == lang:lower() then
				table.insert(list, cmp)
			end
		end

		if #list <= 0 then
			return nil,'No matching compiler found for language: '..lang
		else
			return list
		end
	else
		return dList
	end
end

return c
