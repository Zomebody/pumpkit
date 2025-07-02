
local loader = require("framework.loader")

local addToPage
local createDropdown
local Colors

local defaultFont = "LieraSansMedium.ttf"

local Vars = {
	["Default"] = {
		["NavigationWidth"] = 210;
		["BodyWidth"] = 700;
		["DividerThickness"] = 6;
		["TopBarThickness"] = 42;
		["HeaderFontSize"] = 36;
		["TitleFontSize"] = 20;
		["TextSize"] = 14;
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
		["TextSize"] = 11;
		["SmallTextSize"] = 9;
		["CodeSize"] = 12;
		["PagePaddingLeft"] = 12;
	}
}

local garbage = 0

local DisplayVars = nil

local TopBar = nil
local Container = nil
local Navigation = nil
local Body = nil

local shownBody = nil
local shownNavigation = nil



local wx, wy, ww, wh = love.window.getSafeArea()

function love.load()
	loader()
	addToPage = require(filepath("app/append_page", "."))
	createDropdown = require(filepath("app/create_dropdown", "."))
	Colors = require("app.color_palette")
	
	love.window.setTitle("UI Documentation")

	wx, wy, ww, wh = love.window.getSafeArea()
	DisplayVars = love.graphics.getWidth() > 720 and Vars.Default or Vars.SmallScreen
	Vars.SmallScreen.BodyWidth = ww - Vars.SmallScreen.NavigationWidth

	--[[
	task:initialize()
	tween:initialize()
	animation:initialize()
	ui:initialize()
]]

	initializeApp()
end

function initializeApp()
	print("start garbage: " .. collectgarbage("count"))

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
			--return Obj.OnScroll ~= nil or Obj.OnNestedScroll ~= nil
			return Obj.Events.Scroll ~= nil or Obj.Events.NestedScroll ~= nil
		end
		return false
	end
	local function hasPressEvents(Obj)
		if Obj ~= nil and Obj ~= Body then
			--return Obj.OnPressStart ~= nil or Obj.OnPressEnd ~= nil or Obj.OnFullPress ~= nil or Obj.OnDrag ~= nil or Obj.OnNestedDrag
			return Obj.Events.PressStart ~= nil or Obj.Events.PressEnd ~= nil or Obj.Events.FullPress ~= nil or Obj.Events.Drag ~= nil or Obj.Events.NestedDrag ~= nil
		end
		return false
	end
	local function getShownChild(Item)
		for o = 1, #Item.Children do
			if not Item.Children[o].Hidden then
				return Item.Children[o]
			end
		end
	end


	-- set events
	local Scrollables = {{Navigation, 30}, {Body, 50}}
	for i = 1, #Scrollables do
		
		local scrollTween = nil
		local Obj = Scrollables[i][1]
		
		Obj:on("NestedScroll", function(x, y)
			if i == 2 and hasScrollEvents(ui.CursorFocus) then
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
		end)
		
		Obj:on("NestedDrag", function(dx, dy, button)
			if button == 1 then
				if i == 2 and hasPressEvents(ui.DragTarget) then
					return
				end
				local ShownChild = getShownChild(Obj)
				
				if ShownChild ~= nil then
					ShownChild:shiftContent(0, dy)
					if ShownChild.ContentOffset.y > 0 then
						ShownChild:positionContent(0, 0)
					elseif ShownChild.ContentOffset.y < -ShownChild.Children[#ShownChild.Children].Position.Offset.y then
						ShownChild:positionContent(0, -ShownChild.Children[#ShownChild.Children].Position.Offset.y)
					end
				end
			end
		end)
		
		Obj:on("NestedDragEnd", function(_, _, button)
			if button == 1 then
				if i == 2 and hasPressEvents(ui.DragTarget) then
					return
				end
				local frames = math.ceil(love.timer.getFPS() / 20)
				--print("frames: " .. frames)
				local CursorSpeed = ui:getCursorSpeed(frames)
				if CursorSpeed.y ~= 0 then
					local ValueObject = {["Value"] = CursorSpeed.y * love.timer.getDelta()}
					local ShownChild = getShownChild(Obj)
					if ShownChild == nil then return end
					local sign = ValueObject.Value / math.abs(ValueObject.Value)
					scrollTween = tween(ValueObject, "linear", math.sqrt(sign * ValueObject.Value / 30), {["Value"] = 0})
					scrollTween:play()
					scrollTween:on("Update", function()
						ShownChild:shiftContent(0, ValueObject.Value)
						if ShownChild.ContentOffset.y > 0 then
							ShownChild:positionContent(0, 0)
						elseif ShownChild.ContentOffset.y < -ShownChild.Children[#ShownChild.Children].Position.Offset.y then
							ShownChild:positionContent(0, -ShownChild.Children[#ShownChild.Children].Position.Offset.y)
						end
						
					end)
				end
			end
		end)
		
		Obj:on("NestedPressStart", function()
			if scrollTween ~= nil then
				scrollTween:stop()
				scrollTween = nil
			end
		end)
	end
	
	task.spawn(
		function()
			local direction = 0
			if love.keyboard.isDown("down") then direction = direction - 1 end
			if love.keyboard.isDown("up") then direction = direction + 1 end
			if direction ~= 0 then
				local ShownChild = getShownChild(Body)
				if ShownChild == nil then return end
				ShownChild:shiftContent(0, love.timer.getDelta() * direction * 200)
				if ShownChild.ContentOffset.y > 0 then
					ShownChild:positionContent(0, 0)
				elseif ShownChild.ContentOffset.y < -ShownChild.Children[#ShownChild.Children].Position.Offset.y then
					ShownChild:positionContent(0, -ShownChild.Children[#ShownChild.Children].Position.Offset.y)
				end
			end
		end, 0, math.huge, 0
	)
	

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
		Button.ColorFocus = Colors.ButtonHover
		Button.ColorHold = Colors.ButtonHold
		Button:setText(defaultFont, tabs[i], DisplayVars.TextSize)
		Button:resize(0, Button.Size.Scale.y, Button.TextBlock:getSize() + 20, Button.Size.Offset.y)
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

			-- link the right button in the dropdown to open the page and close the previous page
			local bodyInitialized = false
			--DropdownBox.Children[k].OnFullPress = function(x, y, button)
			DropdownBox.Children[k]:on("FullPress", function(x, y, button)
				if button == 1 then
					-- check if page has been initialized yet
					if not bodyInitialized then
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
						bodyInitialized = true
					end
					Navigation:positionContent(0, 0)
					Body:positionContent(0, 0)
					for i = 1, #Body.Children do
						Body.Children[i]:positionContent(0, 0)
					end
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
			end)
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
	--print(inputOnUI)
end

-- debug keys
function love.keypressed(key)
	if #ui.KeyboardFocus > 0 then return end
	if key == "e" then
		if ui.Visible then
			ui:hide()
		else
			ui:show()
		end
	elseif key == "d" then
		for i = 1, #ui.Children do
			print(ui.Children[i], ui.Children[i].Parent)
		end

	elseif key == "q" and TopBar ~= nil then
		ui:remove(TopBar)
		ui:remove(Container)
		TopBar = nil
		Container = nil
		Navigation = nil
		Body = nil
		shownNavigation = nil
		shownBody = nil
		collectgarbage("collect")
		garbage = collectgarbage("count")
		for i = 1, #ui.Children do
			print(ui.Children[i], ui.Children[i].Parent)
		end
	elseif key == "r" and TopBar == nil then
		initializeApp()
	end
end


function love.resize(w, h)
	TopBar:resize(0, 0, w, DisplayVars.TopBarThickness)
	Container:resize(0, 0, Container.Size.Offset.x, h)
	Navigation:resize(0, 0, Navigation.Size.Offset.x, h)
	Body:resize(0, 0, Body.Size.Offset.x, h)
end


function love.update()
	wx, wy, ww, wh = love.window.getSafeArea()
end


function love.draw()
	ui:render()
	--love.graphics.print(tostring(love.timer.getFPS()) .. ", drag active: " .. tostring(ui.DragActive) .. ", dragged ID: " .. tostring(ui.DragTarget ~= nil and ui.DragTarget.Id or nil), 10, wy + wh - 30)
	love.graphics.print(tostring(love.timer.getFPS()), 10, wy + wh - 30)
	local stats = love.graphics.getStats()
	
	love.graphics.print(garbage, 10, wy + wh - 50)
	love.graphics.print("draws: " .. tostring(stats.drawcalls) .. ", imgs: " .. tostring(stats.images) .. ", tex_mem: " .. tostring(stats.texturememory) .. ", fnts: " .. tostring(stats.fonts), 10, wy + wh - 70)

	love.graphics.print("tasks running: " .. tostring(#task.Running), 10, wy + wh - 90)
	love.graphics.print("tweens running: " .. tostring(#tween.Active), 10, wy + wh - 110)

end



