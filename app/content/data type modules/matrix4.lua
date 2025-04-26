
local meta = {
	["Name"] = "matrix4";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The matrix4 Module";
	["Description"] = "A module used to construct 4x4 matrices. Matrices are constructed and interpreted in row-major order. Individual cells can be indexed using Object[1] through Object[16].";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Constructors";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "fromEuler";
	["Arguments"] = {"vec3", "order"};
	["Description"] = "(This constructor might be broken). Creates a 4x4 rotation matrix using the vec3 as the rotation along each axis and where 'order' is a string describing the order in which rotation is applied.\n\n'order' may be one of 'xyz', 'yxz', 'zyx', 'xzy', 'yzx', 'zxy'.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "fromQuaternion";
	["Arguments"] = {"vec4"};
	["Description"] = "Constructs and returns a 4x4 identity matrix using the input vector4 as a quaternion.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "new";
	["Arguments"] = {};
	["Description"] = "Constructs and returns a 4x4 identity matrix.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "new";
	["Arguments"] = {"m1", "m2", "m3", "m4", "m5", "m6", "m7", "m8", "m9", "m10", "m11", "m12", "m13", "m14", "m15", "m16"};
	["Description"] = "Constructs and returns a matrix4 from the given 16 components, input into the matrix in reading order (left to right, starting top-left).";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "new";
	["Arguments"] = {"{n1,n2,n3,n4}", "{n5,n6,n7,n8}", "{n9,n10,n11,n12}", "{n13,n14,n15,n16}"};
	["Description"] = "Constructs and returns a matrix4 using 4 rows of input numbers.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "new";
	["Arguments"] = {"matrix4"};
	["Description"] = "Constructs and returns a matrix4 by copying over the data from the given matrix4.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "orthographic";
	["Arguments"] = {"left", "right", "top", "bottom", "far", "near"};
	["Description"] = "Returns an orthographic projection matrix where the first 4 arguments are the bounds and the last 2 arguments are the far and near plane.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "perspective";
	["Arguments"] = {"aspectRatio", "verticalFov", "farPlane", "nearPlane"};
	["Description"] = "Returns a perspective projection matrix.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "lookAtWorld";
	["Arguments"] = {"position", "direction"};
	["Description"] = "Returns a matrix4 at the given position which is rotated to face the given direction, all in world-space.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "rotationX";
	["Arguments"] = {"rot"};
	["Description"] = "Returns a rotation matrix4 with a rotation along the X-axis.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "rotationY";
	["Arguments"] = {"rot"};
	["Description"] = "Returns a rotation matrix4 with a rotation along the Y-axis.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "rotationZ";
	["Arguments"] = {"rot"};
	["Description"] = "Returns a rotation matrix4 with a rotation along the Z-axis.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "rotationZ";
	["Arguments"] = {"x", "y", "z"};
	["Description"] = "Returns a translation matrix4 with no rotation component.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "translation";
	["Arguments"] = {"vec3"};
	["Description"] = "Returns a translation matrix4 with no rotation component.";
})





table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})


table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "isMatrix4";
	["Arguments"] = {"Object"};
	["Description"] = "Checks if the given object is a matrix4 instance. Returns true if so.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "interpolate";
	["Arguments"] = {"matrixA", "matrixB", "alpha"};
	["Description"] = "Interpolates matrixA towards matrixB where alpha is a number between 0 and 1. Returns an interpolated matrix4.";
})

return {
	["Meta"] = meta;
	["Content"] = content;
}