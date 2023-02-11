
local meta = {
	["Name"] = "polygon";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The polygon data type";
	["Description"] = "An object representing a 2D polygon. A polygon must have at least 3 points. Internally, polygons are constructed from a collection of line variables.";
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
	["Name"] = "closestTo";
	["Arguments"] = {"vector"};
	["Description"] = "Returns the point on the polygon closest to the given vector. If the given vector is inside of the polygon, the returned vector will share the same coordinates.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "dist";
	["Arguments"] = {"vector"};
	["Description"] = "Returns the distance between the given vector and the point on the polygon closest to the given vector. If the vector is inside the polygon, the distance is 0.";
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
	["Type"] = "Constructor";
	["Name"] = "__add";
	["Arguments"] = {"vector"};
	["Description"] = "Move the polygon along the x and y axis by the given vector.";
	["CodeMarkup"] = "<k>local</k> p1 <k>=</k> <f>polygon</f>(<f>vector</f>(<n>60</n>, <n>15</n>), <f>vector</f>(<n>20</n>, <n>70</n>), <f>vector</f>(<n>90</n>, <n>45</n>))\n<k>local</k> p2 <k>=</k> p1 <k>+</k> <f>vector</f>(<n>50</n>, <n>15</n>)\nlove.graphics.<f>polygon</f>(<s>\"line\"</s>, p1:<f>unpack</f>())\nlove.graphics.<f>polygon</f>(<s>\"line\"</s>, p2:<f>unpack</f>())";
	["Demo"] = function()
		local p1 = polygon(vector(60, 15), vector(20, 70), vector(90, 45))
		local p2 = p1 + vector(50, 15)
		local Screen = love.graphics.newCanvas(150, 100)
		Screen:renderTo(
			function()
				local lw = love.graphics.getLineWidth()
				love.graphics.setLineWidth(3)
				love.graphics.polygon("line", p1:unpack())
				love.graphics.polygon("line", p2:unpack())
				love.graphics.setLineWidth(lw)
			end
		)
		local Image = love.graphics.newImage(Screen:newImageData())
		local ImgFrame = ui.newImageFrame(Image)
		return ImgFrame
	end
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "__sub";
	["Arguments"] = {"vector"};
	["Description"] = "Move the polygon along the x and y axis by the inverse of the given vector.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "__tostring";
	["Arguments"] = {};
	["Description"] = "Returns the polygon as a string.";
})


return {
	["Meta"] = meta;
	["Content"] = content;
}