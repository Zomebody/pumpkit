
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
	["ValueType"] = "number";
	["Name"] = "Width";
	["Description"] = "Unclear what this property actually does, but it was required to implement the WrapEnabled property.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "WrapEnabled";
	["Description"] = "Defaulted to true. If true, the text will wrap on the edge and then continue on the line below.";
	["ReadOnly"] = true;
})

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
	["Arguments"] = {"width", "height"};
	["Description"] = "Changes the dimensions of the given text block and resizes the text such that it best fits within text block without overflowing. Finding the right size is done by using a O(log(n)) search of trying different text sizes.";
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
	["Name"] = "setWidth";
	["Arguments"] = {"number"};
	["Description"] = "Changes the width (in pixels) of the text block in which the text resides.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "setWrap";
	["Arguments"] = {"boolean"};
	["Description"] = "Sets whether or not the text should wrap onto the next line. If set to false, the text will overflow or cut off on the side of the element it resides in.";
})

return {
	["Meta"] = meta;
	["Content"] = content;
}