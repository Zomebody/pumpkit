
local meta = {
	["Name"] = "line2";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The line2 data type";
	["Description"] = "An object representing a line2.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Properties";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "from";
	["ValueType"] = "vector2";
	["ReadOnly"] = true;
	["Description"] = "A vector2 representing the starting point of the line2.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "normal";
	["ValueType"] = "vector2";
	["ReadOnly"] = true;
	["Description"] = "A normalized vector2 perpendicular to the direction of the line2.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "to";
	["ValueType"] = "vector2";
	["ReadOnly"] = true;
	["Description"] = "A vector2 representing the end point of the line2.";
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
	["Description"] = "Returns an array representing the line2, as {x1,y1,x2,y2}.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "clone";
	["Arguments"] = {};
	["Description"] = "Creates a new line2 using the same parameters as the current line2.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "closestLine";
	["Arguments"] = {"line2"};
	["Description"] = "Creates a new line2 that spans the shortest distance between the current line2 segment and the provided line2 segment.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "closestTo";
	["Arguments"] = {"vector2", "inf"};
	["Description"] = "Returns a position on the line2 that is closest to the given vector2. The second argument is a boolean indicating if the line2 should be treated as a line of infinite length in both directions.";
	["CodeMarkup"] = "<k>local</k> l <k>=</k> <f>line2</f>(<n>20</n>, <n>20</n>, <n>130</n>, <n>80</n>)\n<k>local</k> p <k>=</k> <f>vector2</f>(<n>40</n>, <n>70</n>)\n<k>local</k> c <k>=</k> l:<f>closestTo</f>(p)\nlove.graphics.<f>line</f>(l:<f>unpack</f>())\nlove.graphics.<f>setColor</f>(<n>1</n>, <n>0</n>, <n>0</n>)\nlove.graphics.<f>circle</f>(<s>\"fill\"</s>, p.x, p.y, <n>6</n>)\nlove.graphics.<f>setColor</f>(<n>0</n>, <n>0.5</n>, <n>1</n>)\nlove.graphics.<f>circle</f>(<s>\"fill\"</s>, c.x, c.y, <n>6</n>)";
	["Demo"] = function()
		local Canvas = love.graphics.newCanvas(150, 90)
		Canvas:renderTo(
			function()
				love.graphics.setLineWidth(2)
				love.graphics.setColor(0, 0, 0)
				love.graphics.rectangle("fill", 0, 0, 150, 90)
				local l = line2(20, 20, 130, 80)
				local p = vector2(40, 70)
				local c = l:closestTo(p)
				love.graphics.setColor(1, 1, 1)
				love.graphics.line(l:unpack())
				love.graphics.setColor(1, 0, 0)
				love.graphics.circle("fill", p.x, p.y, 6)
				love.graphics.setColor(0, 0.5, 1)
				love.graphics.circle("fill", c.x, c.y, 6)
				love.graphics.setColor(1, 1, 1)
			end
		)
		return ui.newImageFrame(Canvas)
	end;
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "dist";
	["Arguments"] = {"vector2"};
	["Description"] = "Returns the distance between the given vector2 and the point on the line2 closest to that vector2.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "getCenter";
	["Arguments"] = {};
	["Description"] = "Returns a vector2 that is at the center position of the line2.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "getLength";
	["Arguments"] = {};
	["Description"] = "Returns the length of the line2.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "getTwoParallels";
	["Arguments"] = {"distance"};
	["Description"] = "Returns two new line2 objects that are parallel to the current line2, but exactly 'distance' units away from the line2. This method can be useful for creating capsule colliders out of lines.";
	["CodeMarkup"] = "<k>local</k> l <k>=</k> <f>line2</f>(<n>30</n>, <n>40</n>, <n>130</n>, <n>80</n>)\n<k>local</k> l1, l2 <k>=</k> l:<f>getTwoParallels</f>(<n>30</n>)\nlove.graphics.<f>line</f>(l:<f>unpack</f>())\nlove.graphics.<f>setColor</f>(<n>1</n>, <n>0</n>, <n>0</n>)\nlove.graphics.<f>line</f>(l1:<f>unpack</f>())\nlove.graphics.<f>line</f>(l2:<f>unpack</f>())";
	["Demo"] = function()
		local Canvas = love.graphics.newCanvas(160, 120)
		Canvas:renderTo(
			function()
				love.graphics.setLineWidth(2)
				love.graphics.setColor(0, 0, 0)
				love.graphics.rectangle("fill", 0, 0, 160, 160)
				love.graphics.setColor(1, 1, 1)
				local l = line2(30, 40, 130, 80)
				local l1, l2 = l:getTwoParallels(30)
				love.graphics.line(l:unpack())
				love.graphics.setColor(1, 0, 0)
				love.graphics.line(l1:unpack())
				love.graphics.line(l2:unpack())
				love.graphics.setColor(1, 1, 1)
			end
		)
		return ui.newImageFrame(Canvas)
	end;
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "interpolation";
	["Arguments"] = {"alpha"};
	["Description"] = "Returns a position along the line2. If alpha is 0, it returns the starting point. If 1, it returns the end point. 0.5 is the middle, and so on.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "intersect";
	["Arguments"] = {"line2"};
	["Description"] = "If the current line2 overlaps the given line2, this returns the location of intersection. Otherwise it returns nil.";
	["CodeMarkup"] = "<k>local</k> l1 <k>=</k> <f>line2</f>(<n>20</n>, <n>50</n>, <n>110</n>, <n>75</n>)\n<k>local</k> l2 <k>=</k> <f>line2</f>(<n>35</n>, <n>100</n>, <n>130</n>, <n>25</n>)\n<k>local</k> hit <k>=</k> l1:<f>intersect</f>(l2)\nlove.graphics.<f>line</f>(l1:<f>unpack</f>())\nlove.graphics.<f>line</f>(l2:<f>unpack</f>())\nlove.graphics.<f>setColor</f>(<n>1</n>, <n>0</n>, <n>0</n>)\nlove.graphics.<f>circle</f>(<s>\"fill\"</s>, hit.x, hit.y, <n>6</n>)";
	["Demo"] = function()
		local Canvas = love.graphics.newCanvas(160, 120)
		Canvas:renderTo(
			function()
				love.graphics.setLineWidth(2)
				love.graphics.setColor(0, 0, 0)
				love.graphics.rectangle("fill", 0, 0, 160, 160)
				love.graphics.setColor(1, 1, 1)
				local l1 = line2(20, 50, 110, 75)
				local l2 = line2(35, 100, 130, 25)
				local hit = l1:intersect(l2)
				love.graphics.line(l1:unpack())
				love.graphics.line(l2:unpack())
				love.graphics.setColor(1, 0, 0)
				love.graphics.circle("fill", hit.x, hit.y, 6)
				love.graphics.setColor(1, 1, 1)
			end
		)
		return ui.newImageFrame(Canvas)
	end;
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "intersectCircle";
	["Arguments"] = {"position", "radius"};
	["Description"] = "Checks if the line2 intersects a circle at the given position vector2 with a given radius. This returns the first point of intersection (a vector2) and an integer indicating the direction of intersection. The position is the first point of intersection along the line2. The integer is '1' if the intersection started at the outside and '-1' if the intersection started from within the circle. Nil is returned if the line2 does not overlap the circle, or if the line2 is fully enclosed within the circle. If a line2 starts or end exactly on the border, it will still count as an intersection.\n\nBelow is an example of line2 intersections with the blue circle. All lines are drawn from left to right. The red dots are returned intersection vector2s.";
	["Demo"] = function()
		local Canvas = love.graphics.newCanvas(300, 160)
		Canvas:renderTo(
			function()
				love.graphics.setLineWidth(2)
				love.graphics.setColor(0, 0, 0)
				love.graphics.rectangle("fill", 0, 0, 300, 160)
				love.graphics.setColor(0, 0.5, 1)
				local cp, cr = vector2(150, 80), 42
				love.graphics.circle("fill", cp.x, cp.y, cr)
				love.graphics.setColor(1, 1, 1)
				local l1 = line2(130, 90, 150, 50)
				local l2 = line2(50, 40, 240, 125)
				local l3 = line2(165, 70, 220, 40)
				local l4 = line2(150, 150, 150, 122)
				love.graphics.line(l1:unpack())
				love.graphics.line(l2:unpack())
				love.graphics.line(l3:unpack())
				local hit1 = l1:intersectCircle(cp, cr)
				local hit2 = l2:intersectCircle(cp, cr)
				local hit3 = l3:intersectCircle(cp, cr)
				love.graphics.setColor(1, 0, 0)
				if hit1 ~= nil then
					love.graphics.circle("fill", hit1.x, hit1.y, 6)
				end
				if hit2 ~= nil then
					love.graphics.circle("fill", hit2.x, hit2.y, 6)
				end
				if hit3 ~= nil then
					love.graphics.circle("fill", hit3.x, hit3.y, 6)
				end
				love.graphics.setColor(1, 1, 1)
			end
		)
		return ui.newImageFrame(Canvas)
	end;
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "intersects";
	["Arguments"] = {"arg1", "arg2"};
	["Description"] = "If arg1 is a line2, this will return true if the two line2s intersect. Otherwise, arg1 is treated as a circle location and arg2 is treated as a circle radius. Then it will return true if the line2 intersects the circle, using the same logic as :intersectCircle().";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "moveTo";
	["Arguments"] = {"vector2", "vector2"};
	["Description"] = "Sets the starting point and end point of the line2 to the two provided vector2s (in order). This updates its normal as well.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "replace";
	["Arguments"] = {"line2"};
	["Description"] = "Replaces the properties of the current line2 with the values of the given line2.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "separates";
	["Arguments"] = {"vector2", "vector2"};
	["Description"] = "This method returns true if the two given vector2s are on opposite sides of the line2. Otherwise, it returns false.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "setMag";
	["Arguments"] = {"size"};
	["Description"] = "Sets the 'from' vector2 to be exactly 'size' units away from the 'from' vector2. The direction of the line2 remains the same.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "shift";
	["Arguments"] = {"x", "y"};
	["Description"] = "Offsets the line2 in the horizontal and vertical axis. Instead of two number, the first argument may also be a vector2.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "toVector2";
	["Arguments"] = {};
	["Description"] = "Returns a new vector2 that is the end point minus the starting point.";
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
	["Arguments"] = {"line2", "line2"};
	["Description"] = "Adds two line2s together. The 'from' and 'to' properties of the two input line2s are added together.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "__eq";
	["Arguments"] = {"line2"};
	["Description"] = "Returns true if the two compared objects are both line2 instances with the same start and end points.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "__sub";
	["Arguments"] = {"line2", "line2"};
	["Description"] = "Subtracts the second line2 from the first line2. The 'from' and 'to' properties of the two input line2s are subtracted from each other.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "__mul";
	["Arguments"] = {"line2", "number"};
	["Description"] = "Multiples the start and end point of the line by some scalar.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "__tostring";
	["Arguments"] = {};
	["Description"] = "Returns a string which is the line2 in the form {vector2,vector2} where the first vector2 is the starting point and the second vector2 is the end point.";
})


return {
	["Meta"] = meta;
	["Content"] = content;
}