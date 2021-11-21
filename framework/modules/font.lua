
local fontDirectory = "framework/fonts/"

local font = {}

local history = {}
local semaphores = {}

font.history = history
font.semaphores = semaphores

function font.new(filename, size, isTemporary) -- isTemporary is only used once: when trying to auto-fit fonts (in which case many temporary fonts are created). So a font never exists that is undocumented
	assert(love.filesystem.getInfo(fontDirectory .. filename), "Text object failed to load font at path '" .. fontDirectory .. filename .. "': Not a file")
	if not isTemporary and history[filename] ~= nil and history[filename][size] ~= nil then
		semaphores[filename][size] = semaphores[filename][size] + 1
		return history[filename][size]
	else
		local f = love.graphics.newFont(fontDirectory .. filename, size)
		if not isTemporary then
			if history[filename] == nil then
				history[filename] = {}
				semaphores[filename] = {}
			end
			if history[filename][size] == nil then
				history[filename][size] = f
				semaphores[filename][size] = 1
			end
		end
		return f
	end
end

-- TODO: DOCUMENT THIS METHOD
function font:dereference(filename, size)
	assert(semaphores[filename] ~= nil and semaphores[filename][size] ~= nil, "semaphore for " .. filename .. " at size " .. tostring(size) .. " does not exist")
	semaphores[filename][size] = semaphores[filename][size] - 1
	if semaphores[filename][size] == 0 then -- given filename + size combo is no longer in use, so remove it!
		history[filename][size]:release() -- immediately destroys the object's Lua reference
		history[filename][size] = nil
		semaphores[filename][size] = nil
		if next(history[filename]) == nil then -- dictionary contains no more keys (text sizes) for the given font name
			history[filename] = nil
			semaphores[filename] = nil
		end
	end
end



return font
