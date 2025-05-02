
----------------------------------------------------[[ == IMPORTS == ]]----------------------------------------------------
--[[
local fontDirectory = "framework/fonts/"
local font = require(filepath(..., "font"))
local color = require(filepath(..., "../datatypes/color"))
]]


----------------------------------------------------[[ == MODULE == ]]----------------------------------------------------

local module = {}
local textblock = {}
textblock.__index = textblock

local function isText(t)
	return getmetatable(t) == textblock
end

local function new(parent, fontname, size, textData, lineCount)
	if size == nil then size = 12 end
	local w = parent.AbsoluteSize.x - parent.Padding.x * 2
	local raw = ""
	if type(textData) == "string" then
		raw = textData
	else
		for i = 2, #textData, 2 do
			raw = raw .. textData[i]
		end
	end
	local Obj = {
		["Parent"] = parent;
		["AlignmentX"] = "left";
		["AlignmentY"] = "top";
		["Color"] = color(1, 1, 1);
		["ColoredText"] = textData;
		["Font"] = nil;
		["FontFile"] = fontname;
		["FontSize"] = size;
		["RawText"] = raw or "";
		["Text"] = love.graphics.newText(font.new(fontname, size));
		["Width"] = w; -- the *actual* width of the text is different if WrapEnabled is false, but this will keep the 'other' width in case you set WrapEnabled back to true
		--["WrapEnabled"] = true; -- if text should wrap or stay on one line (replaced with MaxLines)
		["TextScales"] = size == nil;
		["MaxLines"] = lineCount; -- if 0, there is no maximum. Otherwise, this defines the maximum number of lines that will fit in the box when automatic text scaling is enabled

		["FontHeight"] = 0;
		["Events"] = {}; -- "FontHeightChanged"
	}
	Obj.Font = Obj.Text:getFont()
	Obj.Text:setf(textData, w, "left")
	local height = Obj.Font:getHeight()
	Obj.FontHeight = height
	--if w == math.huge then
	--	Obj.Width = Obj.Text:getWidth()
	--end
	setmetatable(Obj, textblock)
	return Obj
end


-- "left", "right", "center", "justify"
function textblock:alignX(side)
	assert(side == "left" or side == "center" or side == "right" or side == "justify", "Method textblock:alignX(side) expects argument 'side' to be one of ('left', 'center', 'right', 'justify')")
	self.AlignmentX = side
	--self.Text:setf(self.ColoredText, self.Width, side)
	--if self.WrapEnabled then
	--	self.Text:setf(self.ColoredText, self.Width, side)
	--else
	--self.Text:set(self.ColoredText)
	--local maxWidth = self.Text:getWidth()
	self.Text:setf(self.ColoredText, self.Parent.AbsoluteSize.x - self.Parent.Padding.x * 2, side)
	--end
end

-- "bottom" / "center" / "top"
function textblock:alignY(side)
	assert(side == "bottom" or side == "center" or side == "top", "Method textblock:alignY(side) expects argument 'side' to be one of ('bottom', 'center', 'top')")
	self.AlignmentY = side
end


function textblock:getSize()
	return self.Text:getDimensions()
end


-- replace the textblock data with new textData
function textblock:setText(textData)
	local oldRaw = self.RawText
	local raw = ""
	if type(textData) == "string" then
		raw = textData
	else
		for i = 2, #textData, 2 do
			raw = raw .. textData[i]
		end
	end
	self.RawText = raw or "";
	self.ColoredText = textData
	--self.Text:setf(self.ColoredText, self.Width, self.AlignmentX)
	--if self.WrapEnabled then
	--	self.Text:setf(self.ColoredText, self.Width, self.AlignmentX)
	--else
	--self.Text:set(self.ColoredText)
	--local maxWidth = self.Text:getWidth()
	self.Text:setf(self.ColoredText, self.Parent.AbsoluteSize.x - self.Parent.Padding.x * 2, self.AlignmentX)
	if self.TextScales then -- calling fitText will also call FontHeightChanged, which is why there's an if-else here to avoid duplicate work
		-- if the number of lines of text is set, its size won't change, so no need to re-fit the text!
		if self.MaxLines == 0 then
			self:fitText()
		end
	else
		local newHeight = self.Font:getHeight()
		if newHeight ~= self.FontHeight then
			self.FontHeight = newHeight
			if self.Events["FontHeightChanged"] ~= nil then
				connection.doEvents(self.Events.FontHeightChanged, newHeight)
			end
		end
	end

	if raw ~= oldRaw and self.Events["TextChanged"] ~= nil then
		connection.doEvents(self.Events.TextChanged, raw)
	end
	
	--end
end

-- returns the raw or colored text of the textblock
function textblock:getText(isColored)
	if isColored then
		return self.ColoredText
	else
		return self.RawText
	end
end



-- fitText won't try *every* font size since that would be overkill (and be bad for memory usage when using large fonts)
-- so instead it skips over certain font sizes, especially at larger sizes since the different between 99 and 100 isn't noticible
local SIZES = {
	1,  2,  3,  4,  5,  6,  7,  8,  9,  10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
	21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50,
	52, 54, 56, 58, 60, 63, 66, 69, 72, 75, 78, 81, 84, 87, 90, 95, 100, 105, 110, 120,
	130, 140, 160, 180
}

-- resize the text to fit within the given width and height
function textblock:fitText(remainScaled)
	local w = self.Width
	local h = self.Parent.AbsoluteSize.y - self.Parent.Padding.y * 2
	self:clearFont()
	self.Text:setf(self.ColoredText, w, self.AlignmentX)

	local ceil = math.huge -- upper bound: text of that size does not fit
	local floor = 0 -- lower bound: text of that size fits
	local curTry = 16 -- tweak this number to optimize the number of iterations. Must be power of 2!
	local lastFit = nil -- the last size that did fit in the box
	local doesFit = false

	repeat
		local createdFont = font.new(self.FontFile, SIZES[curTry])
		self.Text:setFont(createdFont)

		-- check if the current size fits
		if self.MaxLines == 0 then -- check for when you just want to fit the whole text in the box
			local newWidth, wrappedText = createdFont:getWrap(self.RawText, w)
			local newHeight = createdFont:getHeight() * #wrappedText
			doesFit = (newHeight <= h)
		else -- check for if you can fit exactly that number of lines in the given height
			local fontHeight = createdFont:getHeight() -- height of the font in pixels
			doesFit = (fontHeight <= math.floor(h / self.MaxLines))
		end

		if doesFit then
			lastFit = SIZES[curTry]
			floor = curTry
			if ceil == math.huge and curTry * 2 <= #SIZES then
				curTry = curTry * 2
			else
				curTry = (curTry + ceil) / 2
			end
		else
			ceil = curTry
			curTry = (curTry + floor) / 2
		end
	until SIZES[curTry] == nil -- make sure you don't jump out of the array or index something like 2.5 or whatever
	

	if remainScaled ~= nil then
		self.TextScales = (remainScaled == true)
	end

	if lastFit == nil then
		lastFit = 1 -- fallback in case your frame has size 0 and thus no text ever fits
	end
	
	self.FontSize = lastFit
	self.Font = font.new(self.FontFile, lastFit)
	self.Text:setFont(self.Font)

	local newHeight = self.Font:getHeight()
	if newHeight ~= self.FontHeight then
		self.FontHeight = newHeight
		if self.Events["FontHeightChanged"] ~= nil then
			connection.doEvents(self.Events.FontHeightChanged, newHeight)
		end
	end

	return lastFit
end



-- enables text scaling and refits the text to fit the given line count
function textblock:setMaxLines(count)
	assert(type(count) == "number" or type(count) == "nil", "textblock:setMaxLines(count) requires argument 'count' to be a number or nil.")
	if count == nil then
		count = 0
	end

	self.MaxLines = count
	self.TextScales = true
	self:fitText()
end



-- change the font to one from the fonts directory, CAN BE SLOW IF CALLED EVERY FRAME!
function textblock:setFont(name)
	--if love.filesystem.getInfo(fontDirectory .. name) then
	self:clearFont()
	self.FontFile = name
	self.Font = font.new(name, self.FontSize)--love.graphics.newFont(fontDirectory .. name, self.FontSize)
	self.Text:setFont(self.Font)

	if self.TextScales then -- calling fitText will also call FontHeightChanged, which is why there's an if-else here to avoid duplicate work
		self:fitText()
	else
		local newHeight = self.Font:getHeight()
		if newHeight ~= self.FontHeight then
			self.FontHeight = newHeight
			if self.Events["FontHeightChanged"] ~= nil then
				connection.doEvents(self.Events.FontHeightChanged, newHeight)
			end

		end
	end

	
end


-- set a new size for the text and recreate the font using the new size, CAN BE SLOW IF CALLED EVERY FRAME!
function textblock:setTextSize(size)
	size = math.floor(size + 0.5)
	if self.FontSize ~= size then
		self:clearFont()
		self.FontSize = size
		self.Font = font.new(self.FontFile, self.FontSize)--love.graphics.newFont(fontDirectory .. self.FontFile, self.FontSize)
		self.Text:setFont(self.Font)

		local newHeight = self.Font:getHeight()
		if newHeight ~= self.FontHeight then
			self.FontHeight = newHeight
			if self.Events["FontHeightChanged"] ~= nil then
				connection.doEvents(self.Events.FontHeightChanged, newHeight)
			end
		end
	end
	self.TextScales = false -- by setting a size explicitly, you disable automatic text scaling
end


-- set a new maximum width for the textblock
-- should only be called internally
function textblock:updateWidth()
	self.Width = self.Parent.AbsoluteSize.x - self.Parent.Padding.x * 2
	if self.TextScales then
		self:fitText()
	else
		self.Text:setf(self.ColoredText, self.Width, self.AlignmentX)
	end
end



-- called when the object that uses the textblock is being removed
function textblock:clearFont()
	self.Font = nil
	--font:dereference(self.FontFile, self.FontSize) -- no longer exists
end



-- eventName is the name of the event to call. All event name strings are accepted, but not all of them may trigger
-- func is the function to link
function textblock:on(eventName, func)
	if self.Events[eventName] == nil then
		self.Events[eventName] = {}
	end
	local index = #self.Events[eventName] + 1
	local Conn = connection.new(self, eventName)
	self.Events[eventName][index] = {func, Conn}
	return Conn
end



----------------------------------------------------[[ == RETURN == ]]----------------------------------------------------

module.isText = isText
module.new = new

return setmetatable(module, {__call = function(_, ...) return new(...) end})

