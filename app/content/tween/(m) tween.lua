

local ui = require("framework.ui")
local vector = require("framework.datatypes.vector")
local color = require("framework.datatypes.color")
local tween = require("framework.datatypes.tween")


local meta = {
	["Name"] = "(m) tween";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The tween Module";
	["Description"] = "A module responsible for the creation and execution of tweens.";
	["CodeMarkup"] = "";
	["Demo"] = function()
		local Container = ui.newFrame(400, 120, color(0, 0, 0))
		Container:setPadding(20, 20)
		local Box = ui.newFrame(80, 80, color(1, 1, 1))
		Box:alignX("left")
		Container:addChild(Box)

		local TweenedObject = {["Value"] = 0}
		local posTween = tween.new(TweenedObject, "sine", 2, {["Value"] = 1})

		Box.OnFullPress = function(x, y, button)
			if button == 1 then
				if posTween.Playing then
					posTween:stop()
				else
					posTween:play()
				end
			end
		end

		posTween.OnUpdate = function()
			Box:reposition(TweenedObject.Value, 0, 0, 0)
			Box:setCenter(TweenedObject.Value, 0)
		end

		return Container
	end;
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "new";
	["Arguments"] = {""};
	["Description"] = "Constructs a tween.\n\nIf the module itself is called, this method will be called instead.";
})

return {
	["Meta"] = meta;
	["Content"] = content;
}