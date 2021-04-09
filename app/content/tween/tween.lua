

local ui = require("framework.ui")
local vector = require("framework.datatypes.vector")
local color = require("framework.datatypes.color")


local meta = {
	["Name"] = "tween";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The tween data type";
	["Description"] = "An object representing a single tween.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Properties";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Events";
	["Description"] = "";
})


return {
	["Meta"] = meta;
	["Content"] = content;
}