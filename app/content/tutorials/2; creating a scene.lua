
local meta = {
	["Name"] = "change-this-later";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "1. What are scenes";
	["Description"] = "A scene can be used to simplify the process of programming a game world. They contain a static background and entities that can be interacted with. A scene also has a camera that can be moved around and zoomed in/out.";
	--["CodeMarkup"] = "";
	--[[
	["Demo"] = function()
		
	end;]]
})


table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "2. Creating a scene";
	["Description"] = "There are multiple types of scenes, but a default scene with a static background image can be created by calling the scene object. Before a scene can be used, it has to be added to the world. The camera will by default point at the top-left corner of the scene background because its default position is (0,0).";
	["CodeMarkup"] = "<k>local</k> loader <k>=</k> <f>require</f>(<s>\"framework.loader\"</s>)\n\n<k>function</k> love.<f>load</f>()\n\t<f>loader</f>()\n\t<k>local</k> Background <k>=</k> love.graphics.<f>newImage</f>(<s>\"image.png\"</s>)\n\t<k>local</k> imgScene <k>=</k> <f>scene</f>(Background)\n<k>end</k>\n\n<k>function</k> love.<f>draw</f>()\n\tworld:<f>render</f>()\n<k>end</k>";
	--[[
	["Demo"] = function()
		
	end;]]
})

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "3. Adding entities";
	["Description"] = "";
	["CodeMarkup"] = "";
	--[[
	["Demo"] = function()
		
	end;]]
})



return {
	["Meta"] = meta;
	["Content"] = content;
}