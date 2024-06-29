
local meta = {
	["Name"] = "change-this-later";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "1. Initializing the framework";
	["Description"] = "Before any of the framework's datatypes, UI systems and other features can be used, it must first be loaded. This is done by requiring the 'loader' module and then firing the function it returns. Doing so will create globals for all the different modules of the framework. It will also initialize the modules automatically, which will apply Monkey Patching to default love2d callbacks.\n\nNote: If you call the loader module before defining callbacks such as love.update() and love.draw(), you should make sure you do not overwrite them on accident afterwards. This can be avoided by only calling the loader function during love.load().";
	["CodeMarkup"] = "<k>local</k> loader <k>=</k> <f>require</f>(<s>\"framework.loader\"</s>)\n\n<k>function</k> love.<f>load</f>()\n\t<f>loader</f>()\n\t<f>print</f>(<f>color</f>(<n>1</n>, <n>1</n>, <n>0</n>)) <c>-- color is now recognized!</c>\n<k>end</k>";
	--[[
	["Demo"] = function()
		
	end;]]
})

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "2. Using the modules";
	["Description"] = "Modules are automatically initialized and ran every frame. However, any module that has to draw to the screen will not do so automatically. You will need to call their 'render' method in the love.draw callback to draw them.";
	["CodeMarkup"] = "<k>local</k> loader <k>=</k> <f>require</f>(<s>\"framework.loader\"</s>)\n\n<k>function</k> love.<f>load</f>()\n\t<f>loader</f>()\n<k>end</k>\n\n<k>function</k> love.<f>draw</f>()\n\tworld:<f>render</f>()\n\tui:<f>render</f>()\n<k>end</k>";
	--[[
	["Demo"] = function()
		
	end;]]
})


return {
	["Meta"] = meta;
	["Content"] = content;
}