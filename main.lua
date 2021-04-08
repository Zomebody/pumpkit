
local ui = require("framework.ui")
--local inputreader = require("framework/inputreader")
local color = require("framework.datatypes.color")
local vector = require("framework.datatypes.vector")
--local content = require("app/content/ui_base").Content

local addToPage = require("app.append_page")
local createDropdown = require("app.create_dropdown")

local defaultFont = "LieraSansMedium.ttf"

local Vars = {
	["Default"] = {
		["NavigationWidth"] = 200;
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

	-- set events
	local Scrollables = {{Navigation, 30}, {Body, 50}}
	for i = 1, #Scrollables do
		local Obj = Scrollables[i][1]
		Obj.OnNestedScroll = function(x, y)
			Obj:shiftContent(0, y * Scrollables[i][2])
			if Obj.ContentOffset.y > 0 then
				Obj:shiftContent(0, -Obj.ContentOffset.y)
			end
		end
	end

	-- create and fill in the top bar
	TopBar = ui.newFrame(love.graphics.getWidth(), DisplayVars.TopBarThickness, Colors.Background)
	TopBar.ClipContent = false

	--local dropDowns = {love.filesystem.getDirectoryItems("app.content")}
	--for o = 1, #dropDowns do
	--local directoryChildren = love.filesystem.getDirectoryItems("app/content/classes")
	--print(#directoryChildren)
	--local Box = createDropdown(DisplayVars, directoryChildren)
	--Box:reposition(0, 0, 0, TopBar.Size.y)
	--TopBar:addChild(Box)
	--end

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

	--[[
	for i = 1, #docFiles do
		local data = require("app.content.classes." .. docFiles[i]:sub(1, docFiles[i]:find("%.") - 1))
		-- create containers
		local NavContainer = ui.newFrame(DisplayVars.NavigationWidth, 0, Colors.Transparent)
		NavContainer.ClipContent = false
		NavContainer:hide()
		Navigation:addChild(NavContainer)
		local BodyContainer = ui.newFrame(DisplayVars.BodyWidth, 0, Colors.Transparent)
		BodyContainer.ClipContent = false
		BodyContainer:hide()
		Body:addChild(BodyContainer)

		local dataTarget = data
		local superClass = nil
		repeat
			addToPage(BodyContainer, NavContainer, dataTarget, DisplayVars, superClass)
			local stop = true
			if dataTarget.Meta.SuperClass ~= nil then
				for k = 1, #docFiles do
					if docFiles[k]:sub(1, docFiles[k]:find("%.") - 1) == dataTarget.Meta.SuperClass then
						stop = false
						superClass = dataTarget.Meta.SuperClass
						dataTarget = require("app.content.classes." .. dataTarget.Meta.SuperClass)
						break
					end
				end
			end
		until stop


		local Button = ui.newFrame(999, DisplayVars.TopBarThickness, Colors.Transparent)
		Button.ColorHover = Colors.ButtonHover
		Button.ColorHold = Colors.ButtonHold
		Button:setText(defaultFont, data.Meta.Name, DisplayVars.TextSize)
		Button:resize(Button.TextBlock:getSize() + 20, Button.Size.y)
		Button.TextBlock:alignX("center")
		Button.TextBlock:alignY("center")
		Button.OnFullPress = function(x, y, button)
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
		if prevButton ~= nil then
			Button:putNextTo(prevButton, "right")
		end
		prevButton = Button
		TopBar:addChild(Button)
	end
	]]

	-- add topbar last so it always appears on top
	ui:addChild(TopBar)
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
	love.graphics.print(tostring(love.timer.getFPS()) .. ", " .. tostring(wx) .. ", " .. tostring(wy) .. ", " .. tostring(ww) .. ", " .. tostring(wh), 10, wy + wh - 30)
end



