
local meta = {
	["Name"] = "color";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The color Module";
	["Description"] = "A module used to construct color data types.";
	["CodeMarkup"] = "<c>-- Colors displayed from left to right</c>\n<k>local</k> orange <k>=</k> <f>color</f>(<n>1</n>, <n>0.5</n>, <n>0</n>)\n<k>local</k> blue <k>=</k> color.<f>fromHex</f>(<s>\"#007bff\"</s>)\n<k>local</k> purple <k>=</k> <f>color</f>(blue):<f>shiftHue</f>(<n>60</n>)\n<k>local</k> babyBlue <k>=</k> blue:<f>clone</f>():<f>lighten</f>(<n>0.6</n>)";
	["Demo"] = function()
		local Container = ui.newFrame(500, 100, color(1, 1, 1))
		Container.Opacity = 0

		-- create colors (displayed from left to right)
		local orange = color(1, 0.5, 0)
		local blue = color.fromHex("#007bff")
		local purple = color(blue):shiftHue(60)
		local babyBlue = blue:clone():lighten(0.6)

		local BoxOrange = ui.newFrame(100, 100, orange)
		Container:addChild(BoxOrange)
		local BoxBlue = ui.newFrame(100, 100, blue)
		BoxBlue:putNextTo(BoxOrange, "right")
		Container:addChild(BoxBlue)
		local BoxPurple = ui.newFrame(100, 100, purple)
		BoxPurple:putNextTo(BoxBlue, "right")
		Container:addChild(BoxPurple)
		local BoxBabyBlue = ui.newFrame(100, 100, babyBlue)
		BoxBabyBlue:putNextTo(BoxPurple, "right")
		Container:addChild(BoxBabyBlue)

		return Container
	end;
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "fromHex";
	["Arguments"] = {"hex"};
	["Description"] = "Constructs a color from a HEX string. The pound sign at the start is optional.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "fromHSL";
	["Arguments"] = {"h", "s", "l"};
	["Description"] = "Constructs a color from HSL values, where the hue is in the range 0-360 and the others in the range 0-1";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "fromHSV";
	["Arguments"] = {"h", "s", "v"};
	["Description"] = "Constructs a color from HSV values, where the hue is in the range 0-360 and the others in the range 0-1.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "fromRGB";
	["Arguments"] = {"r", "g", "b"};
	["Description"] = "Constructs a color from RGB values, where r, g and b are numbers in the range 0 to 255.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "new";
	["Arguments"] = {"r", "g", "b", "a"};
	["Description"] = "Constructs a color from red, green and blue components and an alpha value, all optional and between 0 and 1. If r is a string instead, it is interpreted as a Hex value.\n\nIf the module itself is called, this method will be called instead.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "interpolate";
	["Arguments"] = {"color", "color", "x"};
	["Description"] = "Returns a color that is in between the two given colors, interpolated using HSL values. 'x' is the location (between 0 and 1), where 0 is the first color, 1 is the second color and 0.5 is in the middle.";
	["Demo"] = function()
		local Container = ui.newFrame(500, 120)
		local c1 = color(1, 0.5, 0.5)
		local c2 = color(0, 1, 0.75)
		local imgData = love.image.newImageData(500, 90)
		imgData:mapPixel(
			function(x, y, r, g, b, a)
				local v = x/500
				local interColor = color.interpolate(c1, c2, v)
				return interColor.r, interColor.g, interColor.b
			end
		)
		local TextLabel1 = ui.newFrame(250, 30, color(0, 0, 0, 0))
		TextLabel1:setPadding(4)
		TextLabel1:setText("LieraSansMedium.ttf", {{0, 0, 0}, tostring(c1)}, 16)
		TextLabel1.TextBlock:alignX("left")
		TextLabel1.TextBlock:alignY("center")
		local TextLabel2 = ui.newFrame(250, 30, color(0, 0, 0, 0))
		TextLabel2:setPadding(4)
		TextLabel2:setText("LieraSansMedium.ttf", {{0, 0, 0}, tostring(c2)}, 16)
		TextLabel2.TextBlock:alignX("right")
		TextLabel2.TextBlock:alignY("center")
		TextLabel2:alignX("right")

		local img = love.graphics.newImage(imgData)
		local ColorFrame = ui.newImageFrame(img)
		ColorFrame:alignY("bottom")
		Container:addChild(ColorFrame)
		Container:addChild(TextLabel1)
		Container:addChild(TextLabel2)
		local label1
		return Container
	end
})

table.insert(content, {
	["Type"] = "Function";
	["Name"] = "isColor";
	["Arguments"] = {"Object"};
	["Description"] = "Checks if the given object is a color instance. Returns true if so.";
})

table.insert(content, {
	["Type"] = "Function";
	["Name"] = "isHex";
	["Arguments"] = {"string"};
	["Description"] = "Checks if the given string is in HEX format, which is an optional hashtag followed by 6 valid hex characters.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "random";
	["Arguments"] = {};
	["Description"] = "Creates a color with random r, g and b values. The hue is completely random, but the value and saturation are slightly biased towards 1.\n\nThe following colors are all randomly generated during the start-up of this program.";
	["Demo"] = function()
		local Container = ui.newFrame(500, 200)
		for x = 0, 9 do
			for y = 0, 3 do
				local ColorFrame = ui.newFrame(50, 50, color.random())
				ColorFrame:reposition(0, 0, x * 50, y * 50)
				Container:addChild(ColorFrame)
			end
		end
		return Container
	end
})

return {
	["Meta"] = meta;
	["Content"] = content;
}