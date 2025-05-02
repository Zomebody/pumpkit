
local meta = {
	["Name"] = "TextBlock";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "TextBlock";
	["Description"] = "An object that is created and assigned to UI elements when their text is set.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Properties";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "string";
	["Name"] = "AlignmentX";
	["Description"] = "How the text within the text block is aligned on the X-axis. Possible values are: 'left', 'right', 'center', 'justify'.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "string";
	["Name"] = "AlignmentY";
	["Description"] = "How the text within the text block is aligned on the Y-axis. Possible values are: 'top', 'bottom', 'center'.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "color";
	["Name"] = "Color";
	["Description"] = "The text color. If the text object itself also contains colored strings, those colors are multiplied by this color. The default color is white.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "table";
	["Name"] = "ColoredText";
	["Description"] = "The table representation of the text as used in the Love2D constructor when creating a Text object. This table is an array containing strings and sub-tables representing colors.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "font";
	["Name"] = "Font";
	["Description"] = "The font file used in the text block.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "string";
	["Name"] = "FontFile";
	["Description"] = "The file name of the font used.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "FontSize";
	["Description"] = "The size of the displayed text.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "MaxLines";
	["Description"] = "The maximum number of lines that will fit inside the text block when TextScales is set to true.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "UIBase";
	["Name"] = "Parent";
	["Description"] = "The parent element that this text block is attached to. The size of the text block is dependent on the parent's size.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "string";
	["Name"] = "RawText";
	["Description"] = "The raw text string displayed in the text block. This excludes text coloring.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "Text";
	["Name"] = "Text";
	["Description"] = "A Love2D Text object.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "boolean";
	["Name"] = "TextScales";
	["Description"] = "Whether the text inside the text block will automatically increase or decrease in size when the parent element is resized, new text is added, or the MaxLines changes.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "Width";
	["Description"] = "Unclear what this property actually does, but it was required to implement the WrapEnabled property.";
	["ReadOnly"] = true;
})
--[[
table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "WrapEnabled";
	["Description"] = "Defaulted to true. If true, the text will wrap on the edge and then continue on the line below.";
	["ReadOnly"] = true;
})
]]
table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "alignX";
	["Arguments"] = {"side"};
	["Description"] = "Align the text horizontally within the text block. Possible values are 'left', 'right', 'center', 'justify'.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "alignY";
	["Arguments"] = {"side"};
	["Description"] = "Align the text horizontally within the text block. Possible values are 'top', 'bottom', 'center'";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "clearFont";
	["Arguments"] = {};
	["Description"] = "This method is for internal use only. It will be called when the font is changed, to clear any references to unused fonts.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "fitText";
	["Arguments"] = {"remainScaled"};
	["Description"] = "Changes the dimensions of the given text block and resizes the text such that it best fits within text block without overflowing. Finding the right size is done by using a O(log(n)) search of trying different text sizes. It does not try every possible size, instead it searching through a list of 64 different sizes since created fonts are cached, and this helps manage memory usage. Generally you won't notice it if a font could have been slightly bigger to fit the space.\n\n'remainScaled' is a boolean indicating if TextScales should be set to true or false after fitting the text (or unchanged if nil).\n\nIf 'MaxLines' is set to any value other than 0, the text will be scaled such that exactly that many lines of text fit within the text block.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "getText";
	["Arguments"] = {"boolean"};
	["Description"] = "Returns the text from the text block. If 'true' is passed, the ColoredText property is returned. Otherwise, the RawText property is returned.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "getSize";
	["Arguments"] = {};
	["Description"] = "Returns the width and height of the Text object.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "setFont";
	["Arguments"] = {"filename"};
	["Description"] = "Sets the font of the text block to the given file name.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "setText";
	["Arguments"] = {"string"};
	["Description"] = "Replaces the content of the text block with the given string. Additionally, instead of a string, you can use a table representation of colored text as well.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "setTextSize";
	["Arguments"] = {"number"};
	["Description"] = "Changes the text size to the given number, rounded to the nearest integer value.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "updateWidth";
	["Arguments"] = {};
	["Description"] = "Changes the width (in pixels) of the text block in which the text resides. This is called automatically when the parent element is resized.";
})


table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Events";
	["Description"] = "";
})


table.insert(content, {
	["Type"] = "Event";
	["Name"] = "FontHeightChanged";
	["Arguments"] = {"height"};
	["Description"] = "Called when the height of the font used in the TextBlock changes. This does not trigger if the font is changed to a different font with the same font height. To get the corresponding new font size, simply index TextBlock.FontSize";
})


table.insert(content, {
	["Type"] = "Event";
	["Name"] = "TextChanged";
	["Arguments"] = {"rawText"};
	["Description"] = "Called when the text inside the textblock changed.";
})

return {
	["Meta"] = meta;
	["Content"] = content;
}