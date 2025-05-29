
local meta = {
	["Name"] = "bezier";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The bezier data type";
	["Description"] = "An object representing a bezier curve of any number of dimensions, depending on how it is constructed.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Properties";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "Points";
	["ValueType"] = "array";
	["ReadOnly"] = true;
	["Description"] = "An array of vector2 instances that make up the bezier curve.";
})


table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "array";
	["Arguments"] = {};
	["Description"] = "Returns the bezier curve's points in the form {x1, y1, x2, y2, ...}";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "clone";
	["Arguments"] = {};
	["Description"] = "Creates and returns a new bezier with the same structure.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "getPoint";
	["Arguments"] = {"x"};
	["Description"] = "Returns the point on the curve at position 'x', where 'x' is between 0 and 1. Returned points are not equally spaced. x=0 is the start of the bezier curve and x=1 is the end of the curve.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "getVelocityAt";
	["Arguments"] = {"a", "t"};
	["Description"] = "Assuming 'a' is an alpha between 0 and 1 that describes the position on the curve and 't' is how long it takes to fully move across the curve, this method returns the velocity at the given point 'a'.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "unpack";
	["Arguments"] = {};
	["Description"] = "Returns the bezier curve's points as a tuple in the form x1, y1, x2, y2, ...";
})


return {
	["Meta"] = meta;
	["Content"] = content;
}