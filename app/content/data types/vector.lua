
local meta = {
	["Name"] = "vector";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The vector data type";
	["Description"] = "An object representing a 2D vector.";
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
	["Description"] = "The x component of the vector.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "y";
	["ValueType"] = "number";
	["ReadOnly"] = true;
	["Description"] = "The y component of the vector.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "angleDiff";
	["Arguments"] = {"vector"};
	["Description"] = "Returns the smallest angle between itself and the given vector, in radians.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "array";
	["Arguments"] = {};
	["Description"] = "Returns the vector in array form: {x,y}.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "clamp";
	["Arguments"] = {"min", "max"};
	["Description"] = "If the vector's magnitude is smaller than min, it is scaled up to min. If the vector's magnitude is larger than max, it is scaled down to max.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "clone";
	["Arguments"] = {"vector"};
	["Description"] = "Create and return a new vector with the same x and y values as the given vector.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "dot";
	["Arguments"] = {"vector"};
	["Description"] = "Returns the dot product between itself and the given vector.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "getMag";
	["Arguments"] = {};
	["Description"] = "Calculates and returns the magnitude of the vector, which is a simple 2D Pythagoras.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "heading";
	["Arguments"] = {};
	["Description"] = "Returns the current angle of the vector in radians.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "limit";
	["Arguments"] = {"number"};
	["Description"] = "If the vector's magnitude if higher than the given number, it is scaled down to the given number.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "magSq";
	["Arguments"] = {};
	["Description"] = "Calculates and returns (x*x+y*y).";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "norm";
	["Arguments"] = {};
	["Description"] = "Normalizes the vector. This means the vector is scaled to have a magnitude of exactly 1.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "pivot";
	["Arguments"] = {"angle", "vector"};
	["Description"] = "Rotates the vector around a given vector by a given amount in radians. TODO: figure out if it's clockwise or counter-clockwise";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "projectOnto";
	["Arguments"] = {"vector"};
	["Description"] = "Projects the vector onto the given vector. This is like squiching the vector onto a surface, represented by the given factor. The example below visualizes the projection of the black vector onto the blue vector, resulting in the new red vector.";
	["Demo"] = function()
		local Image = love.graphics.newImage("test_images/projectOnto.png")
		local ImageFrame = ui.newImageFrame(Image)
		return ImageFrame
	end
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "reflect";
	["Arguments"] = {"normal", "multiplier"};
	["Description"] = "Reflects the vector along the given normal vector, which is the same as mirroring the vector along a normal and then pointing it in the opposite direction. Multiplier will apply a scaling to the reflected vector, but defaults to 1.\n\nBelow is a quick visualization where the black vector is being reflected along the blue line and then a multiplier of ~3 is applied.";
	["Demo"] = function()
		local Image = love.graphics.newImage("test_images/reflect.png")
		local ImageFrame = ui.newImageFrame(Image)
		return ImageFrame
	end
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "replace";
	["Arguments"] = {"vector"};
	["Description"] = "Replace the values of itself with the values of the given vector.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "rotate";
	["Arguments"] = {"angle"};
	["Description"] = "Rotates the vector by a given amount in radians. TODO: figure out if it's clockwise or counter-clockwise.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "rotateTo";
	["Arguments"] = {"vector", "angle"};
	["Description"] = "Rotates the vector by a given amount in radians towards another direction vector. This method will not overshoot if the amount to rotate by is larger than the angle between the two vectors.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "set";
	["Arguments"] = {"x", "y"};
	["Description"] = "Sets the x and y value of the vector. If a is a vector, that vector's values will be copied instead.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "setMag";
	["Arguments"] = {"magnitude"};
	["Description"] = "Sets the magnitude of itself to the given value. This means the angle stays the same, but the size is scaled to fit the new magnitude. If the vector has a magnitude of 0, this will cause undocumented behavior.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "stretch";
	["Arguments"] = {"vector", "factor"};
	["Description"] = "Stretches the vector along another vector by a given factor. 'factor' is a multiplier for how much the vector should be stretched. The example below is a stretch operation on the black vector along the blue vector, with a factor of -2, resulting in the red vector.";
	["Demo"] = function()
		local Image = love.graphics.newImage("test_images/stretch.png")
		local ImageFrame = ui.newImageFrame(Image)
		return ImageFrame
	end;
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "unpack";
	["Arguments"] = {};
	["Description"] = "Returns the x-value followed by the y-value.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "__add";
	["Arguments"] = {"vector"};
	["Description"] = "Returns the result of the addition between two vectors.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "__div";
	["Arguments"] = {"vector"};
	["Description"] = "Returns the division of two vectors.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "__eq";
	["Arguments"] = {"vector"};
	["Description"] = "Returns true if the two vectors have the same x and y values, and false otherwise.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "__mul";
	["Arguments"] = {"vector"};
	["Description"] = "Returns the product of two vectors.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "__sub";
	["Arguments"] = {"vector"};
	["Description"] = "Returns the result of the subtraction between two vectors.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "__tostring";
	["Arguments"] = {};
	["Description"] = "Prints the color in the form (r,g,b) where r, g and b are values from 0 to 255.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "__unm";
	["Arguments"] = {};
	["Description"] = "Inverts the x and y components of the vector.";
})


return {
	["Meta"] = meta;
	["Content"] = content;
}