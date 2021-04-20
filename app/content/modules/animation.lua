

local getpath = require("framework.getpath")
local ui = require(getpath("framework/modules/ui"))
local vector = require(getpath("framework/datatypes/vector"))
local color = require(getpath("framework/datatypes/color"))
local animation = require(getpath("framework/modules/animation"))


local meta = {
	["Name"] = "animation";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The animation Module";
	["Description"] = "A module used to construct animation data types.\n\nAnimations created with this module are singular animations. If you want to create an entity that requires multiple animations, you will need to create multiple animation objects. However, you could reuse the same sprite sheet or image for the different animations!";
	["CodeMarkup"] = "<k>local</k> Dino = love.graphics.<f>newImage</f>(<s>\"test_images/DinoSprites.png\"</s>)\nDino:<f>setFilter</f>(<s>\"nearest\"</s>, <s>\"nearest\"</s>)\n<k>local</k> Animation = <f>animation</f>(Dino, <n>24</n>, <n>24</n>, {<f>vector</f>(<n>5</n>, <n>1</n>), <f>vector</f>(<n>6</n>, <n>1</n>), <f>vector</f>(<n>7</n>, <n>1</n>), <f>vector</f>(<n>8</n>, <n>1</n>), <f>vector</f>(<n>9</n>, <n>1</n>), <f>vector</f>(<n>10</n>, <n>1</n>)}, <n>10</n>, <b>true</b>)\n<c>-- Alternative</c>\n<c> local Animation = animation(Dino, 24, 24, {5, 1, 6, 1, 7, 1, 8, 1, 9, 1, 10, 1}, 10, true)</c>\n<k>local</k> AnimFrame = ui.<f>newAnimatedFrame</f>(Animation, <n>128</n>, <n>128</n>)\nAnimation:<f>play</f>()";
	["Demo"] = function()
		local Dino = love.graphics.newImage("test_images/DinoSprites.png")
		Dino:setFilter("nearest", "nearest")
		local Animation = animation(Dino, 24, 24, {vector(5, 1), vector(6, 1), vector(7, 1), vector(8, 1), vector(9, 1), vector(10, 1)}, 10, true)
		-- Alternative
		-- local Animation = animation(Dino, 24, 24, {5, 1, 6, 1, 7, 1, 8, 1, 9, 1, 10, 1}, 10, true)
		local AnimFrame = ui.newAnimatedFrame(Animation, 128, 128)
		Animation:play()
		return AnimFrame
	end;
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
	["Arguments"] = {"refImg", "width", "height", "order", "playSpeed", "looped"};
	["Description"] = "Used to create a new animation object. If the module itself is called, this method will be called instead.\n- refImg is the reference image sprite sheet.\n- width is the frame width.\n- height is the frame height. If nil, the image height is used.\n- order is an array of vectors containing, in order, the locations of each frame. Top left is vector(1,1), The one to its right is vector(2,1) and so on. Alternatively, vectors can be replaced with {x,y} tables or x,y tuples. If nil, frames are ordered in reading order.\n- playSpeed is the animation play speed in frames per second, or 8fps if nil.\n- looped is a boolean indicating if the animation should loop, defaulted to false.";
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