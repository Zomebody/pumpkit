
local meta = {
	["Name"] = "triangle";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The triangle Module";
	["Description"] = "A module used to construct 2d triangles.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Constructors";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "new";
	["Arguments"] = {"vec1", "vec2", "vec3"};
	["Description"] = "Constructs a triangle using the three input vector2s.";
	["CodeMarkup"] = "<k>local</k> tri = <f>triangle</f>(\n\t<f>vector2</f>(<n>20</n>, <n>50</n>),\n\t<f>vector2</f>(<n>70</n>, <n>15</n>),\n\t<f>vector2</f>(<n>120</n>, <n>80</n>)\n)\nlove.graphics.<f>line</f>(\n\ttri.Line1.from.x,\n\ttri.Line1.from.y,\n\ttri.Line2.from.x,\n\ttri.Line2.from.y,\n\ttri.Line3.from.x,\n\ttri.Line3.from.y,\n\ttri.Line1.from.x,\n\ttri.Line1.from.y\n)";
	["Demo"] = function()
		local Canvas = love.graphics.newCanvas(150, 100)
		Canvas:renderTo(
			function()
				love.graphics.setLineWidth(2)
				love.graphics.setColor(0, 0, 0)
				love.graphics.rectangle("fill", 0, 0, 140, 90)
				love.graphics.setColor(1, 1, 1)
				local tri = triangle(vector2(20, 50), vector2(70, 15), vector2(120, 80))
				love.graphics.line(tri.Line1.from.x, tri.Line1.from.y, tri.Line2.from.x, tri.Line2.from.y, tri.Line3.from.x, tri.Line3.from.y, tri.Line1.from.x, tri.Line1.from.y)
				love.graphics.setColor(1, 1, 1)
			end
		)
		return ui.newImageFrame(Canvas)
	end
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "isTriangle";
	["Arguments"] = {"Object"};
	["Description"] = "Checks if the given object is a triangle instance. Returns true if so.";
})

return {
	["Meta"] = meta;
	["Content"] = content;
}