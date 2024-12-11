
local meta = {
	["Name"] = "range";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The range Module";
	["Description"] = "A module used to construct ranges.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Constructors";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "new";
	["Arguments"] = {"min", "max"};
	["Description"] = "Constructs a range from the minimum number 'min' to the maximum number 'max'.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "isRange";
	["Arguments"] = {"Object"};
	["Description"] = "Checks if the given object is a range instance. Returns true if so.";
})

return {
	["Meta"] = meta;
	["Content"] = content;
}