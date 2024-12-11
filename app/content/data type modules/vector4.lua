
local meta = {
	["Name"] = "vector4";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The vector4 Module";
	["Description"] = "A module used to construct vector4s.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Constructors";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "new";
	["Arguments"] = {"x", "y", "z", "w"};
	["Description"] = "Constructs a vector with the given x, y, z and w values.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "isVector4";
	["Arguments"] = {"Object"};
	["Description"] = "Checks if the given object is a vector4 instance. Returns true if so.";
})

return {
	["Meta"] = meta;
	["Content"] = content;
}