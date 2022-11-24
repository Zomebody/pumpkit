
local meta = {
	["Name"] = "change-this-later";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "1. Initializing modules";
	["Description"] = "When a module is initialized, it will apply a process known as 'Monkey Patching' to the default Love2d callbacks, such as love.update and love.draw.\n\nCertain callbacks may be altered by more than one module initialization. Therefore, the order in which modules are initialized effects the order in which module code is executed.";
	["CodeMarkup"] = "";
	--[[
	["Demo"] = function()
		
	end;]]
})


table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "2. Monkey Patching order";
	["Description"] = "Some modules may prepend code to Love2D callbacks. Other modules may append code to Love2D callbacks. Below is an illustration of each module and which callbacks they either prepend or append.\nTODO";
	["CodeMarkup"] = "";
	--[[
	["Demo"] = function()
		
	end;]]
})



return {
	["Meta"] = meta;
	["Content"] = content;
}