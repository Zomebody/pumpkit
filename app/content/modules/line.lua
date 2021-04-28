

local getpath = require("framework.getpath")
local ui = require(getpath("framework/modules/ui"))
local vector = require(getpath("framework/datatypes/vector"))
local color = require(getpath("framework/datatypes/color"))
local line = require(getpath("framework/datatypes/line"))


local meta = {
	["Name"] = "line";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The line Module";
	["Description"] = "A module used to construct lines.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Constructors";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "new";
	["Arguments"] = {"from", "to"};
	["Description"] = "Constructs a line starting at the vector 'from' with the end point at vector 'to'. Alternatively, 4 numbers can be passed (x1,y1,x2,y2) to construct a line. The example below illustrates a line and its normal pointing out of its center.";
	["Demo"] = function()
		local Canvas = love.graphics.newCanvas(120, 100)
		Canvas:renderTo(
			function()
				love.graphics.setLineWidth(2)
				love.graphics.setColor(0, 0, 0)
				love.graphics.rectangle("fill", 0, 0, 150, 90)
				love.graphics.setColor(1, 1, 1)
				local l = line(20, 20, 100, 80)
				love.graphics.line(l:unpack())
				love.graphics.setColor(0, 0.5, 1)
				local c = l:getCenter()
				love.graphics.line(c.x, c.y, c.x + l.normal.x*16, c.y + l.normal.y*16)
				love.graphics.setColor(1, 1, 1)
			end
		)
		return ui.newImageFrame(Canvas)
	end;
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "isLine";
	["Arguments"] = {"Object"};
	["Description"] = "Checks if the given object is a line instance. Returns true if so.";
})

return {
	["Meta"] = meta;
	["Content"] = content;
}