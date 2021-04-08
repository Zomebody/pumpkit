

local ui = require("framework.ui")
local vector = require("framework.datatypes.vector")
local color = require("framework.datatypes.color")


local meta = {
	["Name"] = "Frame";
	["SuperClass"] = "UIBase";
}

local content = {}

table.insert(content, {
	["Type"] = "Header";
	["Name"] = meta.Name;
	["Note"] = "Extends " .. meta.SuperClass;
	["Description"] = "A plain interface element with a color, which can also hold text. It is basically the same as a UIBase, except it has a :draw() method.";
	["CodeMarkup"] = "<k>local</k> frame = ui.<f>newFrame</f>(<n>170</n>, <n>50</n>, <f>color</f>(<n>0.6</n>, <n>0.6</n>, <n>0.6</n>))\nframe:<f>setBorder</f>(<n>3</n>)\nframe.BorderColor = <f>color</f>(<n>0.4</n>, <n>0.4</n>, <n>0.4)</n>\nframe:<f>setText</f>(<s>\"Roundabout.ttf\"</s>, <s>\"An example frame\"</s>, <n>20</n>)\nframe.TextBlock:<f>alignX</f>(<s>\"center\"</s>)\nframe.TextBlock:<f>alignY</f>(<s>\"center\"</s>)";
	["Demo"] = function() -- function that creates and returns an element to be placed right below the code example
		local frame = ui.newFrame(170, 50, color(0.6, 0.6, 0.6))
		frame:setBorder(3)
		frame.BorderColor = color(0.4, 0.4, 0.4)
		frame:setText("Roundabout.ttf", "An example frame", 20)
		frame.TextBlock:alignX("center")
		frame.TextBlock:alignY("center")
		return frame;
	end;
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "draw";
	["Arguments"] = {};
	["Description"] = "Draws the object on the screen. This is called automatically by the UI system each frame.";
})

return {
	["Meta"] = meta;
	["Content"] = content;
}