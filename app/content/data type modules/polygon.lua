
local meta = {
	["Name"] = "polygon";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The polygon Module";
	["Description"] = "A module used to construct 2d polygons.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Constructors";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "new";
	["Arguments"] = {"..."};
	["Description"] = "Constructs a polygon with a number of vertices equal to the number of arguments passed. Each argument must be a vector2. A polygon can only be constructed if at least 3 vector2s are supplied.";
	["CodeMarkup"] = "<k>local</k> poly = <f>polygon</f>(\n\t<f>vector2</f>(<n>20</n>, <n>50</n>),\n\t<f>vector2</f>(<n>70</n>, <n>15</n>),\n\t<f>vector2</f>(<n>120</n>, <n>30</n>),\n\t<f>vector2</f>(<n>135</n>, <n>70</n>),\n\t<f>vector2</f>(<n>80</n>, <n>80</n>)\n)\n<k>for</k> i = <n>1</n>, <k>#</k>poly.Lines <k>do</k>\n\tlove.graphics.<f>line</f>(\n\t\tpoly.Lines[i].from.x,\n\t\tpoly.Lines[i].from.y,\n\t\tpoly.Lines[i].to.x,\n\t\tpoly.Lines[i].to.y\n\t)\n<k>end</k>";
	["Demo"] = function()
		local Canvas = love.graphics.newCanvas(150, 100)
		Canvas:renderTo(
			function()
				love.graphics.setLineWidth(2)
				love.graphics.setColor(0, 0, 0)
				love.graphics.rectangle("fill", 0, 0, 150, 90)
				love.graphics.setColor(1, 1, 1)
				local poly = polygon(vector2(20, 50), vector2(70, 15), vector2(120, 30), vector2(135, 70), vector2(80, 80))
				for i = 1, #poly.Lines do
					love.graphics.line(poly.Lines[i].from.x, poly.Lines[i].from.y, poly.Lines[i].to.x, poly.Lines[i].to.y)
				end
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
	["Name"] = "isPolygon";
	["Arguments"] = {"Object"};
	["Description"] = "Checks if the given object is a polygon instance. Returns true if so.";
})

return {
	["Meta"] = meta;
	["Content"] = content;
}