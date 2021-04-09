--[[
	TODO:
	- document OnDrag(x, y, button, dx, dy), OnDragEnd(dx, dy), OnNestedDrag(x, y, button, dx, dy), OnNestedDragEnd(dx, dy), :isDescendantOf(Obj), ui.DragActive, ui.DragStart, ui.DragTarget, ui.PressedButton

	TODO object types:
	- StateButton (button which, when clicked, proceeds to the next state, and can wrap back to the initial state)
	- ScrollableFrame (frame that changes ContentOffset when you scroll up/down while over the frame)
	- Slider (frame with another frame inside that can be dragged)

	TODO (other file):
	- animation(img, framewidth, fduration)
	- Animation.Width
	- Animation.Height
	- Animation.FrameDuration
	- Animation.StartTime
	- Animation:start()
	- Animation:pause()
	- Animation:stop()
	- Animation:getFrame()
	- Animation:changeFrameDuration()
]]
----------------------------------------------------[[ == IMPORTS == ]]----------------------------------------------------

local vector = require("framework.datatypes.vector")
local color = require("framework.datatypes.color")
local textblock = require("framework.datatypes.textblock")



----------------------------------------------------[[ == BASE OBJECTS == ]]----------------------------------------------------

local module = {
	["MouseFocus"] = nil; -- current element the mouse is hovering over
	-- TODO: replace PressedElement with an 'ActivePresses' table, where each index corresponds to a mouse button and the value is a reference to the element being held down.
	["PressedElement"] = nil; -- the element that is currently being pressed / held down
	["PressedButton"] = nil;
	["DragActive"] = false; -- whether or not DragTarget is experiencing a drag
	["DragStart"] = vector();
	["DragTarget"] = nil; -- the element that is currently being dragged
	--["NestedDragTargets"] = {}; -- an array of elements that are experiencing a drag event. The first index is a regular OnDrag, all other elements are OnNestedDrag elements
	--["ActiveInputId"] = nil; -- id of the 'thing' that is pressing, so 1 = left mouse, 2 = right mouse, light userdata = touch, 'A' would be gamepad A
	["TotalCreated"] = 0; -- total number of UI elements that have been created
	["Changed"] = false; -- internal boolean to determine at the end of each frame if some element was added, removed, hidden, unhidden or changed position or size, so MouseFocus can be updated

	["Children"] = {};
	["Size"] = vector(love.graphics.getDimensions()); -- TODO: use getSafeArea() to ignore the mobile inset
}

local UIBase = {}
UIBase.__index = UIBase

local Frame = setmetatable({}, UIBase)
Frame.__index = Frame

local ImageFrame = setmetatable({}, UIBase)
ImageFrame.__index = ImageFrame

local SlicedFrame = setmetatable({}, UIBase)
SlicedFrame.__index = SlicedFrame



----------------------------------------------------[[ == HELPER FUNCTIONS == ]]----------------------------------------------------

local function updateAbsolutePosition(Obj, wX, wY, wWidth, wHeight)
	-- set value depending on if this is a top-level element, or if there is a parent
	if Obj.Parent ~= nil and Obj.Parent ~= module then
		wX = (wX == nil and Obj.Parent.AbsolutePosition.x or wX) + Obj.Parent.PaddingX
		wY = (wY == nil and Obj.Parent.AbsolutePosition.y or wY) + Obj.Parent.PaddingY
		wWidth = (wWidth == nil and Obj.Parent.Size.x or wWidth) - 2 * Obj.Parent.PaddingX
		wHeight = (wHeight == nil and Obj.Parent.Size.y or wHeight) - 2 * Obj.Parent.PaddingY
	else
		wX = wX == nil and 0 or wX
		wY = wY == nil and 0 or wY
		wWidth = wWidth == nil and module.Size.x or wWidth
		wHeight = wHeight == nil and module.Size.y or wHeight
	end

	-- apply content offset from all ancestors
	local contentOffsetX = 0
	local contentOffsetY = 0
	if Obj.Parent ~= nil and Obj.Parent ~= module then
		contentOffsetX = Obj.Parent.ContentOffset.x
		contentOffsetY = Obj.Parent.ContentOffset.y
	end

	-- calculate and apply absolute position. Then update children
	local absX = wX + contentOffsetX + Obj.Position.Offset.x + math.floor(Obj.Position.Scale.x * wWidth) - math.floor(Obj.Size.x * Obj.Center.x)
	local absY = wY + contentOffsetY + Obj.Position.Offset.y + math.floor(Obj.Position.Scale.y * wHeight) - math.floor(Obj.Size.y * Obj.Center.y)
	Obj.AbsolutePosition:set(absX, absY)
	for i = 1, #Obj.Children do
		updateAbsolutePosition(Obj.Children[i], absX, absY, Obj.Size.x, Obj.Size.y)
	end
end



----------------------------------------------------[[ == MODULE INITIALIZATION == ]]----------------------------------------------------

-- connects love2d events to UI element events
function module:initialize()
	if not module.Initialized then
		module.Initialized = true
	else
		return
	end

	-- Monkey Patching love.mousemoved (at start)
	local mousemoved = love.mousemoved or function() end -- define new mousemoved function if it doesn't exist yet
	love.mousemoved = function(x, y, dx, dy, istouch)
		local oldFocus = self.MouseFocus
		self.MouseFocus = self:at(x, y)

		-- find and trigger hover events if focus changed
		if oldFocus ~= self.MouseFocus then -- focus changed, check for new focus
			if oldFocus ~= nil then
				self.PressedElement = nil
				if oldFocus.OnHoverEnd ~= nil then
					oldFocus.OnHoverEnd()
				end
			end
			if self.MouseFocus ~= nil and self.MouseFocus.OnHoverStart ~= nil then
				self.MouseFocus.OnHoverStart()
			end
		end

		-- use delta movement to call (nested) drag events
		if self.DragTarget ~= nil then
			self.DragActive = true
			local Target = self.DragTarget
			if Target.OnDrag ~= nil then
				Target.OnDrag(dx, dy, self.PressedButton, x - self.DragStart.x, y - self.DragStart.y)
			end
			if Target.OnNestedDrag ~= nil then
				Target.OnNestedDrag(dx, dy, self.PressedButton, x - self.DragStart.x, y - self.DragStart.y)
			end
			while Target.Parent ~= nil and Target.Parent ~= module do
				Target = Target.Parent
				if Target.OnNestedDrag ~= nil then
					Target.OnNestedDrag(dx, dy, self.PressedButton, x - self.DragStart.x, y - self.DragStart.y)
				end
			end
		end

		mousemoved(x, y)
	end

	-- Monkey Patching love.update (at end)
	local update = love.update or function() end -- define new update function if it doesn't exist yet
	love.update = function()
		update()
		if self.Changed then
			self.Changed = false
			local oldFocus = self.MouseFocus
			self.MouseFocus = self:at(love.mouse.getPosition())
			if oldFocus ~= self.MouseFocus then
				--self.IsFullPress = false
				if oldFocus ~= nil then
					self.PressedElement = nil
					if oldFocus.OnHoverEnd ~= nil then
						oldFocus.OnHoverEnd()
					end
				end
				if self.MouseFocus ~= nil and self.MouseFocus.OnHoverStart ~= nil then
					self.MouseFocus.OnHoverStart()
				end
			end
		end
	end

	-- Monkey Patching love.resize (at start)
	local resize = love.resize or function() end -- define new resize function if it doesn't exist yet
	love.resize = function(w, h)
		self.Changed = true
		local screenW, screenH = self.Size.x, self.Size.y
		self.Size = vector(love.graphics.getDimensions())
		if self.Size.x ~= screenW or self.Size.y ~= screenH then
			screenW = self.Size.x
			screenH = self.Size.y
			for i = 1, #self.Children do
				updateAbsolutePosition(self.Children[i])
			end
		end
		resize(w, h)
	end

	-- Monkey Patching mouse pressed and mouse released
	local mousepressed = love.mousepressed or function() end
	love.mousepressed = function(x, y, button, istouch, presses)
		mousepressed(x, y, button, istouch, presses)
		
		-- stop current drag
		if self.DragTarget ~= nil then
			local Target = self.DragTarget
			if Target.OnDragEnd ~= nil then
				Target.OnDragEnd(x - self.DragStart.x, y - self.DragStart.y)
			end
			if Target.OnNestedDragEnd ~= nil then
				Target.OnNestedDragEnd(x - self.DragStart.x, y - self.DragStart.y)
			end
			while Target.Parent ~= nil and Target.Parent ~= module do
				Target = Target.Parent
				if Target.OnNestedDragEnd ~= nil then
					Target.OnNestedDragEnd(x - self.DragStart.x, y - self.DragStart.y)
				end
			end
		end

		if self.MouseFocus ~= nil then
			self.PressedElement = self.MouseFocus
			self.PressedButton = button

			self.DragStart:set(x, y)
			self.DragTarget = self.PressedElement

			if self.MouseFocus.OnPressStart ~= nil then
				self.MouseFocus.OnPressStart(x, y, button, istouch, presses)
			end
		end
	end



	local mousereleased = love.mousereleased or function() end
	love.mousereleased = function(x, y, button, istouch, presses)
		mousereleased(x, y, button, istouch, presses)
		if self.MouseFocus ~= nil then
			--local oldPressed = self.PressedElement
			--self.PressedElement = nil
			if self.MouseFocus.OnPressEnd ~= nil then
				self.MouseFocus.OnPressEnd(x, y, button, istouch, presses)
			end
			if self.MouseFocus == self.PressedElement and self.MouseFocus.OnFullPress ~= nil then
				self.MouseFocus.OnFullPress(x, y, button, istouch, presses)
			end
		end

		-- stop current drag
		if self.DragTarget ~= nil then
			local Target = self.DragTarget
			if Target.OnDragEnd ~= nil then
				Target.OnDragEnd(x - self.DragStart.x, y - self.DragStart.y)
			end
			if Target.OnNestedDragEnd ~= nil then
				Target.OnNestedDragEnd(x - self.DragStart.x, y - self.DragStart.y)
			end
			while Target.Parent ~= nil and Target.Parent ~= module do
				Target = Target.Parent
				if Target.OnNestedDragEnd ~= nil then
					Target.OnNestedDragEnd(x - self.DragStart.x, y - self.DragStart.y)
				end
			end
		end

		-- reset values after the fact so they can be used in the press callbacks, e.g. when programming a scrollable frame and you want to know is a FullPress is valid, or part of a drag
		self.PressedButton = nil
		self.PressedElement = nil
		self.DragTarget = nil
		self.DragActive = false
	end

	-- Monkey Patching mouse pressed and mouse released
	--love.touchpressed = function(x, y, button, istouch, presses)
	--
	--end

	-- Monkey patching mousescroll
	local wheelmoved = love.wheelmoved or function() end
	love.wheelmoved = function(x, y)
		wheelmoved(x, y)
		if self.MouseFocus ~= nil then
			if self.MouseFocus.OnScroll ~= nil then
				self.MouseFocus.OnScroll(x, y)
			end
			local Target = self.MouseFocus
			if self.MouseFocus.OnNestedScroll ~= nil then
				self.MouseFocus.OnNestedScroll(x, y)
			end
			while Target.Parent ~= nil and Target.Parent ~= module do
				Target = Target.Parent
				if Target.OnNestedScroll ~= nil then
					Target.OnNestedScroll(x, y)
				end
			end
		end
	end
end


-- add a child to the root UI element
function module:addChild(Obj)
	-- remove old parent of object
	if Obj.Parent ~= nil then
		local Parent = Obj.Parent
		for i = 1, #Parent.Children do
			if Parent.Children[i] == Obj then
				table.remove(Parent.Children, i)
				break
			end
		end
	end
	-- set new parent of object
	Obj.Parent = self
	self.Children[#self.Children + 1] = Obj
	updateAbsolutePosition(Obj)
	self.Changed = true
end

-- draw all UI on screen
function module:render()
	love.graphics.setColor(1, 1, 1, 1)
	for i = 1, #self.Children do
		self.Children[i]:draw()
	end
	love.graphics.setScissor()
	love.graphics.setColor(1, 1, 1, 1)
end

-- returns the UI element being drawn at location (x, y)
function module:at(x, y)
	local Obj = nil
	for i = 1, #self.Children do
		if not self.Children[i].Hidden then
			local Found = self.Children[i]:at(x, y)
			if Found ~= nil then
				Obj = Found
			end
		end
	end
	return Obj
end



----------------------------------------------------[[ == UIBASE METHODS == ]]----------------------------------------------------

-- removes the old parent from Obj and sets its new parent to self.
function UIBase:addChild(Obj)
	-- remove old parent of object
	if Obj.Parent ~= nil then
		local Parent = Obj.Parent
		for i = 1, #Parent.Children do
			if Parent.Children[i] == Obj then
				table.remove(Parent.Children, i)
				break
			end
		end
	end
	-- set new parent of object
	Obj.Parent = self
	self.Children[#self.Children + 1] = Obj
	updateAbsolutePosition(Obj)
	module.Changed = true
end

-- return true if the given Object is an (indirect) parent of the UI element
function UIBase:isDescendantOf(Obj)
	local Target = self
	while Target.Parent ~= nil do
		Target = Target.Parent
		if Target == Obj then
			return true
		end
	end
	return false
end

-- hides the UI element
function UIBase:hide()
	self.Hidden = true
	module.Changed = true
end

-- hides the UI element
function UIBase:show()
	self.Hidden = false
	module.Changed = true
end

-- return the UI element being drawn at location (x, y)
function UIBase:at(x, y)
	local Obj = nil
	local scissorX, scissorY, scissorW, scissorH = love.graphics.getScissor()
	local pX = scissorX == nil and 0 or scissorX
	local pY = scissorY == nil and 0 or scissorY
	local w = scissorW == nil and module.Size.x or scissorW
	local h = scissorH == nil and module.Size.y or scissorH
	if self.ClipContent == true then
		if x < self.AbsolutePosition.x or x > self.AbsolutePosition.x + self.Size.x or y < self.AbsolutePosition.y or y > self.AbsolutePosition.y + self.Size.y then
			return nil
		end
		love.graphics.intersectScissor(self.AbsolutePosition.x, self.AbsolutePosition.y, self.Size.x, self.Size.y)
	end
	-- in bounds and within the UI element
	if x >= pX and x <= pX + w and y >= pY and y <= pY + h then
		if x >= self.AbsolutePosition.x and x <= self.AbsolutePosition.x + self.Size.x and y >= self.AbsolutePosition.y and y <= self.AbsolutePosition.y + self.Size.y then
			Obj = self
		end
	end
	for i = 1, #self.Children do
		if not self.Children[i].Hidden then
			local Found = self.Children[i]:at(x, y)
			if Found ~= nil then
				Obj = Found
			end
		end
	end
	love.graphics.setScissor(scissorX, scissorY, scissorW, scissorH)
	return Obj
end

-- resize the UI element to (w, h)
function UIBase:resize(w, h)
	self.Size:set(w, h)
	if self.TextBlock ~= nil then
		self.TextBlock:setWidth(w - 2 * self.PaddingX)
	end
	if self.Parent ~= nil and self.Parent ~= module then
		updateAbsolutePosition(self, self.Parent.AbsolutePosition.x, self.Parent.AbsolutePosition.y, self.Parent.Size.x, self.Parent.Size.y)
	else
		updateAbsolutePosition(self) -- TODO: THIS LINE OF CODE IS NOT TESTED
	end
	if self.FitTextOnResize and self.TextBlock ~= nil then
		self:fitText()
	end
	module.Changed = true
end

-- reposition the UI element to another location
function UIBase:reposition(sx, sy, ox, oy)
	if vector.isVector(sx) then
		self.Position.Scale:set(sx)
		self.Position.Offset:set(sy)
	else
		self.Position.Scale:set(sx, sy)
		self.Position.Offset:set(ox, oy)
	end
	updateAbsolutePosition(self)
	module.Changed = true
end

-- reposition the UI element to be placed to one of the sides of the given UI element (Parents should be the same to make this work)
-- side: "left" / "right" / "top" / "above" / "bottom" / "under"
function UIBase:putNextTo(Obj, side, offset)
	offset = offset == nil and 0 or offset
	if side == "left" then
		self:reposition(Obj.Position.Scale, Obj.Position.Offset + vector(-self.Size.x - offset, 0))
	elseif side == "right" then
		self:reposition(Obj.Position.Scale, Obj.Position.Offset + vector(Obj.Size.x + offset, 0))
	elseif side == "top" or side == "above" then
		self:reposition(Obj.Position.Scale, Obj.Position.Offset + vector(0, -self.Size.y - offset))
	elseif side == "bottom" or side == "under" or side == "below" then
		self:reposition(Obj.Position.Scale, Obj.Position.Offset + vector(0, Obj.Size.y + offset))
	end
end

-- increase the offset of a UI element by offsetX and offsetY
function UIBase:shift(offsetX, offsetY)
	if vector.isVector(offsetX) then
		self:reposition(self.Position.Scale, self.Position.Offset + offsetX)
	else
		self:reposition(self.Position.Scale, self.Position.Offset + vector(offsetX, offsetY))
	end
end

-- increase the ContentOffset of a UI element by offsetX and offsetY
function UIBase:shiftContent(offsetX, offsetY)
	if vector.isVector(offsetX) then
		self.ContentOffset:set(self.ContentOffset.x + offsetX.x, self.ContentOffset.y + offsetX.y)
	else
		self.ContentOffset:set(self.ContentOffset.x + offsetX, self.ContentOffset.y + offsetY)
	end
	updateAbsolutePosition(self)
	module.Changed = true
end

-- set the ContentOffset of a UI element to offsetX, offsetY
function UIBase:positionContent(offsetX, offsetY)
	if vector.isVector(offsetX) then
		self.ContentOffset:set(offsetX.x, offsetX.y)
	else
		self.ContentOffset:set(offsetX, offsetY)
	end
	updateAbsolutePosition(self)
	module.Changed = true
end

-- horizontally align the element to a side, valid options: "left" / "center" / "right"
function UIBase:alignX(side)
	self.Position.Offset.x = 0
	if side == "left" then
		self.Position.Scale.x = 0
		self.Center.x = 0
	elseif side == "right" then
		self.Position.Scale.x = 1
		self.Center.x = 1
	else
		self.Position.Scale.x = 0.5
		self.Center.x = 0.5
	end
	updateAbsolutePosition(self)
	module.Changed = true
end

-- vertically align the element to a side, valid options: "bottom" / "center" / "top"
function UIBase:alignY(side)
	self.Position.Offset.y = 0
	if side == "top" then
		self.Position.Scale.y = 0
		self.Center.y = 0
	elseif side == "bottom" then
		self.Position.Scale.y = 1
		self.Center.y = 1
	else
		self.Position.Scale.y = 0.5
		self.Center.y = 0.5
	end
	updateAbsolutePosition(self)
	module.Changed = true
end

-- update the style of the component
function UIBase:setBorder(col, width)
	if type(col) == "number" then
		self.BorderWidth = math.floor(col + 0.5)
	else
		self.BorderColor = color(col)
		self.BorderWidth = math.floor(width + 0.5)
	end
end


-- create an invisible border of a certain thickness in pixels, used to offset inner elements and text
function UIBase:setPadding(sizeX, sizeY)
	self.PaddingX = sizeX
	if sizeY == nil then
		self.PaddingY = sizeX
	else
		self.PaddingY = sizeY
	end
	if self.TextBlock ~= nil then
		self.TextBlock:setWidth(self.Size.x - 2 * self.PaddingX)
	end
	updateAbsolutePosition(self)
	module.Changed = true
end


function UIBase:getPixelPadding()
	local px = (self.PaddingX < 1) and (self.PaddingX * 0.5 * self.Size.x) or (self.PaddingX)
	local py = (self.PaddingY < 1) and (self.PaddingY * 0.5 * self.Size.y) or (self.PaddingY)
	return px, py
end


-- adds a TextBlock to the UI and sets its content. If no arguments provided, removes the text. If no font size provided, text is scaled to fit the frame
function UIBase:setText(fontname, textData, size, scaleHeight)
	if fontname == nil then
		self.TextBlock = nil
	elseif size == nil then -- scale text to fit box
		local w = self.Size.x - 2 * self.PaddingX
		local h = self.Size.y - 2 * self.PaddingY
		local tb = textblock(fontname, size, textData, w)
		tb:fitText(w, h)
		self.FitTextOnResize = true
		self.TextBlock = tb
	else
		local w = self.Size.x - 2 * self.PaddingX
		local tb = textblock(fontname, size, textData, w)
		self.TextBlock = tb
		if scaleHeight then
			local width, height = tb:getSize()
			self:resize(self.Size.x, height + self.PaddingY * 2)
		end
	end
end

function UIBase:fitText()
	if self.TextBlock ~= nil then
		self.TextBlock:fitText(self.Size.x - 2 * self.PaddingX, self.Size.y - 2 * self.PaddingY)
	end
end



----------------------------------------------------[[ == FRAME METHODS == ]]----------------------------------------------------

-- draw the frame on screen
function Frame:draw()
	if self.Hidden then return end

	local scissorX, scissorY, scissorW, scissorH = love.graphics.getScissor()

	if self.ClipContent == true then
		love.graphics.intersectScissor(self.AbsolutePosition.x, self.AbsolutePosition.y, self.Size.x, self.Size.y)
	end

	local gw, gh = love.graphics.getDimensions()
	-- bounds check optimization. This will reduce GPU used! (GPU went down from 17% to 14% in a recent test)
	if not (self.AbsolutePosition.x > gw or self.AbsolutePosition.x + self.Size.x < 0 or self.AbsolutePosition.y > gh or self.AbsolutePosition.x + self.Size.x < 0) then
		local r, g, b, a = self.Color.r, self.Color.g, self.Color.b, self.Color.a
		if module.PressedElement == self then
			r, g, b, a = self.ColorHold.r, self.ColorHold.g, self.ColorHold.b, self.ColorHold.a
		elseif module.MouseFocus == self then
			r, g, b, a = self.ColorHover.r, self.ColorHover.g, self.ColorHover.b, self.ColorHover.a
		end
		if self.BorderWidth > 0 then
			love.graphics.setColor(self.BorderColor.r, self.BorderColor.g, self.BorderColor.b, self.BorderColor.a*self.Opacity)
			love.graphics.setLineWidth(self.BorderWidth)
			love.graphics.rectangle("line", self.AbsolutePosition.x + self.BorderWidth / 2, self.AbsolutePosition.y + self.BorderWidth / 2, self.Size.x - self.BorderWidth, self.Size.y - self.BorderWidth)
		end
		love.graphics.setColor(r, g, b, a*self.Opacity)
		love.graphics.rectangle("fill", self.AbsolutePosition.x + self.BorderWidth, self.AbsolutePosition.y + self.BorderWidth, self.Size.x - self.BorderWidth*2, self.Size.y - self.BorderWidth*2)
		-- draw text on top
		if self.TextBlock ~= nil then
			-- TODO: should this if-statement be moved into TextBlock as a method?
			love.graphics.setColor(self.TextBlock.Color:components())
			if self.TextBlock.AlignmentY == "top" then
				love.graphics.draw(self.TextBlock.Text, self.AbsolutePosition.x + self.PaddingX, self.AbsolutePosition.y + self.PaddingY)
			elseif self.TextBlock.AlignmentY == "center" then
				love.graphics.draw(self.TextBlock.Text, self.AbsolutePosition.x + self.PaddingX, self.AbsolutePosition.y + math.floor(self.Size.y / 2 - self.TextBlock.Text:getHeight() / 2))
			else -- bottom
				love.graphics.draw(self.TextBlock.Text, self.AbsolutePosition.x + self.PaddingX, self.AbsolutePosition.y + self.Size.y - self.PaddingY - self.TextBlock.Text:getHeight())
			end
		end
	end

	for i = 1, #self.Children do
		self.Children[i]:draw()
	end
	love.graphics.setScissor(scissorX, scissorY, scissorW, scissorH)
end



----------------------------------------------------[[ == IMAGEFRAME METHODS == ]]----------------------------------------------------

function ImageFrame:setReference(img)
	self.ReferenceImage = img
end


function ImageFrame:draw()
	if self.Hidden then return end

	local imgWidth, imgHeight = self.ReferenceImage:getDimensions()
	local scissorX, scissorY, scissorW, scissorH = love.graphics.getScissor()

	if self.ClipContent == true then
		love.graphics.intersectScissor(self.AbsolutePosition.x, self.AbsolutePosition.y, self.Size.x, self.Size.y)
	end


	local gw, gh = love.graphics.getDimensions()
	-- bounds check to reduce GPU load. Don't need to draw out of bounds!
	if not (self.AbsolutePosition.x > gw or self.AbsolutePosition.x + self.Size.x < 0 or self.AbsolutePosition.y > gh or self.AbsolutePosition.x + self.Size.x < 0) then
		local r, g, b, a = self.Color.r, self.Color.g, self.Color.b, self.Color.a
		if module.PressedElement == self then
			r, g, b, a = self.ColorHold.r, self.ColorHold.g, self.ColorHold.b, self.ColorHold.a
		elseif module.MouseFocus == self then
			r, g, b, a = self.ColorHover.r, self.ColorHover.g, self.ColorHover.b, self.ColorHover.a
		end
		love.graphics.setColor(r, g, b, a*self.Opacity)
		-- temporarily adjust scissor to cut off border space, then reset the scissor
		local curSX, curSY, curSW, curSH = love.graphics.getScissor()
		love.graphics.setScissor(curSX + self.BorderWidth, curSY + self.BorderWidth, curSW - 2*self.BorderWidth, curSH - 2*self.BorderWidth)
		love.graphics.draw(self.ReferenceImage, self.AbsolutePosition.x, self.AbsolutePosition.y, 0, self.Size.x / imgWidth, self.Size.y / imgHeight)
		love.graphics.setScissor(curSX, curSY, curSW, curSH)
		-- draw border
		if self.BorderWidth > 0 then
			love.graphics.setColor(self.BorderColor.r, self.BorderColor.g, self.BorderColor.b, self.BorderColor.a*self.Opacity)
			love.graphics.setLineWidth(self.BorderWidth)
			love.graphics.rectangle("line", self.AbsolutePosition.x + self.BorderWidth / 2, self.AbsolutePosition.y + self.BorderWidth / 2, self.Size.x - self.BorderWidth, self.Size.y - self.BorderWidth)
		end
		-- draw text on top
		if self.TextBlock ~= nil then
			-- TODO: should this if-statement be moved into TextBlock as a method?
			love.graphics.setColor(self.TextBlock.Color:components())
			if self.TextBlock.AlignmentY == "top" then
				love.graphics.draw(self.TextBlock.Text, self.AbsolutePosition.x + self.PaddingX, self.AbsolutePosition.y + self.PaddingY)
			elseif self.TextBlock.AlignmentY == "center" then
				love.graphics.draw(self.TextBlock.Text, self.AbsolutePosition.x + self.PaddingX, self.AbsolutePosition.y + math.floor(self.Size.y / 2 - self.TextBlock.Text:getHeight() / 2))
			else -- bottom
				love.graphics.draw(self.TextBlock.Text, self.AbsolutePosition.x + self.PaddingX, self.AbsolutePosition.y + self.Size.y - self.PaddingY - self.TextBlock.Text:getHeight())
			end
		end
	end

	for i = 1, #self.Children do
		self.Children[i]:draw()
	end
	love.graphics.setScissor(scissorX, scissorY, scissorW, scissorH)
end



----------------------------------------------------[[ == SLICEDFRAME METHODS == ]]----------------------------------------------------

function SlicedFrame:setReference(img)
	local oldReference = self.ReferenceImage
	self.ReferenceImage = img

	local oldW, oldH = oldReference:getDimensions()
	local newW, newH = img:getDimensions()

	self:setSlice(vector(self.TopLeftSlice), self.BottomRightSlice + vector(newW - oldW, newH - oldH))
end


-- sets the top left and top right corner used to chop the image into 9 quads that are used for the drawing operation
function SlicedFrame:setSlice(topLeft, bottomRight)
	if bottomRight == nil then
		bottomRight = vector(self.ReferenceImage:getDimensions()) - topLeft
	end
	self.TopLeftSlice = topLeft
	self.BottomRightSlice = bottomRight
	-- top row
	self.ImageSlices[1]:setViewport(0, 0, topLeft.x, topLeft.y, self.ReferenceImage);
	self.ImageSlices[2]:setViewport(topLeft.x, 0, bottomRight.x - topLeft.x, topLeft.y, self.ReferenceImage);
	self.ImageSlices[3]:setViewport(bottomRight.x, 0, imgPixelWidth - bottomRight.x, topLeft.y, self.ReferenceImage);
	-- middle row
	self.ImageSlices[4]:setViewport(0, topLeft.y, topLeft.x, bottomRight.y - topLeft.y, self.ReferenceImage);
	self.ImageSlices[5]:setViewport(topLeft.x, topLeft.y, bottomRight.x - topLeft.x, bottomRight.y - topLeft.y, self.ReferenceImage);
	self.ImageSlices[6]:setViewport(bottomRight.x, topLeft.y, imgPixelWidth - bottomRight.x, bottomRight.y - topLeft.y, self.ReferenceImage);
	-- bottom row
	self.ImageSlices[7]:setViewport(0, bottomRight.y, topLeft.x, imgPixelHeight - bottomRight.y, self.ReferenceImage);
	self.ImageSlices[8]:setViewport(topLeft.x, bottomRight.y, bottomRight.x - topLeft.x, imgPixelHeight - bottomRight.y, self.ReferenceImage);
	self.ImageSlices[9]:setViewport(bottomRight.x, bottomRight.y, imgPixelWidth - bottomRight.x, imgPixelHeight - bottomRight.y, self.ReferenceImage);
end


-- draws the sliced image at its location in the UI. Called internally
function SlicedFrame:draw()
	if self.Hidden then return end

	local imgWidth, imgHeight = self.ReferenceImage:getDimensions()
	local scissorX, scissorY, scissorW, scissorH = love.graphics.getScissor()

	if self.ClipContent == true then
		love.graphics.intersectScissor(self.AbsolutePosition.x, self.AbsolutePosition.y, self.Size.x, self.Size.y)
	end

	local gw, gh = love.graphics.getDimensions()
	-- bounds check to reduce GPU load. Don't need to draw out of bounds!
	if not (self.AbsolutePosition.x > gw or self.AbsolutePosition.x + self.Size.x < 0 or self.AbsolutePosition.y > gh or self.AbsolutePosition.x + self.Size.x < 0) then
		local r, g, b, a = self.Color.r, self.Color.g, self.Color.b, self.Color.a
		if module.PressedElement == self then
			r, g, b, a = self.ColorHold.r, self.ColorHold.g, self.ColorHold.b, self.ColorHold.a
		elseif module.MouseFocus == self then
			r, g, b, a = self.ColorHover.r, self.ColorHover.g, self.ColorHover.b, self.ColorHover.a
		end
		love.graphics.setColor(r, g, b, a*self.Opacity)
		-- temporarily adjust scissor to cut off border space, then reset the scissor
		local curSX, curSY, curSW, curSH = love.graphics.getScissor()
		love.graphics.setScissor(curSX + self.BorderWidth, curSY + self.BorderWidth, curSW - 2*self.BorderWidth, curSH - 2*self.BorderWidth)
		

		local x2 = self.TopLeftSlice.x * self.CornerScale
		local x3 = self.Size.x - (imgWidth - self.BottomRightSlice.x) * self.CornerScale
		local y2 = self.TopLeftSlice.y * self.CornerScale
		local y3 = self.Size.y - (imgHeight - self.BottomRightSlice.y) * self.CornerScale
		local stretchXMultiplier = (self.Size.x - self.TopLeftSlice.x * self.CornerScale - (imgWidth - self.BottomRightSlice.x) * self.CornerScale) / (self.BottomRightSlice.x - self.TopLeftSlice.x)
		local stretchYMultiplier = (self.Size.y - self.TopLeftSlice.y * self.CornerScale - (imgHeight - self.BottomRightSlice.y) * self.CornerScale) / (self.BottomRightSlice.y - self.TopLeftSlice.y)

		-- in reading order, top row
		love.graphics.draw(self.ReferenceImage, self.ImageSlices[1], self.AbsolutePosition.x, self.AbsolutePosition.y, 0, self.CornerScale, self.CornerScale)
		love.graphics.draw(self.ReferenceImage, self.ImageSlices[2], self.AbsolutePosition.x + x2, self.AbsolutePosition.y, 0, stretchXMultiplier, self.CornerScale)
		love.graphics.draw(self.ReferenceImage, self.ImageSlices[3], self.AbsolutePosition.x + x3, self.AbsolutePosition.y, 0, self.CornerScale, self.CornerScale)
		-- middle row
		love.graphics.draw(self.ReferenceImage, self.ImageSlices[4], self.AbsolutePosition.x, self.AbsolutePosition.y + y2, 0, self.CornerScale, stretchYMultiplier)
		love.graphics.draw(self.ReferenceImage, self.ImageSlices[5], self.AbsolutePosition.x + x2, self.AbsolutePosition.y + y2, 0, stretchXMultiplier, stretchYMultiplier)
		love.graphics.draw(self.ReferenceImage, self.ImageSlices[6], self.AbsolutePosition.x + x3, self.AbsolutePosition.y + y2, 0, self.CornerScale, stretchYMultiplier)
		-- bottom row
		love.graphics.draw(self.ReferenceImage, self.ImageSlices[7], self.AbsolutePosition.x, self.AbsolutePosition.y + y3, 0, self.CornerScale, self.CornerScale)
		love.graphics.draw(self.ReferenceImage, self.ImageSlices[8], self.AbsolutePosition.x + x2, self.AbsolutePosition.y + y3, 0, stretchXMultiplier, self.CornerScale)
		love.graphics.draw(self.ReferenceImage, self.ImageSlices[9], self.AbsolutePosition.x + x3, self.AbsolutePosition.y + y3, 0, self.CornerScale, self.CornerScale)


		love.graphics.setScissor(curSX, curSY, curSW, curSH)
		-- draw border
		if self.BorderWidth > 0 then
			love.graphics.setColor(self.BorderColor.r, self.BorderColor.g, self.BorderColor.b, self.BorderColor.a*self.Opacity)
			love.graphics.setLineWidth(self.BorderWidth)
			love.graphics.rectangle("line", self.AbsolutePosition.x + self.BorderWidth / 2, self.AbsolutePosition.y + self.BorderWidth / 2, self.Size.x - self.BorderWidth, self.Size.y - self.BorderWidth)
		end

		-- draw text on top
		if self.TextBlock ~= nil then
			-- TODO: should this if-statement be moved into TextBlock as a method?
			love.graphics.setColor(self.TextBlock.Color:components())
			if self.TextBlock.AlignmentY == "top" then
				love.graphics.draw(self.TextBlock.Text, self.AbsolutePosition.x + self.PaddingX, self.AbsolutePosition.y + self.PaddingY)
			elseif self.TextBlock.AlignmentY == "center" then
				love.graphics.draw(self.TextBlock.Text, self.AbsolutePosition.x + self.PaddingX, self.AbsolutePosition.y + math.floor(self.Size.y / 2 - self.TextBlock.Text:getHeight() / 2))
			else -- bottom
				love.graphics.draw(self.TextBlock.Text, self.AbsolutePosition.x + self.PaddingX, self.AbsolutePosition.y + self.Size.y - self.PaddingY - self.TextBlock.Text:getHeight())
			end
		end
	end

	for i = 1, #self.Children do
		self.Children[i]:draw()
	end
	love.graphics.setScissor(scissorX, scissorY, scissorW, scissorH)
end



----------------------------------------------------[[ == OBJECT CREATION == ]]----------------------------------------------------

-- the base properties of each UIBase
local function newBase(w, h, col)
	col = col == nil and color(1, 1, 1) or color(col)
	module.TotalCreated = module.TotalCreated + 1
	local Obj = {
		-- properties
		["AbsolutePosition"] = vector(0, 0); -- position in absolute pixels
		["BorderColor"] = color(col):darken(0.4); -- color of the inner border of the frame
		["BorderWidth"] = 0; -- border thickness in pixels
		["Center"] = vector(0, 0); -- AnchorPoint from Roblox
		["Children"] = {};
		["Class"] = "Frame";
		["ClipContent"] = true; -- children and text will be cut off if it falls outside of the frame
		["ContentOffset"] = vector();
		["Color"] = col; -- color of the frame. For images, this adjusts the image color
		["ColorHold"] = col:clone(); -- color when the element is being held down
		["ColorHover"] = col:clone(); -- color when the element is being hovered over by the cursor
		["FitTextOnResize"] = false;
		["Hidden"] = false;
		["Id"] = module.TotalCreated;
		["Opacity"] = 1; -- if 0, this object is not drawn (but children are!) TODO: fix children not being drawn
		["PaddingX"] = 0; -- an invisible border that creates a smaller inner-window to contain children and text. If 0 < padding < 1, then it's interpreted as a percentage / ratio
		["PaddingY"] = 0;
		["Parent"] = nil;
		["Position"] = { -- works similar to Roblox's UDim2
			["Scale"] = vector(0, 0);
			["Offset"] = vector(0, 0);
		};
		["Size"] = vector(w, h);
		["TextBlock"] = nil;

		-- events
		["OnDrag"] = nil; -- triggered when you move the input across the pressed element
		["OnDragEnd"] = nil; -- triggered when you stop dragging an object, by releasing or changing the input button
		["OnFullPress"] = nil; -- tap/click started and ended in the same element with no interruption
		["OnHoverEnd"] = nil; -- triggered when cursor left the element
		["OnHoverStart"] = nil; -- triggered when cursor enters the element
		["OnNestedDrag"] = nil; -- same as OnDrag, but it also works on descendants
		["OnNestedDragEnd"] = nil; -- same as OnDragEnd, but it also works on descendants
		["OnNestedScroll"] = nil; -- triggered when you scroll the mouse wheel over an element, or one of its descendants
		["OnPressEnd"] = nil; -- tap/click ended in the element
		["OnPressStart"] = nil; -- tap/click started in the element
		["OnScroll"] = nil; -- triggered when you scroll the mouse wheel while hovering over the element
	}
	return Obj
end

-- create new Frame object
local function newFrame(w, h, col)
	local Obj = newBase(w, h, col)
	setmetatable(Obj, Frame)
	return Obj
end

-- create new ImageFrame object
local function newImageFrame(img, w, h, col)
	local Obj = newBase(w or img:getPixelWidth(), h or img:getPixelHeight(), col)
	Obj["ReferenceImage"] = img
	setmetatable(Obj, ImageFrame)
	return Obj
end

-- create new SlicedFrame object
local function newSlicedFrame(img, topLeft, bottomRight, w, h, col, corScale)
	-- create and initialize main object
	local imgPixelWidth, imgPixelHeight = img:getDimensions()
	if bottomRight == nil then
		bottomRight = vector(imgPixelWidth, imgPixelHeight) - topLeft
	end
	local Obj = newBase(w or imgPixelWidth, h or imgPixelHeight, col)
	Obj["ReferenceImage"] = img
	Obj["CornerScale"] = corScale or 1
	Obj["TopLeftSlice"] = topLeft
	Obj["BottomRightSlice"] = bottomRight
	Obj["ImageSlices"] = { -- set slices, in reading order
		-- top row
		love.graphics.newQuad(0, 0, topLeft.x, topLeft.y, Obj.ReferenceImage);
		love.graphics.newQuad(topLeft.x, 0, bottomRight.x - topLeft.x, topLeft.y, Obj.ReferenceImage);
		love.graphics.newQuad(bottomRight.x, 0, imgPixelWidth - bottomRight.x, topLeft.y, Obj.ReferenceImage);
		-- middle row
		love.graphics.newQuad(0, topLeft.y, topLeft.x, bottomRight.y - topLeft.y, Obj.ReferenceImage);
		love.graphics.newQuad(topLeft.x, topLeft.y, bottomRight.x - topLeft.x, bottomRight.y - topLeft.y, Obj.ReferenceImage);
		love.graphics.newQuad(bottomRight.x, topLeft.y, imgPixelWidth - bottomRight.x, bottomRight.y - topLeft.y, Obj.ReferenceImage);
		-- bottom row
		love.graphics.newQuad(0, bottomRight.y, topLeft.x, imgPixelHeight - bottomRight.y, Obj.ReferenceImage);
		love.graphics.newQuad(topLeft.x, bottomRight.y, bottomRight.x - topLeft.x, imgPixelHeight - bottomRight.y, Obj.ReferenceImage);
		love.graphics.newQuad(bottomRight.x, bottomRight.y, imgPixelWidth - bottomRight.x, imgPixelHeight - bottomRight.y, Obj.ReferenceImage);
	}

	-- return
	setmetatable(Obj, SlicedFrame)
	return Obj
end



----------------------------------------------------[[ == RETURN == ]]----------------------------------------------------

-- pack up and return module
module.newFrame = newFrame
module.newImageFrame = newImageFrame
module.newSlicedFrame = newSlicedFrame
--return setmetatable(module, {__call = function(_, ...) return new(...) end})
return module



