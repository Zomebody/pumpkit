
local meta = {
	["Name"] = "vector3";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The vector3 data type";
	["Description"] = "An object representing a 3D vector.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Properties";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "x";
	["ValueType"] = "number";
	["ReadOnly"] = true;
	["Description"] = "The x component of the vector3.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "y";
	["ValueType"] = "number";
	["ReadOnly"] = true;
	["Description"] = "The y component of the vector3.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "z";
	["ValueType"] = "number";
	["ReadOnly"] = true;
	["Description"] = "The z component of the vector3.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "angleDiff";
	["Arguments"] = {"vector3"};
	["Description"] = "Returns the smallest angle between itself and the given vector3, in radians.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "array";
	["Arguments"] = {};
	["Description"] = "Returns the vector in array form: {x,y,z}.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "clone";
	["Arguments"] = {"vector3"};
	["Description"] = "Create and return a new vector3 with the same x, y and z values as the given vector3.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "cross";
	["Arguments"] = {"vector3"};
	["Description"] = "Returns the cross product between the current vector and the passed vector.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "dist";
	["Arguments"] = {"vector3"};
	["Description"] = "Returns the Pythagorian distance between the current vector3 and the supplied vector3.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "dot";
	["Arguments"] = {"vector3"};
	["Description"] = "Returns the dot product between itself and the given vector3.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "getMag";
	["Arguments"] = {};
	["Description"] = "Calculates and returns the magnitude of the vector3, which is a simple 3D Pythagoras.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "limit";
	["Arguments"] = {"number"};
	["Description"] = "If the vector3's magnitude if higher than the given number, it is scaled down to the given number.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "norm";
	["Arguments"] = {};
	["Description"] = "Normalizes the vector3. This means the vector3 is scaled to have a magnitude of exactly 1.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "replace";
	["Arguments"] = {"vector3"};
	["Description"] = "Replace the values of itself with the values of the given vector3.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "set";
	["Arguments"] = {"x", "y", "z"};
	["Description"] = "Sets the x, y and z value of the vector3. If 'x' is a vector3, that vector's values will be copied instead.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "setMag";
	["Arguments"] = {"magnitude"};
	["Description"] = "Sets the magnitude of itself to the given value. This means the angle stays the same, but the size is scaled to fit the new magnitude. If the vector3 has a magnitude of 0, this will cause undocumented behavior.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "unpack";
	["Arguments"] = {};
	["Description"] = "Returns the x-value, y-value and z-value as 3 separate values.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "__add";
	["Arguments"] = {"vector3"};
	["Description"] = "Returns the result of the addition between two vector3s.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "__div";
	["Arguments"] = {"vector3"};
	["Description"] = "Returns the division of two vector3s.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "__eq";
	["Arguments"] = {"vector3"};
	["Description"] = "Returns true if the two vector3s have the same x, y and z values, and false otherwise.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "__mul";
	["Arguments"] = {"vector3"};
	["Description"] = "Returns the product of two vector3s.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "__sub";
	["Arguments"] = {"vector3"};
	["Description"] = "Returns the result of the subtraction between two vector3s.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "__tostring";
	["Arguments"] = {};
	["Description"] = "Prints the vector3 in the form (x,y,z).";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "__unm";
	["Arguments"] = {};
	["Description"] = "Inverts the x, y and z components of the vector3.";
})


return {
	["Meta"] = meta;
	["Content"] = content;
}