
local meta = {
	["Name"] = "gradient";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The gradient Module";
	["Description"] = "A module used to construct gradients.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Constructors";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "new";
	["Arguments"] = {"number, color, number, color, ..."};
	["Description"] = "Constructs a gradient from at least 2 numbers and colors. The numbers must be supplied in ascending order where the first number is always 0 and the last number is always 1. Each number-color pair represents a color at a given point in the gradient.\n\nAlternatively, numbers and colors may be grouped and supplied in tables like so: {number, color}, {number color}, ...";
	["CodeMarkup"] = "<k>local</k> imgData <k>=</k> love.image.<f>newImageData</f>(<n>200</n>, <n>1</n>)\n<k>local</k> gr <k>=</k> <f>gradient</f>(\n\t{<n>0</n>, <f>color</f>(<n>1</n>, <n>0.5</n>, <n>0</n>)},\n\t{<n>0.33</n>, <f>color</f>(<n>0</n>, <n>1</n>, <n>0.5</n>)},\n\t{<n>0.67</n>, <f>color</f>(<n>0.5</n>, <n>0</n>, <n>1</n>)},\n\t{<n>1</n>, <f>color</f>(<n>1</n>, <n>0.5</n>, <n>1</n>)}\n)\nimgData:<f>mapPixel</f>(<f>function</f>(x, y, r, g, b, a)\n\t<k>local</k> c <k>=</k> gr:<f>getColor</f>(x <k>/</k> <n>200</n>)\n\t<k>return</k> c.r, c.g, c.b, c.a\n<k>end</k>)\n<k>local</k> img <k>=</k> love.graphics.<f>newImage</f>(imgData)";
	["Demo"] = function()
		local imgData = love.image.newImageData(200, 1)
		local gr = gradient({0, color(1, 0.5, 0)}, {0.33, color(0, 1, 0.5)}, {0.67, color(0.5, 0, 1)}, {1, color(1, 0.5, 1)})
		local gr2 = gr:clone()
		imgData:mapPixel(
			function(x, y, r, g, b, a)
				local c = gr2:getColor(x / 200)
				return c.r, c.g, c.b, c.a
			end
		)
		local img = love.graphics.newImage(imgData)
		local Frame = ui.newImageFrame(img, 200, 60)
		return Frame
	end
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "isGradient";
	["Arguments"] = {"Object"};
	["Description"] = "Checks if the given object is a gradient instance. Returns true if so.";
})

return {
	["Meta"] = meta;
	["Content"] = content;
}