
local meta = {
	["Name"] = "camera";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The camera Module";
	["Description"] = "A module used to create Camera instances.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Constructors";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "new";
	["Arguments"] = {};
	["Description"] = "Creates a new camera instance focused on position (0,0) with a zoom of 1.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "initialize";
	["Arguments"] = {};
	["Description"] = "FOR INTERNAL USE ONLY. Initializes the camera module. This is automatically called when the framework is loaded.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "isCamera";
	["Arguments"] = {"Object"};
	["Description"] = "Checks if the given object is a camera instance. Returns true if so.";
})

return {
	["Meta"] = meta;
	["Content"] = content;
}