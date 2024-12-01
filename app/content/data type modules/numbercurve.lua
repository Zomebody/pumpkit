
local meta = {
	["Name"] = "line";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The numbercurve Module";
	["Description"] = "A module used to construct number curves. A numbercurve is a datatype which stores a curve going from 0 to 1 with points in that range that can have any numeric value.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Constructors";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "new";
	["Arguments"] = {"x1", "number", "x2", "number", "..."};
	["Description"] = "Constructs a numbercuve.\n\nEvery odd-numbered arguments are timestamps. The first one needs to be 0. The last one needs to be 1. They must also be in order from low to high.\n\nEvery even-numbered argument must be a number. It can be any number.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "isNumbercurve";
	["Arguments"] = {"Object"};
	["Description"] = "Checks if the given object is a numbercurve instance. Returns true if so.";
})

return {
	["Meta"] = meta;
	["Content"] = content;
}