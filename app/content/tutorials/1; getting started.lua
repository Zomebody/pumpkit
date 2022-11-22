
local meta = {
	["Name"] = "change-this-later";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "1. Initializing the framework";
	["Description"] = "Before any of the framework's datatypes, UI systems and other features can be used, it must first be loaded. This is done by requiring the 'loader' module and then firing the function it returns. Doing so will create globals for all the different modules of the framework.";
	["CodeMarkup"] = "<f>require</f>(<s>\"framework.loader\"</s>)()\n\n<k>function</k> love.<f>load</f>()\n\t<f>print</f>(<f>color</f>(<n>1</n>, <n>1</n>, <n>0</n>)) <c>-- color is now recognized!</c>\n<k>end</k>";
	--[[
	["Demo"] = function()
		
	end;]]
})

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "2. Loading modules";
	["Description"] = "All of the framework's modules are turned off by default. When you try to use them, nothing will happen. Instead, you need to initialize each module you want to use. All modules provide an ':initialize()' method to do so.";
	["CodeMarkup"] = "<f>require</f>(<s>\"framework.loader\"</s>)()\n\n<k>function</k> love.<f>load</f>()\n\ttween:<f>initialize</f>() <c>-- tweens now run!</c>\n\tui:<f>initialize</f>() <c>-- ui will now be drawn!</c>\n<k>end</k>";
	--[[
	["Demo"] = function()
		
	end;]]
})


return {
	["Meta"] = meta;
	["Content"] = content;
}