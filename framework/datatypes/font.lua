
local fontDirectory = "framework/fonts/"

local font = {}

local history = {}

function font.new(filename, size, ignoreSave)
	assert(love.filesystem.getInfo(fontDirectory .. filename), "Text object failed to load font at path '" .. fontDirectory .. filename .. "': Not a file")
	if history[filename] ~= nil and history[filename][size] ~= nil then
		return history[filename][size]
	else
		local f = love.graphics.newFont(fontDirectory .. filename, size)
		if not ignoreSave then
			if history[filename] == nil then
				history[filename] = {}
			end
			if history[filename][size] == nil then
				history[filename][size] = f
			end
		end
		return f
	end
end

return font
