
local meta = {
	["Name"] = "ImageFrame";
	["SuperClass"] = "UIBase";
}

local content = {}

table.insert(content, {
	["Type"] = "Header";
	["Name"] = meta.Name;
	["Note"] = "Extends " .. meta.SuperClass;
	["Description"] = "An interface element that contains an image. When drawn, the image is stretched to perfectly fit within the element.";
	["CodeMarkup"] = "<k>local</k> img <k>=</k> love.graphics.<f>newImage</f>(<n>...</n>)\n<k>local</k> image_frame <k>=</k> ui.<f>newImageFrame</f>(img, <n>200</n>, <n>200</n>)";
	["Demo"] = function() -- function that creates and returns an element to be placed right below the code example
		local img = love.graphics.newImage("test_images/Twitch_PFP.png")
		local image_frame = ui.newImageFrame(img, 200, 200)
		image_frame.BorderColor = color(0, 0, 0)
		--image_frame.Rotation = 10
		--image_frame.BorderWidth = 2
		return image_frame;
	end;
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Properties";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "Image";
	["Name"] = "ReferenceImage";
	["Description"] = "The image that covers the element, used in drawing.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "draw";
	["Arguments"] = {};
	["Description"] = "Draws the object on the screen. This is called automatically by the UI system each frame. The given image is stretched such that is fully covers the element's Size.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "setReference";
	["Arguments"] = {"Image"};
	["Description"] = "Sets the reference image to the given Image object.";
})

return {
	["Meta"] = meta;
	["Content"] = content;
}