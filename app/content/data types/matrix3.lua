
local meta = {
	["Name"] = "matrix3";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The matrix3 data type";
	["Description"] = "An object representing a 3x3 matrix.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Properties";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "[1]";
	["ValueType"] = "number";
	["ReadOnly"] = true;
	["Description"] = "The first (top-left) cell.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "[2]";
	["ValueType"] = "number";
	["ReadOnly"] = true;
	["Description"] = "The second (top-center) cell.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "[3]";
	["ValueType"] = "number";
	["ReadOnly"] = true;
	["Description"] = "The third (top-right) cell.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "[4]";
	["ValueType"] = "number";
	["ReadOnly"] = true;
	["Description"] = "The fourth (center-left) cell.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "[5]";
	["ValueType"] = "number";
	["ReadOnly"] = true;
	["Description"] = "The fifth (center) cell.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "[6]";
	["ValueType"] = "number";
	["ReadOnly"] = true;
	["Description"] = "The sixth (center-right) cell.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "[7]";
	["ValueType"] = "number";
	["ReadOnly"] = true;
	["Description"] = "The seventh (bottom-left) cell.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "[8]";
	["ValueType"] = "number";
	["ReadOnly"] = true;
	["Description"] = "The eight (bottom-center) cell.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "[9]";
	["ValueType"] = "number";
	["ReadOnly"] = true;
	["Description"] = "The ninth (bottom-right) cell.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})


table.insert(content, {
	["Type"] = "Method";
	["Name"] = "columns";
	["Arguments"] = {};
	["Description"] = "Returns the first, second and third column of the matrix as arrays in order.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "determinant";
	["Arguments"] = {};
	["Description"] = "Returns the determinant of the matrix.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "identity";
	["Arguments"] = {};
	["Description"] = "Resets the matrix to an identity matrix.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "inverse";
	["Arguments"] = {};
	["Description"] = "Returns a new 3x3 matrix that is the inverse of this one.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "rows";
	["Arguments"] = {};
	["Description"] = "Returns the first, second and third row of the matrix as arrays in order.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "unpack";
	["Arguments"] = {};
	["Description"] = "Returns a tuple of all 9 numbers in the matrix, in reading order from top-left to bottom-right.";
})






table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "__eq";
	["Arguments"] = {"matrix3"};
	["Description"] = "Returns true if the two matrix3's contain the same values in the same positions.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "__mul";
	["Arguments"] = {"matrix3"};
	["Description"] = "Multiplies the matrix3 with another matrix3.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "__mul";
	["Arguments"] = {"number"};
	["Description"] = "Scales the matrix by the given amount.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "__mul";
	["Arguments"] = {"vector3"};
	["Description"] = "Multiplies the matrix3 with the given vector3.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "__tostring";
	["Arguments"] = {};
	["Description"] = "Prints the matrix3 in row-major order.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "__unm";
	["Arguments"] = {};
	["Description"] = "Returns a new matrix3 that is an inverted copy.";
})


return {
	["Meta"] = meta;
	["Content"] = content;
}