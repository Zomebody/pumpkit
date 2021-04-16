
local ui = require("framework.ui")
local color = require("framework.datatypes.color")
local vector = require("framework.datatypes.vector")
local Colors = require("app.color_palette")

local defaultFont = "LieraSansMedium.ttf"

function createDropdown(Vars, LinkedButton, strings)
	local Container = ui.newFrame(0, 0, Colors.BackgroundLight)
	Container.ClipContent = false
	Container.Hidden = true
	local maxWidth = 40
	for i = 1, #strings do
		local Button = ui.newFrame(9999, 0, Colors.Transparent)
		Button:setPadding(12, 8)
		Button:setText(defaultFont, strings[i], Vars.TextSize, true)
		Button:alignX("left")
		local textWidth = Button.TextBlock:getSize() + Button.PaddingX * 2
		if textWidth > maxWidth then
			maxWidth = textWidth
		end
		Button.ColorHover = Colors.ButtonHover
		Button.ColorHold = Colors.ButtonHold
		if #Container.Children > 0 then
			Button:putNextTo(Container.Children[#Container.Children], "under")
		end
		Button.OnHoverEnd = function()
			if ui.CursorFocus == nil or (ui.CursorFocus.Parent ~= Button.Parent and ui.CursorFocus ~= LinkedButton) then
				Container.Hidden = true
			end
		end
		Container:addChild(Button)
	end
	for i = 1, #Container.Children do
		Container.Children[i]:resize(maxWidth, Container.Children[i].Size.y)
	end
	if #Container.Children > 0 then
		Container:resize(maxWidth, Container.Children[#Container.Children].Position.Offset.y + Container.Children[#Container.Children].Size.y)
	end
	Container:putNextTo(LinkedButton, "below")

	-- link events to make dropdown work
	LinkedButton.OnFullPress = function(x, y, button)
		if button == 1 then
			Container.Hidden = not Container.Hidden
		end
	end
	LinkedButton.OnHoverEnd = function()
		if not (ui.CursorFocus == Container or (ui.CursorFocus ~= nil and ui.CursorFocus.Parent == Container)) then
			Container.Hidden = true
		end
	end

	LinkedButton.Parent:addChild(Container)
	
	return Container
end

return createDropdown
