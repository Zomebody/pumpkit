
------------------------[[ = VARIABLES = ]]------------------------

local output = ""



------------------------[[ = FUNCTIONS = ]]------------------------

function hasKeys(Tab)
	for k, v in pairs(Tab) do
		if type(k) ~= "number" then
			return true
		end
	end
	return false
end

function isShallowArray(Arr)
	local i = 0
	for _ in pairs(Arr) do
		i = i + 1
		while Arr[i] == nil do
			i = i + 1
		end
		if type(Arr[i]) == "table" then return false end
	end
	return true
end

function arrayToString(Arr)
	local str = ""
	local i = 0
	for _ in pairs(Arr) do
		i = i + 1
		while Arr[i] == nil do
			i = i + 1
			str = str .. "nil, "
		end
		if type(Arr[i]) ~= "string" then
			str = str .. tostring(Arr[i]) .. ", "
		else
			str = str .. "\"" .. tostring(Arr[i]) .. "\", "
		end
	end
	return string.sub(str, 1, string.len(str) - 2)
end



------------------------[[ = MAIN FUNCTIONS = ]]------------------------

function buildString(Item, key, depth)
	depth = depth == nil and 0 or depth
	key = key == nil and "undefined" or key
	if depth ~= 0 and type(Item) ~= "function" then
		if type(key) == "string" then
			key = "[\"" .. key .. "\"]"
		elseif type(key) == "number" or type(key) == "boolean" or type(key) == "table" then
			key = "[" .. tostring(key) .. "]"
		end
	end
	local depthString = string.rep("    ", depth)
	if type(Item) == "table" then
		if hasKeys(Item) then -- dictionary
			output = output .. depthString .. key .. " = {" .. "\n"
			for k, v in pairs(Item) do
				buildString(v, k, depth + 1)
			end
			output = output .. depthString .. "}" .. ";\n"
		elseif isShallowArray(Item) then
			output = output .. depthString .. key .. " = {" .. arrayToString(Item, false) .. "}" .. ";\n"
		else -- table of objects
			output = output .. depthString .. key .. " = {" .. "\n"
			for k, v in pairs(Item) do
				BuildString(v, k, depth + 1)
			end
			output = output .. depthString .. "}" .. ";\n"
		end
	elseif type(Item) == "function" then
		output = output .. depthString .. "> function " .. key .. "(...)" .. ";\n"
	elseif type(Item) == "string" then
		output = output .. depthString .. key .. " = \"" .. tostring(Item) .. "\"" .. ";\n"
	else
		output = output .. depthString .. key .. " = " .. tostring(Item) .. ";\n"
	end
end


function printTable(Item, key)
	buildString(Item, key)
	local res = output
	output = ""
	return res
end


return printTable

