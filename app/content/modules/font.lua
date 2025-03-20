
local meta = {
	["Name"] = "font";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The font Module";
	["Description"] = "A module used to create fonts.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Constructors";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "new";
	["Arguments"] = {"filename", "size", "isTemporary"};
	["Description"] = "FOR INTERNAL USE ONLY. Creates a new font using the given file name and at the given size. isTemporary is set to true if this font should not be kept in a cache. The boolean is used when a UI object is resized and the FitTextOnResize property is set to true.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Properties";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "Cache";
	["ReadOnly"] = true;
	["Description"] = "A double-dictionary in the form cache[fontname][size]=font which stores which fonts have been created at which sizes and stores them for caching.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "clearCache";
	["Arguments"] = {"fontname"};
	["Description"] = "If no argument is provided this will clear all cached fonts. Otherwise, it clears all font sizes of the given font name";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "getSupportedFonts";
	["Arguments"] = {};
	["Description"] = "Returns an array of all fonts that are being supported. This list contains all font files within the framework's font folder. .txt files are ignored so that you can add licenses into the folder.\n\nFonts that are used in this app:";
	["Demo"] = function()
		local Container = ui.newFrame(200, 200, color(0, 0, 0))
		Container:setPadding(6)
		local fontList = font:getSupportedFonts()
		local str = ""
		for i = 1, #fontList do
			str = str .. fontList[i] .. "\n"
		end
		Container:setText("FiraCode.ttf", str, 14, true)
		return Container
	end
})

return {
	["Meta"] = meta;
	["Content"] = content;
}