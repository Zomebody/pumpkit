
local meta = {
	["Name"] = "ImageFrame";
	["SuperClass"] = "UIBase";
}

local content = {}

table.insert(content, {
	["Type"] = "Header";
	["Name"] = meta.Name;
	["Note"] = "Extends " .. meta.SuperClass;
	["Description"] = "An interface element that contains an image. When drawn, the image is stretched to perfectly fit within the element. If an instance is created without supplying an image, a 1x1 pixel white image will be created as a placeholder.";
	["CodeMarkup"] = "<k>local</k> img <k>=</k> love.graphics.<f>newImage</f>(<n>...</n>)\n<k>local</k> image_frame <k>=</k> ui.<f>newImageFrame</f>(img, <n>200</n>, <n>200</n>)";
	["Demo"] = function() -- function that creates and returns an element to be placed right below the code example
		local img = love.graphics.newImage("test_images/pumpky.png")
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
	["ValueType"] = "string";
	["Name"] = "ImageFit";
	["Description"] = "This property determines how an image fills its space. The default value is 'stretch'. Other possible values are documented in the :setImageFit() method.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "image";
	["Name"] = "MaskImage";
	["Description"] = "Sets a mask image. See MaskThreshold for details.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "MaskThreshold";
	["Description"] = "A number between 0 and 1. If a MaskImage is set, it is overlayed over the ImageFrame and any text if added. Any pixels in the MaskImage with a value in the red-channel lower than MaskThreshold will make the pixels in the ImageFrame's image transparent.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "Image";
	["Name"] = "ReferenceImage";
	["Description"] = "The image that covers the element, used in drawing.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "boolean";
	["Name"] = "Tiled";
	["Description"] = "If an image has its wrapping mode set to 'repeat' for both the X-axis and Y-axis, the image will be tiled rather than stretched. This property works in combination with ImageFit. When ImageFit is set to 'stretch', the image will tile using the image's original size. When ImageFit is set to 'contain', open space on the sides is filled with copies of the image.";
	["ReadOnly"] = true;
	["Demo"] = function()
		local img = love.graphics.newImage("test_images/pumpky_small.png")
		img:setWrap("repeat", "repeat")
		local TiledImage = ui.newImageFrame(img, vector2(1, 0), vector2(-30, 300))
		return TiledImage
	end
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
	["Name"] = "setImageFit";
	["Arguments"] = {"string"};
	["Description"] = "Sets the image fitting mode. Valid arguments are:\n- 'stretch': stretch or squish the image such that it fills its space.\n- 'cover': scale the image while preserving its aspect ratio such that its fills the space. Any overflow on the sides is cut off.\n- 'contain': scale the image while preserving its aspect ratio such that it fits within the space without cutting off any edges. This may cause open space horizontally or vertically.";
	["Demo"] = function()
		local img = love.graphics.newImage("test_images/pumpky_small.png")
		local Container = ui.newFrame(550, 200, color(0, 0, 0))
		--local LabelStretch = 
		local Stretch = ui.newImageFrame(img, 80, 130)
		Stretch:setBorder(color(1, 0, 0, 0.6), 4)
		Stretch:alignY("bottom")
		Stretch:shift(30, -10)
		Stretch:setImageFit("stretch")
		Container:addChild(Stretch)
		local Cover = ui.newImageFrame(img, 180, 130)
		Cover:setBorder(color(1, 0, 0, 0.6), 4)
		Cover:alignY("bottom")
		Cover:shift(150, -10)
		Cover:setImageFit("cover")
		Container:addChild(Cover)
		local Contain = ui.newImageFrame(img, 180, 130)
		Contain:setBorder(color(1, 0, 0, 0.6), 4)
		Contain:alignY("bottom")
		Contain:shift(355, -10)
		Contain:setImageFit("contain")
		Container:addChild(Contain)
		return Container
	end
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