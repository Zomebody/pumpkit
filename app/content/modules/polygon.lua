
local meta = {
	["Name"] = "polygon";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The polygon Module";
	["Description"] = "A module used to construct polygons.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Constructors";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "new";
	["Arguments"] = {"vector1, vector2, vector3, ..."};
	["Description"] = "Constructs a polygon from at least 3 vectors.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "isPolygon";
	["Arguments"] = {"Object"};
	["Description"] = "Checks if the given object is a polygon instance. Returns true if so.";
})

return {
	["Meta"] = meta;
	["Content"] = content;
}