
local meta = {
	["Name"] = "triangle";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The triangle data type";
	["Description"] = "An object representing a 2D triangle. Internally, a triangle is constructed from a 3 line variables.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Properties";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "Line1";
	["ValueType"] = "line";
	["ReadOnly"] = true;
	["Description"] = "The first edge of the triangle.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "Line2";
	["ValueType"] = "line";
	["ReadOnly"] = true;
	["Description"] = "The second edge of the triangle.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "Line3";
	["ValueType"] = "line";
	["ReadOnly"] = true;
	["Description"] = "The third edge of the triangle.";
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
	["Description"] = "Creates and returns a new triangle with the same structure.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "closestTo";
	["Arguments"] = {"vector"};
	["Description"] = "Returns the point on the triangle closest to the given vector. If the given vector is inside of the triangle, the returned vector will share the same coordinates.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "dist";
	["Arguments"] = {"vector"};
	["Description"] = "Returns the distance between the given vector and the point on the triangle closest to the given vector. If the vector is inside the triangle, the distance is 0.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "encloses";
	["Arguments"] = {"vector"};
	["Description"] = "Returns true if the given vector is inside of the triangle.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "getPerimeter";
	["Arguments"] = {};
	["Description"] = "Returns the sum of the lengths of the three edges that make up the triangle.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "getPoints";
	["Arguments"] = {};
	["Description"] = "Returns an array of vector values that represent the corners of the triangle.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "getSurfaceArea";
	["Arguments"] = {};
	["Description"] = "Returns the total surface area covered by the triangle.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "intersectLine";
	["Arguments"] = {"line"};
	["Description"] = "Returns the points at which the triangle intersects the given line. If there were no intersections, this returns nil. Otherwise it returns one or two vectors depending on where the triangle was intersected.";
	["Demo"] = function()
		local tri = triangle(vector(16, 84), vector(51, 12), vector(84, 60))
		local l = line(vector(11, 36), vector(85, 80))
		local v1, v2 = tri:intersectLine(l)
		local Screen = love.graphics.newCanvas(100, 100)
		Screen:renderTo(
			function()
				local lw = love.graphics.getLineWidth()
				local r, g, b, a = love.graphics.getColor()
				love.graphics.setLineWidth(3)
				love.graphics.polygon("line", tri:unpack())
				love.graphics.setLineWidth(2)
				love.graphics.setColor(0, 1, 1)
				love.graphics.line(l.from.x, l.from.y, l.to.x, l.to.y)
				love.graphics.setLineWidth(lw)
				love.graphics.setColor(1, 0, 0)
				love.graphics.circle("fill", v1.x, v1.y, 5)
				love.graphics.circle("fill", v2.x, v2.y, 5)
				love.graphics.setColor(r, g, b, a)
			end
		)
		local Image = love.graphics.newImage(Screen:newImageData())
		local ImgFrame = ui.newImageFrame(Image)
		return ImgFrame
	end
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "unpack";
	["Arguments"] = {};
	["Description"] = "Returns the triangle's coordinates as six individual variables: x1, y1, x2, y2, x3, y3.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "__add";
	["Arguments"] = {"vector"};
	["Description"] = "Move the triangle along the x and y axis by the given vector.";
	["CodeMarkup"] = "<k>local</k> p1 <k>=</k> <f>triangle</f>(<f>vector</f>(<n>60</n>, <n>15</n>), <f>vector</f>(<n>20</n>, <n>70</n>), <f>vector</f>(<n>90</n>, <n>45</n>))\n<k>local</k> p2 <k>=</k> p1 <k>+</k> <f>vector</f>(<n>50</n>, <n>15</n>)\nlove.graphics.<f>polygon</f>(<s>\"line\"</s>, p1:<f>unpack</f>())\nlove.graphics.<f>polygon</f>(<s>\"line\"</s>, p2:<f>unpack</f>())";
	["Demo"] = function()
		local p1 = triangle(vector(60, 15), vector(20, 70), vector(90, 45))
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
	["Description"] = "Move the triangle along the x and y axis by the inverse of the given vector.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "__tostring";
	["Arguments"] = {};
	["Description"] = "Returns the triangle as a string.";
})


return {
	["Meta"] = meta;
	["Content"] = content;
}