
local meta = {
	["Name"] = "line2";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The line2 Module";
	["Description"] = "A module used to construct line2s.";
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
	["Description"] = "Constructs a line2 starting at the vector2 'from' with the end point at vector2 'to'. Alternatively, 4 numbers can be passed (x1,y1,x2,y2) to construct a line2. The example below illustrates a line2 and its normal pointing out of its center.";
	["Demo"] = function()
		local Canvas = love.graphics.newCanvas(120, 100)
		Canvas:renderTo(
			function()
				love.graphics.setLineWidth(2)
				love.graphics.setColor(0, 0, 0)
				love.graphics.rectangle("fill", 0, 0, 150, 90)
				love.graphics.setColor(1, 1, 1)
				local l = line2(20, 20, 100, 80)
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
	["Name"] = "isLine2";
	["Arguments"] = {"Object"};
	["Description"] = "Checks if the given object is a line2 instance. Returns true if so.";
})

return {
	["Meta"] = meta;
	["Content"] = content;
}