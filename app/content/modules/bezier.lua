
local meta = {
	["Name"] = "bezier";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The bezier Module";
	["Description"] = "A module used to construct bezier curves.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Constructors";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "new";
	["Arguments"] = {"vector1", "vector2", "vector3", "..."};
	["Description"] = "Constructs a bezier curve between the given list of points. Either a tuple of vectors or an array of numbers can be passed. At least 1 argument must be passed.";
	["Demo"] = function()
		local Canvas = love.graphics.newCanvas(120, 100, {["msaa"] = 4})
		Canvas:renderTo(
			function()
				local v1 = vector(10, 10)
				local v2 = vector(110, 10)
				local v3 = vector(110, 70)
				local v4 = vector(50, 90)

				love.graphics.setLineWidth(2)

				local bcurve = bezier(v1, v2, v3, v4)
				local ps = {0, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95, 1}
				for i = 1, #ps - 1 do
					local p1 = bcurve:getPoint(ps[i])
					local p2 = bcurve:getPoint(ps[i + 1])
					love.graphics.line(p1.x, p1.y, p2.x, p2.y)
				end

				love.graphics.setColor(1, 0, 0)
				love.graphics.circle("fill", v1.x, v1.y, 3)
				love.graphics.circle("fill", v2.x, v2.y, 3)
				love.graphics.circle("fill", v3.x, v3.y, 3)
				love.graphics.circle("fill", v4.x, v4.y, 3)


				love.graphics.setColor(1, 1, 1)
				love.graphics.setLineWidth(1)
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
	["Name"] = "isBezier";
	["Arguments"] = {"Object"};
	["Description"] = "Checks if the given object is a bezier instance. Returns true if so.";
})

return {
	["Meta"] = meta;
	["Content"] = content;
}