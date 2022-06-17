
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
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "dereference";
	["Arguments"] = {"filename", "size"};
	["Description"] = "FOR INTERNAL USE ONLY. When a UI object is removed and it has text, its font is dereferenced if the font at the given size is no longer in use, opening up more memory!";
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
		print(#fontList)
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