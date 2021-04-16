

local ui = require("framework.ui")
local vector = require("framework.datatypes.vector")
local color = require("framework.datatypes.color")
local animation = require("framework.datatypes.animation")


local meta = {
	["Name"] = "(m) animation";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The animation Module";
	["Description"] = "A module used to construct animation data types.\n\nAnimations created with this module are singular animations. If you want to create an entity that requires multiple animations, you will need to create multiple animation objects. However, you could reuse the same sprite sheet or image for the different animations!";
	--["CodeMarkup"] = "";
	--["Demo"] = function()
		
	--end;
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Properties";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "Active";
	["ValueType"] = "array";
	["ReadOnly"] = true;
	["Description"] = "A list of all active animations. An animation is active is its state is not 'idle'. This list is updated automatically.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "isAnimation";
	["Arguments"] = {"Object"};
	["Description"] = "Returns a boolean indicating if the given object is an animation object.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "initialize";
	["Arguments"] = {};
	["Description"] = "Initializes the animation system to play animations during every update loop using Monkey Patching. This method should be called once when the game is loaded.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "new";
	["Arguments"] = {};
	["Description"] = "Used to create a new animation object. If the module itself is called, this method will be called instead.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "update";
	["Arguments"] = {};
	["Description"] = "Updates all animation objects that are currently active. This method is called automatically internally each update loop if the :initialize() method has been called.";
})



return {
	["Meta"] = meta;
	["Content"] = content;
}