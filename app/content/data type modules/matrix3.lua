
local meta = {
	["Name"] = "matrix3";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The matrix3 Module";
	["Description"] = "A module used to construct 3x3 matrices. Matrices are constructed and interpreted in row-major order. Individual cells can be indexed using Object[1] through Object[9].";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Constructors";
	["Description"] = "";
})



table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "new";
	["Arguments"] = {};
	["Description"] = "Constructs a 3x3 identity matrix.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "new";
	["Arguments"] = {"m1", "m2", "m3", "m4", "m5", "m6", "m7", "m8", "m9"};
	["Description"] = "Constructs a matrix3 from the given 9 components, input into the matrix in reading order (left to right, starting top-left).";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "new";
	["Arguments"] = {"number"};
	["Description"] = "Constructs a matrix3 where each cell is assigned the given number.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "new";
	["Arguments"] = {"matrix3"};
	["Description"] = "Constructs a matrix3 by copying over the data from the given matrix3.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "fromRodrigues";
	["Arguments"] = {"vec3A", "vec3B"};
	["Description"] = "Constructs a 3x3 rotation matrix that rotates any 3d vector as if it follows the angular path from direction vector A to vector B.";
})



table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})


table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "isMatrix3";
	["Arguments"] = {"Object"};
	["Description"] = "Checks if the given object is a matrix3 instance. Returns true if so.";
})

return {
	["Meta"] = meta;
	["Content"] = content;
}