
local meta = {
	["Name"] = "matrix4";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The matrix4 data type";
	["Description"] = "An object representing a 4x4 matrix.";
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
	["Description"] = "The second cell.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "[3]";
	["ValueType"] = "number";
	["ReadOnly"] = true;
	["Description"] = "The third cell.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "[4]";
	["ValueType"] = "number";
	["ReadOnly"] = true;
	["Description"] = "The fourth (top-right) cell.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "[5]";
	["ValueType"] = "number";
	["ReadOnly"] = true;
	["Description"] = "The fifth cell.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "[6]";
	["ValueType"] = "number";
	["ReadOnly"] = true;
	["Description"] = "The sixth cell.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "[7]";
	["ValueType"] = "number";
	["ReadOnly"] = true;
	["Description"] = "The seventh cell.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "[8]";
	["ValueType"] = "number";
	["ReadOnly"] = true;
	["Description"] = "The eight cell.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "[9]";
	["ValueType"] = "number";
	["ReadOnly"] = true;
	["Description"] = "The ninth cell.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "[10]";
	["ValueType"] = "number";
	["ReadOnly"] = true;
	["Description"] = "The tenth cell.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "[11";
	["ValueType"] = "number";
	["ReadOnly"] = true;
	["Description"] = "The eleventh cell.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "[12]";
	["ValueType"] = "number";
	["ReadOnly"] = true;
	["Description"] = "The twelfth cell.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "[13]";
	["ValueType"] = "number";
	["ReadOnly"] = true;
	["Description"] = "The thirteeth (bottom-left) cell.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "[14]";
	["ValueType"] = "number";
	["ReadOnly"] = true;
	["Description"] = "The fourteenth cell.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "[15]";
	["ValueType"] = "number";
	["ReadOnly"] = true;
	["Description"] = "The fifteenth cell.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "[16]";
	["ValueType"] = "number";
	["ReadOnly"] = true;
	["Description"] = "The sixteenth (bottom-right) cell.";
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
	["Description"] = "Returns the first, second, third and fourth column of the matrix as arrays in order.";
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
	["Name"] = "rotateX";
	["Arguments"] = {"angle"};
	["Description"] = "Returns a matrix4 that is rotated along the global x-axis by the given amount.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "rotateY";
	["Arguments"] = {"angle"};
	["Description"] = "Returns a matrix4 that is rotated along the global y-axis by the given amount.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "rotateZ";
	["Arguments"] = {"angle"};
	["Description"] = "Returns a matrix4 that is rotated along the global z-axis by the given amount.";
})


table.insert(content, {
	["Type"] = "Method";
	["Name"] = "rows";
	["Arguments"] = {};
	["Description"] = "Returns the first, second and third row of the matrix as arrays in order.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "toEuler";
	["Arguments"] = {"order"};
	["Description"] = "Returns a vector3 describing the matrix's rotation. 'order' must be a string that is either 'xyz', 'yxz' or 'zyx' that describes the order in which the rotation takes place.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "toWorldVector";
	["Arguments"] = {"vector3"};
	["Description"] = "Assuming the given vector is a direction vector in the matrix's space, this method returns the vector translated back to world-space.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "translate";
	["Arguments"] = {"vector3"};
	["Description"] = "Moves the matrix4's position component in world-space.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "transpose";
	["Arguments"] = {};
	["Description"] = "Returns the transpose of the matrix.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "unpack";
	["Arguments"] = {};
	["Description"] = "Returns a tuple of all 9 numbers in the matrix, in reading order from top-left to bottom-right.";
})





table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "__add";
	["Arguments"] = {"matrix4"};
	["Description"] = "Adds each cell of the matrix4 to the same cell of another matrix4.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "__eq";
	["Arguments"] = {"matrix4"};
	["Description"] = "Returns true if the two matrix4's contain the same values in the same positions.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "__mul";
	["Arguments"] = {"matrix4"};
	["Description"] = "Multiplies the matrix4 with another matrix4.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "__mul";
	["Arguments"] = {"number"};
	["Description"] = "Scales the matrix4 by the given amount.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "__mul";
	["Arguments"] = {"vector3"};
	["Description"] = "Multiplies the matrix4 with the given vector4.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "__sub";
	["Arguments"] = {"matrix4"};
	["Description"] = "Subtract each cell of another matrix4 from the same cell of this matrix4.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "__tostring";
	["Arguments"] = {};
	["Description"] = "Prints the matrix4 in row-major order.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "__unm";
	["Arguments"] = {};
	["Description"] = "Returns a new matrix4 that is an inverted copy.";
})


return {
	["Meta"] = meta;
	["Content"] = content;
}