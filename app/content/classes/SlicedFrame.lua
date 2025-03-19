
local meta = {
	["Name"] = "SlicedFrame";
	["SuperClass"] = "UIBase";
}

local content = {}

table.insert(content, {
	["Type"] = "Header";
	["Name"] = meta.Name;
	["Note"] = "Extends " .. meta.SuperClass;
	["Description"] = "An interface element that contains an image chopped into 9 pieces. When drawn, the corners of the image keep their respective sizes, but the edges and center piece are stretched. The object can be used to better scale text boxes, windows and other resizable elements, without seeing stretch marks.\n\nThe code example below will use the same image to create an ImageFrame and a SlicedFrame. Notice how the ImageFrame is stretched, but the SlicedFrame looks clean, despite the both having the same size. In addition, the corners of the SlicedFrame have been scaled by a factor 3 to give it a pixelated look.";
	["CodeMarkup"] = "<k>local</k> img <k>=</k> love.graphics.<f>newImage</f>(<s>\"slice_img.png\"</s>)\nimg:<f>setFilter</f>(<s>\"nearest\"</s>, <s>\"nearest\"</s>)\n<k>local</k> SlicedFrame <k>=</k> ui.<f>newSlicedFrame</f>(img, <f>vector2</f>(<n>10</n>, <n>10</n>), <f>vector2</f>(<n>50</n>, <n>50</n>), <n>200</n>, <n>100</n>, <f>color</f>(<n>1</n>, <n>1</n>, <n>1</n>), <n>3</n>)\n<k>local</k> ImageFrame <k>=</k> ui.<f>newImageFrame</f>(img, <n>200</n>, <n>100</n>)";
	["Demo"] = function() -- function that creates and returns an element to be placed right below the code example
		local img = love.graphics.newImage("test_images/slice10105050.png")
		img:setFilter("nearest", "nearest")
		local SlicedFrame = ui.newSlicedFrame(img, vector2(10, 10), vector2(50, 50), 200, 100, color(1, 1, 1), 3)
		local ImageFrame = ui.newImageFrame(img, 200, 100)
		local Container = ui.newFrame(ImageFrame.AbsoluteSize.x * 2 + 30, ImageFrame.AbsoluteSize.y)
		Container.Opacity = 0
		Container:addChild(ImageFrame)
		SlicedFrame:alignX("right")
		Container:addChild(SlicedFrame)
		return Container
	end;
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Properties";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "vector2";
	["Name"] = "BottomRightSlice";
	["Description"] = "A vector2 representing the bottom right cutting point used to chop up the image into 9 pieces.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "CornerScale";
	["Description"] = "When drawing the SlicedImage object, the size of the corners are multiplied by this factor. This can be useful if you want to draw small pixel-art at a larger size.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "table";
	["Name"] = "ImageSlices";
	["Description"] = "An array containing 9 Quad Love2d objects that are used to draw the UI element (in reading order).";
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
	["Description"] = "A number between 0 and 1. If a MaskImage is set, it is overlayed over the SlicedFrame. Any pixels in the MaskImage with a value in the red-channel lower than MaskThreshold will make the pixels in the SlicedFrame's image transparent.\n\nNote that 9-slicing does not affect the mask.";
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
	["ValueType"] = "vector2";
	["Name"] = "TopLeftSlice";
	["Description"] = "A vector2 representing the top left cutting point used to chop up the image into 9 pieces.";
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

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "setSlice";
	["Arguments"] = {"topLeft", "bottomRight"};
	["Description"] = "Changes the slice corners for the image. topLeft and bottomRight are two vector2s indicating the top left and bottom right corners. This method will update the viewports of all 9 quads used to draw the UI element.";
})

return {
	["Meta"] = meta;
	["Content"] = content;
}