
local meta = {
	["Name"] = "polygon";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The polygon data type";
	["Description"] = "An object representing a 2D polygon. Internally, polygons are constructed from a collection of line variables.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Properties";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "Lines";
	["ValueType"] = "array";
	["ReadOnly"] = true;
	["Description"] = "The lines that make up the polygon.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "clone";
	["Arguments"] = {};
	["Description"] = "Creates and returns a new polygon with the same structure.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "encloses";
	["Arguments"] = {"vector"};
	["Description"] = "Returns true if the given vector is inside of the polygon. This works on both convex and concave polygons.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "getPerimeter";
	["Arguments"] = {};
	["Description"] = "Returns the total length of all line segments in the polygon.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "getPoints";
	["Arguments"] = {};
	["Description"] = "Returns an array of vector values that represent the corners of the polygon.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "getSurfaceArea";
	["Arguments"] = {};
	["Description"] = "Returns the total surface area covered by the polygon.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "isConcave";
	["Arguments"] = {};
	["Description"] = "Returns true if the polygon is concave.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "isConvex";
	["Arguments"] = {};
	["Description"] = "Returns true if the polygon is convex.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "unpack";
	["Arguments"] = {};
	["Description"] = "Returns an array of numbers in the form {x1, y1, x2, y2, ...} where each xy pair is a corner of the polygon.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "__add";
	["Arguments"] = {"vector"};
	["Description"] = "Move the polygon along the x and y axis by the given vector.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "__sub";
	["Arguments"] = {"vector"};
	["Description"] = "Move the polygon along the x and y axis by the inverse of the given vector.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "__tostring";
	["Arguments"] = {};
	["Description"] = "Returns the polygon as a string.";
})


return {
	["Meta"] = meta;
	["Content"] = content;
}