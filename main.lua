
local ui = require("framework.ui")
--local inputreader = require("framework/inputreader")
local color = require("framework.datatypes.color")
local vector = require("framework.datatypes.vector")
local tween = require("framework.datatypes.tween")
--local content = require("app/content/ui_base").Content

local addToPage = require("app.append_page")
local createDropdown = require("app.create_dropdown")

local defaultFont = "LieraSansMedium.ttf"

local Vars = {
	["Default"] = {
		["NavigationWidth"] = 210;
		["BodyWidth"] = 700;
		["DividerThickness"] = 6;
		["TopBarThickness"] = 42;
		["HeaderFontSize"] = 36;
		["TitleFontSize"] = 20;
		["TextSize"] = 16;
		["SmallTextSize"] = 12;
		["CodeSize"] = 16;
		["PagePaddingLeft"] = 15;
	};
	["SmallScreen"] = {
		["NavigationWidth"] = 150;
		["BodyWidth"] = 550;
		["DividerThickness"] = 4;
		["TopBarThickness"] = 32;
		["HeaderFontSize"] = 24;
		["TitleFontSize"] = 16;
		["TextSize"] = 12;
		["SmallTextSize"] = 9;
		["CodeSize"] = 12;
		["PagePaddingLeft"] = 12;
	}
}

local DisplayVars = nil

local TopBar = nil
local Container = nil
local Navigation = nil
local Body = nil

local shownBody = nil
local shownNavigation = nil

local Colors = require("app/color_palette")

local wx, wy, ww, wh = love.window.getSafeArea()

function love.load()
	love.window.setTitle("UI Documentation")

	wx, wy, ww, wh = love.window.getSafeArea()
	DisplayVars = love.graphics.getWidth() > 720 and Vars.Default or Vars.SmallScreen
	Vars.SmallScreen.BodyWidth = ww - Vars.SmallScreen.NavigationWidth

	tween:initialize()
	ui:initialize()

	-- create main body
	love.graphics.setBackgroundColor(Colors.BackgroundDark:components())
	Container = ui.newFrame(DisplayVars.NavigationWidth + DisplayVars.BodyWidth + 4, love.graphics.getHeight())
	Container.Opacity = 0
	Container:alignX("center")
	Container:shift(0, DisplayVars.TopBarThickness)

	Navigation = ui.newFrame(DisplayVars.NavigationWidth, love.graphics.getHeight(), Colors.BackgroundSemiDark)
	Navigation:alignX("left")
	Body = ui.newFrame(DisplayVars.BodyWidth, love.graphics.getHeight(), Colors.Background)
	Body:alignX("right")
	ui:addChild(Container)
	Container:addChild(Navigation)
	Container:addChild(Body)

	local function hasScrollEvents(Obj)
		if Obj ~= nil and Obj ~= Body then
			return Obj.OnScroll ~= nil or Obj.OnNestedScroll ~= nil
		end
		return false
	end
	local function hasPressEvents(Obj)
		if Obj ~= nil and Obj ~= Body then
			return Obj.OnPressStart ~= nil or Obj.OnPressEnd ~= nil or Obj.OnFullPress ~= nil or Obj.OnDrag ~= nil or Obj.OnNestedDrag
		end
		return false
	end
	-- set events
	local Scrollables = {{Navigation, 30}, {Body, 50}}
	for i = 1, #Scrollables do
		local function getShownChild(Item)
			for o = 1, #Item.Children do
				if not Item.Children[o].Hidden then
					return Item.Children[o]
				end
			end
		end
		local scrollTween = nil
		local Obj = Scrollables[i][1]
		Obj.OnNestedScroll = function(x, y)
			if i == 2 and hasScrollEvents(ui.MouseFocus) then
				return
			end
			Obj:shiftContent(0, y * Scrollables[i][2])
			local ShownChild = getShownChild(Obj)
			if ShownChild ~= nil then
				if Obj.ContentOffset.y > 0 then
					Obj:positionContent(0, 0)
				elseif Obj.ContentOffset.y < -ShownChild.Children[#ShownChild.Children].Position.Offset.y then
					Obj:positionContent(0, -ShownChild.Children[#ShownChild.Children].Position.Offset.y)
				end
			end
		end
		Obj.OnNestedDrag = function(dx, dy)
			if i == 2 and hasPressEvents(ui.DragTarget) then
				return
			end
			Obj:shiftContent(0, dy)
			local ShownChild = getShownChild(Obj)
			if ShownChild ~= nil then
				if Obj.ContentOffset.y > 0 then
					Obj:positionContent(0, 0)
				elseif Obj.ContentOffset.y < -ShownChild.Children[#ShownChild.Children].Position.Offset.y then
					Obj:positionContent(0, -ShownChild.Children[#ShownChild.Children].Position.Offset.y)
				end
			end
		end
		Obj.OnNestedDragEnd = function()
			if i == 2 and hasPressEvents(ui.DragTarget) then
				return
			end
			local frames = math.ceil(love.timer.getFPS() / 20)
			--print("frames: " .. frames)
			--local CursorSpeed = ui:getCursorSpeed(6)
			print(CursorSpeed)
			if CursorSpeed.y ~= 0 then
				local ValueObject = {["Value"] = CursorSpeed.y * love.timer.getDelta()}
				print(ValueObject.Value)
				local ShownChild = getShownChild(Obj)
				local sign = ValueObject.Value / math.abs(ValueObject.Value)
				scrollTween = tween(ValueObject, "linear", math.sqrt(sign * ValueObject.Value / 30), {["Value"] = 0})
				scrollTween:play()
				scrollTween.OnUpdate = function()
					Obj:shiftContent(0, ValueObject.Value)
					if Obj.ContentOffset.y > 0 then
						Obj:positionContent(0, 0)
					elseif Obj.ContentOffset.y < -ShownChild.Children[#ShownChild.Children].Position.Offset.y then
						Obj:positionContent(0, -ShownChild.Children[#ShownChild.Children].Position.Offset.y)
					end
				end
			end
		end
		Obj.OnNestedPressStart = function()
			if scrollTween ~= nil then
				scrollTween:stop()
				scrollTween = nil
			end
		end
	end

	-- create and fill in the top bar
	TopBar = ui.newFrame(love.graphics.getWidth(), DisplayVars.TopBarThickness, Colors.Background)
	TopBar.ClipContent = false

	local tabs = love.filesystem.getDirectoryItems("app/content")
	table.sort(tabs)

	local prevButton = nil

	-- for each tab, create a dropdown container and a button that is linked to it
	for i = 1, #tabs do
		-- create the tab button in the navigation bar at the top
		local Button = ui.newFrame(999, DisplayVars.TopBarThickness, Colors.Transparent)
		Button.ColorHover = Colors.ButtonHover
		Button.ColorHold = Colors.ButtonHold
		Button:setText(defaultFont, tabs[i], DisplayVars.TextSize)
		Button:resize(Button.TextBlock:getSize() + 20, Button.Size.y)
		Button.TextBlock:alignX("center")
		Button.TextBlock:alignY("center")
		if prevButton ~= nil then
			Button:putNextTo(prevButton, "right")
		end
		prevButton = Button
		TopBar:addChild(Button)

		-- find the files belonging to this dropdown tab. Also remove the file name extension of each one
		local tabFiles = love.filesystem.getDirectoryItems("app/content/" .. tabs[i])
		table.sort(tabFiles)
		for k = 1, #tabFiles do
			tabFiles[k] = tabFiles[k]:sub(1, tabFiles[k]:find("%.") - 1)
		end

		-- add a dropdown that is linked to the button we just created
		-- this will also link events to the button to open and close the dropdown. It will also parent the dropdown!
		local DropdownBox = createDropdown(DisplayVars, Button, tabFiles)

		-- for each item in the dropdown, load the page and link the right button to open the page
		for k = 1, #tabFiles do
			-- load the page data
			local data = require("app.content." .. tabs[i] .. "." .. tabFiles[k])

			-- create page containers
			local NavContainer = ui.newFrame(DisplayVars.NavigationWidth, 0, Colors.Transparent)
			NavContainer.ClipContent = false
			NavContainer:hide()
			Navigation:addChild(NavContainer)
			local BodyContainer = ui.newFrame(DisplayVars.BodyWidth, 0, Colors.Transparent)
			BodyContainer.ClipContent = false
			BodyContainer:hide()
			Body:addChild(BodyContainer)

			-- fill the page with data
			local dataTarget = data
			local superClass = nil
			repeat
				addToPage(BodyContainer, NavContainer, dataTarget, DisplayVars, superClass)
				local stop = true
				if dataTarget.Meta.SuperClass ~= nil then
					for l = 1, #tabFiles do
						if tabFiles[l] == dataTarget.Meta.SuperClass then
							stop = false
							superClass = dataTarget.Meta.SuperClass
							dataTarget = require("app.content." .. tabs[i] .. "." .. dataTarget.Meta.SuperClass)
							break
						end
					end
				end
			until stop

			-- link the right button in the dropdown to open the page and close the previous page
			DropdownBox.Children[k].OnFullPress = function(x, y, button)
				if button == 1 then
					Navigation:positionContent(0, 0)
					Body:positionContent(0, 0)
					if shownNavigation ~= nil then
						shownNavigation:hide()
					end
					if shownBody ~= nil then
						shownBody:hide()
					end
					NavContainer:show()
					shownNavigation = NavContainer
					BodyContainer:show()
					shownBody = BodyContainer
				end
			end
		end

	end

	-- add topbar last so it always appears on top
	ui:addChild(TopBar)
end

function love.mousepressed(x, y, button, istouch, presses, inputOnUI)
	--print(inputOnUI)
end

function love.mousereleased(x, y, button, istouch, presses, inputOnUI)
	--print(inputOnUI)
end

function love.wheelmoved(x, y, inputOnUI)
	print(inputOnUI)
end

function love.resize(w, h)
	TopBar:resize(w, DisplayVars.TopBarThickness)
	Container:resize(Container.Size.x, h)
	Navigation:resize(Navigation.Size.x, h)
	Body:resize(Body.Size.x, h)
end

function love.update()
	wx, wy, ww, wh = love.window.getSafeArea()
end

function love.draw()
	ui:render()
	--love.graphics.print(tostring(love.timer.getFPS()) .. ", drag active: " .. tostring(ui.DragActive) .. ", dragged ID: " .. tostring(ui.DragTarget ~= nil and ui.DragTarget.Id or nil), 10, wy + wh - 30)
end



