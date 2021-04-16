

local ui = require("framework.ui")
local vector = require("framework.datatypes.vector")
local color = require("framework.datatypes.color")
local animation = require("framework.datatypes.animation")


local meta = {
	["Name"] = "animation";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The animation data type";
	["Description"] = "An object representing a single animation.";
	["Demo"] = function()
		local Driller = love.graphics.newImage("test_images/drillanim.png")
		Driller:setFilter("nearest", "nearest")
		local Animation = animation(Driller, 16, 16, nil, 16, true)
		-- Alternative
		-- local Animation = animation(Driller, 24, 24, {5, 1, 6, 1, 7, 1, 8, 1, 9, 1, 10, 1}, 10, true)
		local AnimFrame = ui.newAnimatedFrame(Animation, 98, 98)
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
	["Name"] = "CurrentFrame";
	["ValueType"] = "number";
	["ReadOnly"] = true;
	["Description"] = "The current frame number that is active and will be returned by :getSprite().";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "FrameCoordinates";
	["ValueType"] = "Vector array";
	["ReadOnly"] = true;
	["Description"] = "An array of vectors containing (in order) the top left pixel coordinates where each frame is located in the reference image.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "FrameCount";
	["ValueType"] = "number";
	["ReadOnly"] = true;
	["Description"] = "The total number of frames in the animation.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "FrameDuration";
	["ValueType"] = "number";
	["ReadOnly"] = true;
	["Description"] = "The duration of each frame in seconds.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "FrameHeight";
	["ValueType"] = "number";
	["ReadOnly"] = true;
	["Description"] = "The height of the animation in pixels.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "FrameWidth";
	["ValueType"] = "number";
	["ReadOnly"] = true;
	["Description"] = "The width of the animation in pixels.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "Looped";
	["ValueType"] = "boolean";
	["ReadOnly"] = false;
	["Description"] = "A boolean indicating whether or not the animation will automatically loop after it reaches the end.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "MarkedFrames";
	["ValueType"] = "Dictionary";
	["ReadOnly"] = true;
	["Description"] = "A key-value dictionary containing as keys the frame numbers and as values the string they are marked with.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "ReferenceImage";
	["ValueType"] = "Image";
	["ReadOnly"] = true;
	["Description"] = "A reference to the image object that represents the animation's sprite sheet.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "Quad";
	["ValueType"] = "Quad";
	["ReadOnly"] = true;
	["Description"] = "A quad object that will be used to display the right frame of the animation.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "State";
	["ValueType"] = "string";
	["ReadOnly"] = true;
	["Description"] = "The current state of the animation, which is one of: \"idle\", \"playing\" or \"paused\".";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "TimePlayed";
	["ValueType"] = "number";
	["ReadOnly"] = true;
	["Description"] = "The total seconds that the animation has been active for since the start. This property resets to zero when the animation loops. This is used to calculate the current frame.";
})


table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})


table.insert(content, {
	["Type"] = "Method";
	["Name"] = "getSize";
	["Arguments"] = {};
	["Description"] = "Returns the width and height of the animation's frames";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "getSprite";
	["Arguments"] = {};
	["Description"] = "Returns the reference image followed by a quad positioned at the current frame of the animation.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "markFrame";
	["Arguments"] = {"frameNumber", "name"};
	["Description"] = "Marks the given frame number with a certain name (string). When a marked frame is reached, the OnFrameReached callback will be triggered.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "pause";
	["Arguments"] = {};
	["Description"] = "Pauses the animation. The animation's state must be \"idle\" for it to get paused.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "play";
	["Arguments"] = {};
	["Description"] = "Plays the animation. The animation must be in \"idle\" state to be played.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "resume";
	["Arguments"] = {};
	["Description"] = "Resumes the animation. The animation must not be playing to be resumed.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "stop";
	["Arguments"] = {};
	["Description"] = "Stops the animation if it is not in \"idle\" state.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "update";
	["Arguments"] = {"dt"};
	["Description"] = "Updates the animation. This will already be called automatically internally when the animation module is initialized.";
})


table.insert(content, {
	["Type"] = "Method";
	["Name"] = "__tostring";
	["Arguments"] = {};
	["Description"] = "Prints the current frame, frame count, animation size and if the animation is looped";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Callbacks";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Callback";
	["Name"] = "OnEndReached";
	["Arguments"] = {};
	["Description"] = "Called right after the animation completed its last frame. If the last frame is skipped due to low frame rates, this callback should still be called.";
})

table.insert(content, {
	["Type"] = "Callback";
	["Name"] = "OnFrameReached";
	["Arguments"] = {"frameName"};
	["Description"] = "Called anytime a marked frame is reached. The frameName argument contains the name that the frame was marked with. This can be useful for enabling/disabling state transitions and such.";
})


return {
	["Meta"] = meta;
	["Content"] = content;
}