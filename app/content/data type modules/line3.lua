
local meta = {
	["Name"] = "line3";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The line3 Module";
	["Description"] = "A module used to construct line3s.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Constructors";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "new";
	["Arguments"] = {"from", "to"};
	["Description"] = "Constructs a line3 starting at the vector3 'from' with the end point at vector3 'to'.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "isLine3";
	["Arguments"] = {"Object"};
	["Description"] = "Checks if the given object is a line3 instance. Returns true if so.";
})

return {
	["Meta"] = meta;
	["Content"] = content;
}