

local getpath = require("framework.getpath")
local ui = require(getpath("framework/modules/ui"))
local vector = require(getpath("framework/datatypes/vector"))
local color = require(getpath("framework/datatypes/color"))
local animation = require(getpath("framework/modules/animation"))


local meta = {
	["Name"] = "AnimatedFrame";
	["SuperClass"] = "UIBase";
}

local content = {}

table.insert(content, {
	["Type"] = "Header";
	["Name"] = meta.Name;
	["Note"] = "Extends " .. meta.SuperClass;
	["Description"] = "An interface element that plays an animation. When drawn, the animation is stretched to perfectly fit within the element. The animation that is used in the constructor is taken as a reference, so any changes made to the animation are automatically reflected when the animation frame is drawn!";
	["CodeMarkup"] = "<k>local</k> img = love.graphics.<f>newImage</f>(<s>\"test_images/animation.png\"</s>)\n<k>local</k> Anim = <f>animation</f>(img, <n>150</n>, <n>nil</n>, <n>nil</n>, <n>20</n>, <b>true</b>)\n<k>local</k> animated_frame = ui.<f>newAnimatedFrame</f>(Anim)\nAnim:<f>play</f>()";
	["Demo"] = function() -- function that creates and returns an element to be placed right below the code example
		local img = love.graphics.newImage("test_images/animation.png")
		local Anim = animation(img, 150, nil, nil, 20, true)
		local animated_frame = ui.newAnimatedFrame(Anim)
		Anim:play()
		return animated_frame
	end;
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Properties";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "Animation";
	["Name"] = "ReferenceAnimation";
	["Description"] = "The animation that is displayed within the frame.";
	["ReadOnly"] = true;
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
	["Description"] = "Draws the object on the screen. This is called automatically by the UI system each frame. The given animation is stretched such that is fully covers the element's Size.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "setReference";
	["Arguments"] = {"Animation"};
	["Description"] = "Sets the reference animation to the given animation object.";
})

return {
	["Meta"] = meta;
	["Content"] = content;
}