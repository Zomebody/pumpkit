

local ui = require("framework.ui")
local vector = require("framework.datatypes.vector")
local color = require("framework.datatypes.color")


local meta = {
	["Name"] = "(m) color";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The color Module";
	["Description"] = "A module used to construct color data types.";
	["CodeMarkup"] = "<c>-- Colors displayed from left to right</c>\n<k>local</k> orange = <f>color</f>(<n>1</n>, <n>0.5</n>, <n>0</n>)\n<k>local</k> blue = color.<f>fromHex</f>(<s>\"#007bff\"</s>)\n<k>local</k> purple = <f>color</f>(blue):<f>shiftHue</f>(<n>60</n>)\n<k>local</k> babyBlue = blue:<f>clone</f>():<f>lighten</f>(<n>0.6</n>)";
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
	["Name"] = "fromHSV";
	["Arguments"] = {"h", "s", "v"};
	["Description"] = "Constructs a color from HSV values.";
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
	["Name"] = "isColor";
	["Arguments"] = {"Object"};
	["Description"] = "Checks if the given object is a color instance. Returns true if so.";
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