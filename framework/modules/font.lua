
local fontDirectory = "framework/fonts/"

local font = {}

local cache = {}
--local semaphores = {}

font.Cache = cache
--font.semaphores = semaphores

function font.new(filename, size) -- isTemporary is only used once: when trying to auto-fit fonts (in which case many temporary fonts are created). So a font never exists that is undocumented
	assert(love.filesystem.getInfo(fontDirectory .. filename), "Text object failed to load font at path '" .. fontDirectory .. filename .. "': Not a file")
	if cache[filename] ~= nil and cache[filename][size] ~= nil then
		--semaphores[filename][size] = semaphores[filename][size] + 1
		return cache[filename][size]
	else
		local f = love.graphics.newFont(fontDirectory .. filename, size)
		if cache[filename] == nil then
			cache[filename] = {}
			--semaphores[filename] = {}
		end
		cache[filename][size] = f
		return f
	end
end

-- dereference is removed in favor of simply having a 'least recently used' algorithm for caching fonts
--[[
function font:dereference(filename, size)
	assert(semaphores[filename] ~= nil and semaphores[filename][size] ~= nil, "semaphore for " .. filename .. " at size " .. tostring(size) .. " does not exist")
	semaphores[filename][size] = semaphores[filename][size] - 1
	if semaphores[filename][size] == 0 then -- given filename + size combo is no longer in use, so remove it!
		cache[filename][size]:release() -- immediately destroys the object's Lua reference
		cache[filename][size] = nil
		semaphores[filename][size] = nil
		if next(cache[filename]) == nil then -- dictionary contains no more keys (text sizes) for the given font name
			cache[filename] = nil
			semaphores[filename] = nil
		end
	end
end
]]


function font:getSupportedFonts()
	local list = {}
	local items = love.filesystem.getDirectoryItems(fontDirectory)
	for i = 1, #items do
		if items[i]:sub(-3) ~= "txt" then
			list[#list + 1] = items[i]
		end
	end
	return list
end


-- very important! If you clear a font while it's being used in UI, new fonts will be created during the new text draw call
function font:clearCache(fontName)
	if fontName == nil then
		for name, sizeArray in pairs(cache) do
			for size, f in pairs(sizeArray) do
				sizeArray[size]:release()
			end
		end
		cache = {}
	else
		for size, f in pairs(cache[fontName]) do
			cache[fontName][size]:release()
		end
		cache[fontName] = {}
	end
end



return font
