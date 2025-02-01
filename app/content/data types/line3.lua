
local meta = {
	["Name"] = "line3";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The line3 data type";
	["Description"] = "An object representing a line3.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Properties";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "from";
	["ValueType"] = "vector3";
	["ReadOnly"] = true;
	["Description"] = "A vector3 representing the starting point of the line3.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "to";
	["ValueType"] = "vector3";
	["ReadOnly"] = true;
	["Description"] = "A vector3 representing the end point of the line3.";
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
	["Description"] = "Returns an array representing the line3, as {x1,y1,z1,x2,y2,z1}.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "clone";
	["Arguments"] = {};
	["Description"] = "Creates a new line3 using the same parameters as the current line3.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "closestTo";
	["Arguments"] = {"vector3"};
	["Description"] = "Returns a position on the line3 that is closest to the given vector3.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "getCenter";
	["Arguments"] = {};
	["Description"] = "Returns a vector3 that is at the center position of the line3.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "getLength";
	["Arguments"] = {};
	["Description"] = "Returns the length of the line3.";
})


table.insert(content, {
	["Type"] = "Method";
	["Name"] = "intersectSphere";
	["Arguments"] = {"pos", "radius"};
	["Description"] = "Checks if the line3 intersects a sphere located at 'pos' with a radius of 'radius' units. Returns true if so, otherwise false.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "toVector3";
	["Arguments"] = {};
	["Description"] = "Returns a new vector3 that is the end point minus the starting point.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "unpack";
	["Arguments"] = {};
	["Description"] = "The same as the :array() method, but this returns a tuple as opposed to a table.";
})



table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "__add";
	["Arguments"] = {"line3", "line3"};
	["Description"] = "Adds two line3s together. The 'from' and 'to' properties of the two input line3s are added together.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "__eq";
	["Arguments"] = {"line3"};
	["Description"] = "Returns true if the two compared objects are both line3 instances with the same start and end points.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "__sub";
	["Arguments"] = {"line3", "line3"};
	["Description"] = "Subtracts the second line3 from the first line3. The 'from' and 'to' properties of the two input line3s are subtracted from each other.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "__tostring";
	["Arguments"] = {};
	["Description"] = "Returns a string which is the line3 in the form {vector3,vector3} where the first vector3 is the starting point and the second vector3 is the end point.";
})


return {
	["Meta"] = meta;
	["Content"] = content;
}