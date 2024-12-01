
local meta = {
	["Name"] = "vector3";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The vector3 Module";
	["Description"] = "A module used to construct vector3s.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Constructors";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "new";
	["Arguments"] = {"x", "y", "z"};
	["Description"] = "Constructs a vector with the given x, y and z values.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "random";
	["Arguments"] = {};
	["Description"] = "Creates a new vector3 with a magnitude of 1, rotated in a random direction.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "isVector3";
	["Arguments"] = {"Object"};
	["Description"] = "Checks if the given object is a vector3 instance. Returns true if so.";
})

return {
	["Meta"] = meta;
	["Content"] = content;
}