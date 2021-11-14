
local meta = {
	["Name"] = "UIBase";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = meta.Name;
	["Description"] = "A rectangular container that acts as the base class of any UI object. A UIBase can hold other UI objects to create a UI hierarchy, but it can also be used as a label with text, a button, and more.\n\nYou cannot create a direct instand of a UIBase. However, you can create a Frame object which contains the same functionality, plus a :draw() method.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Properties";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "vector";
	["Name"] = "AbsolutePosition";
	["Description"] = "The exact location of the object on screen, in pixels. This property is updated whenever any method or event is called that manipulates positions or sizes. The computed values will be rounded down to prevent blurriness in the resulting draw calls.";
	["ReadOnly"] = true;
	["CodeMarkup"] = nil;
	["Demo"] = nil;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "color";
	["Name"] = "BorderColor";
	["Description"] = "The color of the inner border of the object, if BorderWidth > 0.";
	["ReadOnly"] = false;
	["CodeMarkup"] = nil;
	["Demo"] = nil;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "BorderWidth";
	["Description"] = "The width of the inner border of the element. When this is 0, no border is drawn. Otherwise, a border is drawn with a thickness in pixels equal to this property.";
	["ReadOnly"] = false;
	["CodeMarkup"] = nil;
	["Demo"] = nil;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "vector";
	["Name"] = "Center";
	["Description"] = "Similar to Roblox's AnchorPoint property. This will set the center point of the element for positioning. If this is vector(0, 0), the top left corner is used, vector(0.5, 0.5) is the middle, vector(1, 0) is the top right corner, and so on.";
	["ReadOnly"] = false;
	["CodeMarkup"] = nil;
	["Demo"] = nil;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "array";
	["Name"] = "Children";
	["Description"] = "A table containing all children of the UI element. The position of children equals their parent's AbsolutePosition, plus their own position. Children are drawn in order, so the last child appears on top of the other children.";
	["ReadOnly"] = true;
	["CodeMarkup"] = nil;
	["Demo"] = nil;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "string";
	["Name"] = "Class";
	["Description"] = "The class of the UI element. In this case it will be UIBase.";
	["ReadOnly"] = true;
	["CodeMarkup"] = nil;
	["Demo"] = nil;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "boolean";
	["Name"] = "ClipContent";
	["Description"] = "A boolean indicating whether or not children of this element will be cut off and not drawn when they fall outside of the parent's frame. This defaults to true and can be useful for scrolling frames, minimaps, and so on.";
	["ReadOnly"] = false;
	["CodeMarkup"] = nil;
	["Demo"] = nil;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "vector";
	["Name"] = "ContentOffset";
	["Description"] = "A vector that indicates an offset in pixels for child elements. You can edit this property with UIBase:shiftContent(x,y). This property is useful to implement scrolling frames or minimaps.";
	["ReadOnly"] = true;
	["CodeMarkup"] = nil;
	["Demo"] = nil;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "color";
	["Name"] = "Color";
	["Description"] = "The background color of the UIBase.";
	["ReadOnly"] = false;
	["CodeMarkup"] = nil;
	["Demo"] = nil;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "color";
	["Name"] = "ColorFocus";
	["Description"] = "The background color of the UIBase when the mouse is hovering over the element. This can be used to indicate that you may click on the element, like buttons.";
	["ReadOnly"] = false;
	["CodeMarkup"] = nil;
	["Demo"] = nil;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "color";
	["Name"] = "ColorHold";
	["Description"] = "The background color of the UIBase when the element is currently being held down by a mouse click.";
	["ReadOnly"] = false;
	["CodeMarkup"] = nil;
	["Demo"] = nil;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "boolean";
	["Name"] = "FitTextOnResize";
	["Description"] = "A boolean indicating whether or not the text inside the element should scale to fit perfectly within the element after its size is changed. This can be useful when creating, for example, speech bubbles.";
	["ReadOnly"] = false;
	["CodeMarkup"] = nil;
	["Demo"] = function()
		local Container = ui.newFrame(200, 50, color(0, 0, 0, 0))
		local SpeechImg = love.graphics.newImage("test_images/speechbubble1616x2424.png")
		local LargeSpeech = ui.newSlicedFrame(SpeechImg, vector(16, 16), vector(24, 24), 200, 200)
		LargeSpeech.FitTextOnResize = true
		LargeSpeech:setPadding(4)
		LargeSpeech:setText("FiraCode.ttf", {{0, 0, 0}, "Speech"}, 12)
		LargeSpeech.TextBlock:alignX("center")
		LargeSpeech.TextBlock:alignY("center")
		LargeSpeech:resize(100, 50)
		Container:addChild(LargeSpeech)
		local SmallSpeech = ui.newSlicedFrame(SpeechImg, vector(16, 16), vector(24, 24), 200, 200, nil, 7/10)
		SmallSpeech.FitTextOnResize = true
		SmallSpeech:setPadding(4)
		SmallSpeech:setText("FiraCode.ttf", {{0, 0, 0}, "Speech"}, 12)
		SmallSpeech.TextBlock:alignX("center")
		SmallSpeech.TextBlock:alignY("center")
		SmallSpeech:resize(70, 35)
		SmallSpeech:putNextTo(LargeSpeech, "right", 30)
		Container:addChild(SmallSpeech)
		return Container
	end;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "boolean";
	["Name"] = "Hidden";
	["Description"] = "A boolean indicating whether or not the element should be drawn. When set to false, the element will not be drawn, nor will any children be drawn. Events such as scroll, hover and click events will also be disabled.";
	["ReadOnly"] = false;
	["CodeMarkup"] = nil;
	["Demo"] = nil;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "Id";
	["Description"] = "The unique identifier of the object. This is guaranteed to be unique. This can also be used to determine the order in which UI elements are created as the number goes up by 1 anytime an object is created.";
	["ReadOnly"] = true;
	["CodeMarkup"] = nil;
	["Demo"] = nil;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "Opacity";
	["Description"] = "A number between 0 and 1 that determines if the object is see-through. The same effect can also be achieved by editing the alpha channel of the Color property.";
	["ReadOnly"] = false;
	["CodeMarkup"] = nil;
	["Demo"] = nil;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "PaddingX";
	["Description"] = "Adds a padding on the left and right side of the UIBase in pixels. This property applies to child elements and the UIBase's TextBlock. This value can be changed with :setPadding().";
	["ReadOnly"] = true;
	["CodeMarkup"] = nil;
	["Demo"] = nil;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "PaddingY";
	["Description"] = "Adds a padding on the top and bottom side of the UIBase in pixels. This property applies to child elements and the UIBase's TextBlock. This value can be changed with :setPadding().";
	["ReadOnly"] = true;
	["CodeMarkup"] = nil;
	["Demo"] = nil;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "Object";
	["Name"] = "Parent";
	["Description"] = "The parent element of the UIBase. This can be another element or the UI system itself (meaning the element is a top-level element). The parent is automatically set when :addChild() is called on an element and this object is passed as the argument.";
	["ReadOnly"] = true;
	["CodeMarkup"] = nil;
	["Demo"] = nil;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "Object";
	["Name"] = "Position";
	["Description"] = "This determines the location of the UI element relative to its parent. Position.Scale is a vector whose x and y are between 0 and 1, where (0,0) is the top left and (1,1) is the bottom right. Position.Offset is a position in absolute pixels. The two can be mixed to create UI that is scalable with the window's size. Setting this property can be done with the :reposition(scale,offset) method.";
	["ReadOnly"] = true;
	["CodeMarkup"] = nil;
	["Demo"] = nil;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "Rotation";
	["Description"] = "How many degrees to rotate the object clockwise around its middle point.\n\nLimitations:\n\t- Visuals do not apply to children; They treat their parent as if there is no rotation.\n\t- Rotation does not change the hitbox of any click events.\n\t- When ClipContent is set to true, corners will be cut-off when rotated outside of the original orientation box.";
	["ReadOnly"] = false;
	["CodeMarkup"] = nil;
	["Demo"] = nil;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "vector";
	["Name"] = "Size";
	["Description"] = "A vector indicating the size of the element in pixels. Setting the size can be done with the :resize(x,y) method.";
	["ReadOnly"] = true;
	["CodeMarkup"] = nil;
	["Demo"] = nil;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "table<string>";
	["Name"] = "Tags";
	["Description"] = "A list of tags given to the object through the :addTag() method. If no tags are assigned, this table is empty. Tags are sorted by the order in which they were assigned.";
	["ReadOnly"] = true;
	["CodeMarkup"] = nil;
	["Demo"] = nil;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "Object";
	["Name"] = "TextBlock";
	["Description"] = "A reference to the element's TextBlock object. When :setText() is called, this property can be set or unset. The TextBlock determines the text displayed on the element.";
	["ReadOnly"] = true;
	["CodeMarkup"] = nil;
	["Demo"] = nil;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "boolean";
	["Name"] = "VisualOnly";
	["Description"] = "A boolean indicating if the object can be returned by the :at() method. This will also prevent any of the object's cursor-related functions from triggering, which is all events so far.";
	["ReadOnly"] = false;
	["CodeMarkup"] = nil;
	["Demo"] = function()
		local Container = ui.newFrame(240, 100, color(0, 0, 0))
		local Clickable = ui.newFrame(150, 70, color(0, 0.7, 1))
		Clickable.ColorFocus:darken(0.2)
		Clickable.ColorHold:darken(0.3)
		Clickable:setText("FiraCode.ttf", "Clickable", 16)
		Clickable:setPadding(5)
		Clickable.OnFullPress = function()
			if Clickable.Position.Scale.x == 1 then
				Clickable:alignX("left")
			else
				Clickable:alignX("right")
			end
		end
		Clickable.OnScroll = Clickable.OnFullPress
		Clickable.OnDrag = Clickable.OnFullPress
		local Clickthrough = ui.newFrame(150, 70, color(0.7, 0.3, 0, 0.8))
		Clickthrough.VisualOnly = true
		Clickthrough:setText("FiraCode.ttf", "VisualOnly", 16)
		Clickthrough:setPadding(5)
		Clickthrough:alignX("right")
		Clickthrough:alignY("bottom")
		Container:addChild(Clickable)
		Container:addChild(Clickthrough)
		return Container
	end;
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "addChild";
	["Arguments"] = {"Object"};
	["Description"] = "Sets the parent of the given object to this element. It also removes the child from the old parent's child list.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "addTag";
	["Arguments"] = {"tag"};
	["Description"] = "Mark the object with a tag so it can be found with ui:find(). If the object already has the tag, this will do nothing. Tags must be strings. Multiple tags may be assigned.";
	["CodeMarkup"] = "<k>local</k> FrameCyan1 <k>=</k> ui.<f>newFrame</f>(<n>60</n>, <n>60</n>, <f>color</f>(<n>0</n>, <n>0.5</n>, <n>1</n>))\n<k>local</k> FrameCyan2 <k>=</k> ui.<f>newFrame</f>(<n>60</n>, <n>60</n>, <f>color</f>(<n>0</n>, <n>0.5</n>, <n>1</n>))\nFrameCyan1:<f>addTag</f>(<s>\"cyan\"</s>)\nFrameCyan2:<f>addTag</f>(<s>\"cyan\"</s>)\n<k>local</k> ButtonRed <k>=</k> ui.<f>newFrame</f>(<n>60</n>, <n>60</n>, <f>color</f>(<n>0.8</n>, <n>0.2</n>, <n>0.2</n>))\nFrameCyan2:<f>putNextTo</f>(FrameCyan1, <s>\"right\"</s>, <n>20</n>)\nButtonRed:<f>putNextTo</f>(FrameCyan2, <s>\"right\"</s>, <n>20</n>)\nButtonRed:<f>setText</f>(<s>\"FiraCode.ttf\"</s>, <s>\"Click to find cyan\"</s>, <n>18</n>)\nButtonRed.OnFullPress <k>=</k> <f>function</f>()\n\t<k>local</k> Objects <k>=</k> ui:<f>find</f>(<s>\"cyan\"</s>)\n\t<k>for</k> i <k>=</k> 1, #Objects <k>do</k>\n\t\tObjects[i]:<f>setText</f>(<s>\"FiraCode.ttf\"</s>, <s>\"I am cyan!\"</s>, <n>18</n>)\n\t<k>end</k>\n<k>end</k>";
	["Demo"] = function()
		local Container = ui.newFrame(400, 100, color(0, 0, 0))
		local FrameCyan1 = ui.newFrame(60, 60, color(0, 0.5, 1))
		local FrameCyan2 = ui.newFrame(60, 60, color(0, 0.5, 1))
		FrameCyan1:addTag("cyan")
		FrameCyan2:addTag("cyan")
		local ButtonRed = ui.newFrame(60, 60, color(0.8, 0.2, 0.2))
		Container:addChild(FrameCyan1)
		Container:addChild(FrameCyan2)
		Container:addChild(ButtonRed)
		FrameCyan2:putNextTo(FrameCyan1, "right", 20)
		ButtonRed:putNextTo(FrameCyan2, "right", 20)
		ButtonRed:setText("FiraCode.ttf", "Click to find cyan", 18)
		ButtonRed.OnFullPress = function()
			local Objects = ui:find("cyan")
			for i = 1, #Objects do
				Objects[i]:setText("FiraCode.ttf", "I am cyan!", 18)
			end
		end
		return Container
	end
})


table.insert(content, {
	["Type"] = "Method";
	["Name"] = "alignX";
	["Arguments"] = {"side"};
	["Description"] = "Aligns the element on the horizontal axis. Side can be either \"left\", \"right\" or \"center\". This will set the Position and Center property.";
	["CodeMarkup"] = "<k>local</k> Elem <k>=</k> ui.<f>newFrame</f>(<n>40</n>, <n>40</n>, <f>color</f>(<n>1</n>, <n>1</n>, <n>1</n>))\nContainer:<f>addChild</f>(Elem)\nElem:<f>alignX</f>(<s>\"right\"</s>)";
	["Demo"] = function()
		local Container = ui.newFrame(200, 60, color(0, 0, 0))
		local Elem = ui.newFrame(40, 40, color(1, 1, 1))
		Container:addChild(Elem)
		Elem:alignX("right")
		return Container
	end;
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "alignY";
	["Arguments"] = {"side"};
	["Description"] = "Aligns the element on the vertical axis. Side can be either \"top\", \"bottom\" or \"center\". This will set the Position and Center property.";
	["CodeMarkup"] = "<k>local</k> Elem <k>=</k> ui.<f>newFrame</f>(<n>40</n>, <n>40</n>, <f>color</f>(<n>1</n>, <n>1</n>, <n>1</n>))\nContainer:<f>addChild</f>(Elem)\nElem:<f>alignY</f>(<s>\"bottom\"</s>)";
	["Demo"] = function()
		local Container = ui.newFrame(200, 60, color(0, 0, 0))
		local Elem = ui.newFrame(40, 40, color(1, 1, 1))
		Container:addChild(Elem)
		Elem:alignY("bottom")
		return Container
	end;
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "at";
	["Arguments"] = {"x", "y"};
	["Description"] = "Recursively finds and returns the element that is displayed at the absolute x and y coordinates. Objects whose Clickthrough property is set to true will be ignored.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "clearTags";
	["Arguments"] = {};
	["Description"] = "Calls :removeTag() for all strings currently in the Tags list. This will clear all tags from the object.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "fitText";
	["Arguments"] = {};
	["Description"] = "If :setText() has been called sometime prior, this will resize the text such that it perfectly fits within the element's box, while respecting any padding. This can be useful when creating speech bubbles. NOTE: This method is expensive and should not be called many times per frame!";
	["CodeMarkup"] = "<k>local</k> Frame <k>=</k> ui.<f>newFrame</f>(<n>250</n>, <n>80</n>, <f>color</f>(<n>0</n>, <n>0</n>, <n>0</n>))\nFrame:<f>setPadding</f>(<n>4</n>)\nFrame:<f>setText</f>(<s>\"FiraCode.ttf\"</s>, <s>\"Hello World\"</s>, <n>8</n>)\nFrame:<f>fitText</f>()";
	["Demo"] = function()
		local Frame = ui.newFrame(250, 80, color(0, 0, 0))
		Frame:setPadding(4)
		Frame:setText("FiraCode.ttf", "Hello World", 8)
		Frame:fitText()
		return Frame
	end
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "getPixelPadding";
	["Arguments"] = {};
	["Description"] = "Returns the padding on the x-axis and the y-axis.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "hasTag";
	["Arguments"] = {"tag"};
	["Description"] = "Returns true if the object has the given tag and false otherwise.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "hide";
	["Arguments"] = {};
	["Description"] = "Sets the Hidden property to true, preventing the object from being drawn. Events will not work either.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "isDescendantOf";
	["Arguments"] = {"Object"};
	["Description"] = "Returns true if the current UI element is a descendant (child or indirect child) of the given object.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "positionContent";
	["Arguments"] = {"x", "y"};
	["Description"] = "Sets the ContentOffset property to the specified x and y coordinates.";
	["CodeMarkup"] = "<k>local</k> Container <k>=</k> ui.<f>newFrame</f>(<n>250</n>, <n>100</n>, <f>color</f>(<n>0</n>, <n>0</n>, <n>0</n>))\n<k>local</k> Child <k>=</k> ui.<f>newFrame</f>(<n>100</n>, <n>100</n>, <f>color</f>(<n>1</n>, <n>1</n>, <n>1</n>))\nChild.OnFullPress <k>=</k> <f>function</f>()\n\t<k>if</k> Container.ContentOffset.x <k>==</k> <n>0</n> <k>then</k>\n\t\tContainer:<f>positionContent</f>(<n>150</n>, <n>0</n>)\n\t<k>else</k>\n\t\tContainer:<f>positionContent</f>(<n>0</n>, <n>0</n>)\n\t<k>end</k>\n<k>end</k>\nContainer:<f>addChild</f>(Child)";
	["Demo"] = function()
		local Container = ui.newFrame(250, 100, color(0, 0, 0))
		local Child = ui.newFrame(100, 100, color(1, 1, 1))
		Child.OnFullPress = function()
			if Container.ContentOffset.x == 0 then
				Container:positionContent(150, 0)
			else
				Container:positionContent(0, 0)
			end
		end
		Container:addChild(Child)
		return Container
	end
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "putNextTo";
	["Arguments"] = {"Object", "side", "offset"};
	["Description"] = "Moves the element to be positioned next to 'Object'. 'side' is a string determining on which of the four sides the object should be placed. The value can be either 'top'/'above', 'bottom'/'under'/'below', 'left' or 'right'. The offset value determines a distance in pixels between the two elements.";
	["CodeMarkup"] = "<k>local</k> Frame1 <k>=</k> ui.<f>newFrame</f>(<n>100</n>, <n>100</n>, <f>color</f>(<n>0</n>, <n>0</n>, <n>0</n>))\n<k>local</k> Frame2 <k>=</k> ui.<f>newFrame</f>(<n>100</n>, <n>200</n>, <f>color</f>(<n>0</n>, <n>0</n>, <n>0</n>))\nFrame2:<f>putNextTo</f>(Frame1, <s>\"right\"</s>, <n>20</n>) <c>-- put Frame2 20 pixels to the right of Frame1</c>";
	["Demo"] = function() -- function that creates and returns an element to be placed right below the code example
		local Container = ui.newFrame(300, 100)
		Container.Opacity = 0
		local Frame1 = ui.newFrame(100, 100, color(0, 0, 0))
		local Frame2 = ui.newFrame(200, 100, color(0, 0, 0))
		Frame2:putNextTo(Frame1, "right", 20)
		Container:addChild(Frame1)
		Container:addChild(Frame2)
		return Container
	end;
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "remove";
	["Arguments"] = {};
	["Description"] = "Removes the object from memory by unparenting it, unmarking it, cleaning up the textblock and removing all of its children recursively. In the case of an AnimatedFrame, the reference image is stopped as well to dereference the animation if it is not being used elsewhere.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "removeTag";
	["Arguments"] = {"tag"};
	["Description"] = "Removes the given tag from the object if it exists.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "reposition";
	["Arguments"] = {"sx", "sy", "ox", "oy"};
	["Description"] = "Sets the Position property and updates the AbsolutePosition of the elements and its descendants. sx and sy are the scale, ox and oy are the offset. Alternatively, two vectors can be passed for sx and sy instead.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "resize";
	["Arguments"] = {"x", "y"};
	["Description"] = "Resizes the element. This also updates the AbsolutePosition of the element and its children.";
	["CodeMarkup"] = "<k>local</k> Frame1 <k>=</k> ui.<f>newFrame</f>(<n>100</n>, <n>100</n>, <f>color</f>(<n>0</n>, <n>0</n>, <n>0</n>))\nFrame1:<f>setText</f>(<s>\"FiraCode.ttf\"</s>, <s>\"Frame 1\"</s>, <n>18</n>)\n<k>local</k> Frame2 <k>=</k> ui.<f>newFrame</f>(<n>100</n>, <n>100</n>, <f>color</f>(<n>0</n>, <n>0</n>, <n>0</n>))\nFrame2:<f>setText</f>(<s>\"FiraCode.ttf\"</s>, <s>\"Frame 2\"</s>, <n>18</n>)\nFrame2:<f>resize</f>(<n>130</n>, <n>80</n>)";
	["Demo"] = function() -- function that creates and returns an element to be placed right below the code example
		local Container = ui.newFrame(300, 100)
		Container.Opacity = 0
		local Frame1 = ui.newFrame(100, 100, color(0, 0, 0))
		Frame1:setText("FiraCode.ttf", "Frame 1", 18)
		local Frame2 = ui.newFrame(100, 100, color(0, 0, 0))
		Frame2:setText("FiraCode.ttf", "Frame 2", 18)
		Frame2:putNextTo(Frame1, "right", 20)
		Frame2:resize(130, 80)
		Container:addChild(Frame1)
		Container:addChild(Frame2)
		return Container
	end;
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "setBorder";
	["Arguments"] = {"color", "width"};
	["Description"] = "Sets the color and the width of the element's border. If color is a number instead, that will be used as the new width.";
	["CodeMarkup"] = "<k>local</k> Frame1 <k>=</k> ui.<f>newFrame</f>(<n>100</n>, <n>100</n>, <f>color</f>(<n>1</n>, <n>1</n>, <n>1</n>))\nFrame1:<f>setBorder</f>(<f>color</f>(<n>0.4</n>, <n>0.4</n>, <n>1</n>), <n>5</n>)\n<k>local</k> Frame2 <k>=</k> ui.<f>newFrame</f>(<n>100</n>, <n>100</n>, <f>color</f>(<n>1</n>, <n>1</n>, <n>1</n>))\nFrame2:<f>setBorder</f>(<n>10</n>)";
	["Demo"] = function()
		local Container = ui.newFrame(300, 100)
		Container.Opacity = 0
		local Frame1 = ui.newFrame(100, 100, color(1, 1, 1))
		Frame1:setBorder(color(0.4, 0.4, 1), 5)
		local Frame2 = ui.newFrame(100, 100, color(1, 1, 1))
		Frame2:setBorder(10)
		Frame2:putNextTo(Frame1, "right", 20)
		Container:addChild(Frame1)
		Container:addChild(Frame2)
		return Container
	end
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "setCenter";
	["Arguments"] = {"x", "y"};
	["Description"] = "Sets the center of the element. The center property is similar to Roblox's AnchorPoint property. X and y are numbers between 0 and 1. X can also be a vector.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "setPadding";
	["Arguments"] = {"x", "y"};
	["Description"] = "Sets the horizontal and vertical padding of an element. If the second argument is missing, the first argument replaces it. Horizontal and vertical padding applies on both of their edges. Padding will apply to the element's childrens' Position property and it will apply to the element's TextBlock to offset text from the sides.";
	["CodeMarkup"] = "<k>local</k> Container <k>=</k> ui.<f>newFrame</f>(<n>300</n>, <n>100</n>, <f>color</f>(<n>0</n>, <n>0</n>, <n>0</n>))\nContainer:<f>setPadding</f>(<n>20</n>, <n>10</n>)\nContainer:<f>setText</f>(<s>\"FiraCode.ttf\"</s>, <s>\"Hello World\"</s>, <n>18</n>)\n<k>local</k> Child <k>=</k> ui.<f>newFrame</f>(<n>60</n>, <n>60</n>, <f>color</f>(<n>1</n>, <n>1</n>, <n>1</n>))\nChild:<f>alignX</f>(<s>\"right\"</s>)\nChild:<f>alignY</f>(<s>\"bottom\"</s>)\nContainer:<f>addChild</f>(Child)";
	["Demo"] = function()
		local Container = ui.newFrame(300, 100, color(0, 0, 0))
		Container:setPadding(20, 10)
		Container:setText("FiraCode.ttf", "Hello World", 18)
		local Child = ui.newFrame(60, 60, 60, color(1, 1, 1))
		Child:alignX("right")
		Child:alignY("bottom")
		Container:addChild(Child)
		return Container
	end
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "setText";
	["Arguments"] = {"fontname", "textData", "fontsize", "scaleHeight"};
	["Description"] = "Sets the text inside the element. This will set the TextBlock property, which is another instance type. fontname must be a font that exists in the list of fonts. textData is either a string or a table with colored text data (see Love2D documentation of printf()). fontsize is the size of the font. scaleHeight is a boolean that, when enabled, will set the element's height such that the text perfectly fits vertically. This will take padding into consideration as well.";
	["CodeMarkup"] = "<k>local</k> Frame <k>=</k> ui.<f>newFrame</f>(<n>300</n>, <n>100</n>, <f>color</f>(<n>0</n>, <n>0</n>, <n>0</n>))\nFrame:<f>setText</f>(<s>\"FiraCode.ttf\"</s>, <s>\"The quick brown fox jumps over the lazy dog\"</s>, <n>32</n>, <b>true</b>)";
	["Demo"] = function()
		local Frame = ui.newFrame(300, 100, color(0, 0, 0))
		Frame:setText("FiraCode.ttf", "The quick brown fox jumps over the lazy dog", 32, true)
		return Frame
	end
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "shift";
	["Arguments"] = {"offsetX", "offsetY"};
	["Description"] = "Moves the element a certain number of pixels on the x-axis and y-axis.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "shiftContent";
	["Arguments"] = {"offsetX", "offsetY"};
	["Description"] = "Changes the ContentOffset property by the specified amount on the x-axis and y-axis. This can be used to program scrollable elements.";
	["CodeMarkup"] = "<k>local</k> Container <k>=</k> ui.<f>newFrame</f>(<n>250</n>, <n>100</n>, <f>color</f>(<n>0</n>, <n>0</n>, <n>0</n>))\n<k>local</k> Child <k>=</k> ui.<f>newFrame</f>(<n>100</n>, <n>100</n>, <f>color</f>(<n>1</n>, <n>1</n>, <n>1</n>))\nChild.OnFullPress <k>=</k> <f>function</f>()\n\t<k>if</k> Container.ContentOffset.x <k><</k> <n>150</n> <k>then</k>\n\t\tContainer:<f>shiftContent</f>(<n>25</n>, <n>0</n>)\n\t<k>else</k>\n\t\tContainer:<f>shiftContent</f>(<n>-150</n>, <n>0</n>)\n\t<k>end</k>\n<k>end</k>\nContainer:<f>addChild</f>(Child)";
	["Demo"] = function()
		local Container = ui.newFrame(250, 100, color(0, 0, 0))
		local Child = ui.newFrame(100, 100, color(1, 1, 1))
		Child.OnFullPress = function()
			if Container.ContentOffset.x < 150 then
				Container:shiftContent(25, 0)
			else
				Container:shiftContent(-150, 0)
			end
		end
		Container:addChild(Child)
		return Container
	end
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "show";
	["Arguments"] = {};
	["Description"] = "Sets the Hidden property to false. This makes it possible for the element to be drawn. Events will also work again.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "toBack";
	["Arguments"] = {};
	["Description"] = "Moves the child to the first index of its parent's Children table. This makes it appear behind all other siblings.";
	["Demo"] = function()
		local Container = ui.newFrame(300, 150, color(0, 0, 0))
		Container:setPadding(10, 10)
		local frameLeft = ui.newFrame(160, 130, color(0.7, 0.5, 0.3))
		frameLeft:alignX("left")
		frameLeft:setPadding(10, 10)
		frameLeft:setText("FiraCode.ttf", "Click me!", 18)
		frameLeft.TextBlock:alignX("left")
		frameLeft.OnPressStart = function() frameLeft:toBack() end
		local frameRight = ui.newFrame(160, 130, color(0.3, 0.5, 0.7))
		frameRight:alignX("right")
		frameRight:setPadding(10, 10)
		frameRight:setText("FiraCode.ttf", "Click me!", 18)
		frameRight.TextBlock:alignX("right")
		frameRight.OnPressStart = function() frameRight:toBack() end
		Container:addChild(frameLeft)
		Container:addChild(frameRight)
		return Container
	end;
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "toFront";
	["Arguments"] = {};
	["Description"] = "Moves the child to the last index of its parent's Children table. This makes it appear on top of all other siblings.";
	["Demo"] = function()
		local Container = ui.newFrame(300, 150, color(0, 0, 0))
		Container:setPadding(10, 10)
		local frameLeft = ui.newFrame(160, 130, color(0.7, 0.5, 0.3))
		frameLeft:alignX("left")
		frameLeft:setPadding(10, 10)
		frameLeft:setText("FiraCode.ttf", "Click me!", 18)
		frameLeft.TextBlock:alignX("left")
		frameLeft.OnPressStart = function() frameLeft:toFront() end
		local frameRight = ui.newFrame(160, 130, color(0.3, 0.5, 0.7))
		frameRight:alignX("right")
		frameRight:setPadding(10, 10)
		frameRight:setText("FiraCode.ttf", "Click me!", 18)
		frameRight.TextBlock:alignX("right")
		frameRight.OnPressStart = function() frameRight:toFront() end
		Container:addChild(frameLeft)
		Container:addChild(frameRight)
		return Container
	end;
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Callbacks";
	["Description"] = "";
})


table.insert(content, {
	["Type"] = "Callback";
	["Name"] = "OnDrag";
	["Arguments"] = {"dx", "dy", "button", "offX", "offY"};
	["Description"] = "Called when you drag an element. A drag is when you first press the element and then move the cursor while keeping the press active. A drag may go outside the box of the element and it will still count as an active press. dx and dy are numbers indicating the relative movement in the current frame. button is the mouse button (1 for touch drags). offX and offY are an offset in pixels relative to the starting point of the drag.";
	["CodeMarkup"] = "<k>local</k> Draggable <k>=</k> ui.<f>newFrame</f>(<n>80</n>, <n>80</n>, <f>color</f>(<n>1</n>, <n>1</n>, <n>1</n>))\n<k>local</k> x, y <k>=</k> <n>0</n>, <n>0</n>\nDraggable.OnPressStart = <f>function</f>()\n\tx <k>=</k> Draggable.Position.Offset.x\n\ty <k>=</k> Draggable.Position.Offset.y\n<k>end</k>\nDraggable.OnDrag <k>=</k> <f>function</f>(<a>dx</a>, <a>dy</a>, <a>button</a>, <a>offX</a>, <a>offY</a>)\n\t<k>if</k> button <k>==</k> <n>1</n> <k>then</k>\n\t\t<k>local</k> clampedX = math.<f>min</f>(<n>220</n>, math.<f>max</f>(<n>0</n>, x <k>+</k> offX))\n\t\t<k>local</k> clampedY = math.<f>min</f>(<n>220</n>, math.<f>max</f>(<n>0</n>, y <k>+</k> offY))\n\t\tDraggable:<f>reposition</f>(<n>0</n>, <n>0</n>, clampedX, clampedY)\n\t<k>end</k>\n<k>end</k>";
	["Demo"] = function() -- function that creates and returns an element to be placed right below the code example
		local Container = ui.newFrame(300, 180, color(0, 0, 0))
		local Draggable = ui.newFrame(80, 80, color(1, 1, 1))
		local x, y = 0, 0
		Draggable.OnPressStart = function()
			x = Draggable.Position.Offset.x
			y = Draggable.Position.Offset.y
		end
		Draggable.OnDrag = function(dx, dy, button, offX, offY)
			if button == 1 then
				local clampedX = math.min(220, math.max(0, x + offX))
				local clampedY = math.min(100, math.max(0, y + offY))
				Draggable:reposition(0, 0, clampedX, clampedY)
			end
		end
		Container:addChild(Draggable)
		return Container
	end;
})

table.insert(content, {
	["Type"] = "Callback";
	["Name"] = "OnDragEnd";
	["Arguments"] = {"offX", "offY", "button"};
	["Description"] = "Called when you stop dragging the element. offX and offY are an offset in pixels relative to the starting point of the drag. button is the mouse button id (1 for touch drags).";
})

table.insert(content, {
	["Type"] = "Callback";
	["Name"] = "OnFullPress";
	["Arguments"] = {"x", "y", "button", "istouch", "presses"};
	["Description"] = "TODO: implement mobile touch support.\n\nCalled when you hold down and release your cursor on the element without leaving its bounding box in the process. x and y are the absolute cursor location on the screen. 'button' is the identifier of the mouse button, if applicable. istouch is a boolean indicating if the press was a touch event. The presses argument is the number of recent presses, which can be used to check for double-clicks.";
	["CodeMarkup"] = "<k>local</k> Frame <k>=</k> ui.<f>newFrame</f>(<n>80</n>, <n>40</n>, <f>color</f>(<n>0</n>, <n>0</n>, <n>0</n>))\n<k>local</k> counter <k>=</k> <n>0</n>\nFrame.OnFullPress <k>=</k> <f>function</f>()\n\tcounter <k>=</k> counter <k>+</k> <n>1</n>\n\tFrame:<f>setText</f>(<s>\"FiraCode.ttf\"</s>, <f>tostring</f>(counter), <n>18</n>)\n<k>end</k>";
	["Demo"] = function() -- function that creates and returns an element to be placed right below the code example
		local Frame = ui.newFrame(80, 40, color(0, 0, 0))
		local counter = 0
		Frame.OnFullPress = function()
			counter = counter + 1
			Frame:setText("FiraCode.ttf", tostring(counter), 18)
		end
		return Frame
	end;
})

table.insert(content, {
	["Type"] = "Callback";
	["Name"] = "OnHoverEnd";
	["Arguments"] = {};
	["Description"] = "Called when the mouse leaves the bounding box of the UI element.";
	["CodeMarkup"] = "<k>local</k> Frame <k>=</k> ui.<f>newFrame</f>(<n>80</n>, <n>40</n>, <f>color</f>(<n>0</n>, <n>0</n>, <n>0</n>))\n<k>local</k> counter <k>=</k> <n>0</n>\nFrame.OnHoverEnd <k>=</k> <f>function</f>()\n\tcounter <k>=</k> counter <k>+</k> <n>1</n>\n\tFrame:<f>setText</f>(<s>\"FiraCode.ttf\"</s>, <f>tostring</f>(counter), <n>18</n>)\n<k>end</k>";
	["Demo"] = function() -- function that creates and returns an element to be placed right below the code example
		local Frame = ui.newFrame(80, 40, color(0, 0, 0))
		local counter = 0
		Frame.OnHoverEnd = function()
			counter = counter + 1
			Frame:setText("FiraCode.ttf", tostring(counter), 18)
		end
		return Frame
	end;
})

table.insert(content, {
	["Type"] = "Callback";
	["Name"] = "OnHoverStart";
	["Arguments"] = {};
	["Description"] = "Called when the mouse enters the bounding box of the UI element.";
	["CodeMarkup"] = "<k>local</k> Frame <k>=</k> ui.<f>newFrame</f>(<n>80</n>, <n>40</n>, <f>color</f>(<n>0</n>, <n>0</n>, <n>0</n>))\n<k>local</k> counter <k>=</k> <n>0</n>\nFrame.OnHoverStart <k>=</k> <f>function</f>()\n\tcounter <k>=</k> counter <k>+</k> <n>1</n>\n\tFrame:<f>setText</f>(<s>\"FiraCode.ttf\"</s>, <f>tostring</f>(counter), <n>18</n>)\n<k>end</k>";
	["Demo"] = function() -- function that creates and returns an element to be placed right below the code example
		local Frame = ui.newFrame(80, 40, color(0, 0, 0))
		local counter = 0
		Frame.OnHoverStart = function()
			counter = counter + 1
			print(2)
			Frame:setText("FiraCode.ttf", tostring(counter), 18)
		end
		return Frame
	end;
})

table.insert(content, {
	["Type"] = "Callback";
	["Name"] = "OnNestedDrag";
	["Arguments"] = {"dx", "dy", "button", "offX", "offY"};
	["Description"] = "Called when you drag an element, or any of its descendants. A drag is when you first press the element and then move the cursor while keeping the press active. A drag may go outside the box of the element and it will still count as an active press. dx and dy are numbers indicating the relative movement in the current frame. button is the mouse button id (1 for touch drags). offX and offY are an offset in pixels relative to the starting point of the drag.";
})

table.insert(content, {
	["Type"] = "Callback";
	["Name"] = "OnNestedDragEnd";
	["Arguments"] = {"offX", "offY", "button"};
	["Description"] = "Called when you stop dragging the element, or any of its descendants. offX and offY are an offset in pixels relative to the starting point of the drag. button is the mouse button id (1 for touch drags).";
})

table.insert(content, {
	["Type"] = "Callback";
	["Name"] = "OnNestedPressEnd";
	["Arguments"] = {"x", "y", "button", "istouch", "presses"};
	["Description"] = "Similar to OnPressEnd. This is triggered when you release a press on an element, or any of its descendants.";
	["CodeMarkup"] = "<k>local</k> Frame <k>=</k> ui.<f>newFrame</f>(<n>80</n>, <n>40</n>, <f>color</f>(<n>0</n>, <n>0</n>, <n>0</n>))\n<k>local</k> SubFrame <k>=</k> ui.<f>newFrame</f>(<n>80</n>, <n>40</n>, <f>color</f>(<n>0</n>, <n>0</n>, <n>0</n>, <n>0</n>))\n<k>local</k> counter <k>=</k> <n>0</n>\nFrame.OnNestedPressEnd <k>=</k> <f>function</f>()\n\tcounter <k>=</k> counter <k>+</k> <n>1</n>\n\tFrame:<f>setText</f>(<s>\"FiraCode.ttf\"</s>, <f>tostring</f>(counter), <n>18</n>)\n<k>end</k>\nFrame:<f>addChild</f>(SubFrame)<c> -- Frame is covered, but press still works</c>";
	["Demo"] = function() -- function that creates and returns an element to be placed right below the code example
		local Frame = ui.newFrame(80, 40, color(0, 0, 0))
		local SubFrame = ui.newFrame(80, 40, color(0, 0, 0, 0))
		local counter = 0
		Frame.OnNestedPressEnd = function()
			counter = counter + 1
			Frame:setText("FiraCode.ttf", tostring(counter), 18)
		end
		Frame:addChild(SubFrame)
		return Frame
	end;
})

table.insert(content, {
	["Type"] = "Callback";
	["Name"] = "OnNestedPressStart";
	["Arguments"] = {"x", "y", "button", "istouch", "presses"};
	["Description"] = "Similar to OnPressStart. This is triggered when you start a press on an element, or any of its descendants. This can be useful to program scrolling frames with drag functionality.";
	["CodeMarkup"] = "<k>local</k> Frame <k>=</k> ui.<f>newFrame</f>(<n>80</n>, <n>40</n>, <f>color</f>(<n>0</n>, <n>0</n>, <n>0</n>))\n<k>local</k> SubFrame <k>=</k> ui.<f>newFrame</f>(<n>80</n>, <n>40</n>, <f>color</f>(<n>0</n>, <n>0</n>, <n>0</n>, <n>0</n>))\n<k>local</k> counter <k>=</k> <n>0</n>\nFrame.OnNestedPressStart <k>=</k> <f>function</f>()\n\tcounter <k>=</k> counter <k>+</k> <n>1</n>\n\tFrame:<f>setText</f>(<s>\"FiraCode.ttf\"</s>, <f>tostring</f>(counter), <n>18</n>)\n<k>end</k>\nFrame:<f>addChild</f>(SubFrame)<c> -- Frame is covered, but press still works</c>";
	["Demo"] = function() -- function that creates and returns an element to be placed right below the code example
		local Frame = ui.newFrame(80, 40, color(0, 0, 0))
		local SubFrame = ui.newFrame(80, 40, color(0, 0, 0, 0))
		local counter = 0
		Frame.OnNestedPressStart = function()
			counter = counter + 1
			Frame:setText("FiraCode.ttf", tostring(counter), 18)
		end
		Frame:addChild(SubFrame)
		return Frame
	end;
})

table.insert(content, {
	["Type"] = "Callback";
	["Name"] = "OnNestedScroll";
	["Arguments"] = {"x", "y"};
	["Description"] = "Called when the scroll wheel is moved when the mouse is focused on the element or one of its descendants. x and y are values indicating the direction of the scroll action. In most cases only the y-value is not zero.";
	["CodeMarkup"] = "<k>local</k> Frame <k>=</k> ui.<f>newFrame</f>(<n>80</n>, <n>40</n>, <f>color</f>(<n>0</n>, <n>0</n>, <n>0</n>))\n<k>local</k> FrameCover <k>=</k> ui.<f>newFrame</f>(<n>80</n>, <n>40</n>, <f>color</f>(<n>1</n>, <n>1</n>, <n>1</n>, <n>0</n>))\nFrame:<f>addChild</f>(FrameCover) <c>-- cover the Frame's OnScroll callback</c>\n<k>local</k> counter <k>=</k> <n>0</n>\nFrame.OnNestedScroll <k>=</k> <f>function</f>()\n\tcounter <k>=</k> counter <k>+</k> <n>1</n>\n\tFrame:<f>setText</f>(<s>\"FiraCode.ttf\"</s>, <f>tostring</f>(counter), <n>18</n>)\n<k>end</k>";
	["Demo"] = function() -- function that creates and returns an element to be placed right below the code example
		local Frame = ui.newFrame(80, 40, color(0, 0, 0))
		local FrameCover = ui.newFrame(80, 40, color(1, 1, 1, 0))
		Frame:addChild(FrameCover)
		local counter = 0
		Frame.OnNestedScroll = function()
			counter = counter + 1
			print(2)
			Frame:setText("FiraCode.ttf", tostring(counter), 18)
		end
		return Frame
	end;
})

table.insert(content, {
	["Type"] = "Callback";
	["Name"] = "OnPressEnd";
	["Arguments"] = {"x", "y", "button", "istouch", "presses"};
	["Description"] = "Called when you release a press while being focused on the element. x and y are the absolute cursor location on the screen. 'button' is the identifier of the mouse button, if applicable. istouch is a boolean indicating if the press was a touch event. The presses argument is the number of recent presses, which can be used to check for double-clicks.";
	["CodeMarkup"] = "<k>local</k> Frame <k>=</k> ui.<f>newFrame</f>(<n>80</n>, <n>40</n>, <f>color</f>(<n>0</n>, <n>0</n>, <n>0</n>))\n<k>local</k> counter <k>=</k> <n>0</n>\nFrame.OnPressEnd <k>=</k> <f>function</f>()\n\tcounter <k>=</k> counter <k>+</k> <n>1</n>\n\tFrame:<f>setText</f>(<s>\"FiraCode.ttf\"</s>, <f>tostring</f>(counter), <n>18</n>)\n<k>end</k>";
	["Demo"] = function() -- function that creates and returns an element to be placed right below the code example
		local Frame = ui.newFrame(80, 40, color(0, 0, 0))
		local counter = 0
		Frame.OnPressEnd = function()
			counter = counter + 1
			Frame:setText("FiraCode.ttf", tostring(counter), 18)
		end
		return Frame
	end;
})

table.insert(content, {
	["Type"] = "Callback";
	["Name"] = "OnPressStart";
	["Arguments"] = {"x", "y", "button", "istouch", "presses"};
	["Description"] = "Called when you initiate a press while being focused on the element. x and y are the absolute cursor location on the screen. 'button' is the identifier of the mouse button, if applicable. istouch is a boolean indicating if the press was a touch event. The presses argument is the number of recent presses, which can be used to check for double-clicks.";
	["CodeMarkup"] = "<k>local</k> Frame <k>=</k> ui.<f>newFrame</f>(<n>80</n>, <n>40</n>, <f>color</f>(<n>0</n>, <n>0</n>, <n>0</n>))\n<k>local</k> counter <k>=</k> <n>0</n>\nFrame.OnPressStart <k>=</k> <f>function</f>()\n\tcounter <k>=</k> counter <k>+</k> <n>1</n>\n\tFrame:<f>setText</f>(<s>\"FiraCode.ttf\"</s>, <f>tostring</f>(counter), <n>18</n>)\n<k>end</k>";
	["Demo"] = function() -- function that creates and returns an element to be placed right below the code example
		local Frame = ui.newFrame(80, 40, color(0, 0, 0))
		local counter = 0
		Frame.OnPressStart = function()
			counter = counter + 1
			Frame:setText("FiraCode.ttf", tostring(counter), 18)
		end
		return Frame
	end;
})

table.insert(content, {
	["Type"] = "Callback";
	["Name"] = "OnScroll";
	["Arguments"] = {"x", "y"};
	["Description"] = "Called when the mouse wheel scrolls when hovering over the element. x and y are values indicating the direction of the scroll action. In most cases only the y-value is not zero.";
	["CodeMarkup"] = "<k>local</k> Frame <k>=</k> ui.<f>newFrame</f>(<n>80</n>, <n>40</n>, <f>color</f>(<n>0</n>, <n>0</n>, <n>0</n>))\n<k>local</k> counter <k>=</k> <n>0</n>\nFrame.OnScroll <k>=</k> <f>function</f>()\n\tcounter <k>=</k> counter <k>+</k> <n>1</n>\n\tFrame:<f>setText</f>(<s>\"FiraCode.ttf\"</s>, <f>tostring</f>(counter), <n>18</n>)\n<k>end</k>";
	["Demo"] = function() -- function that creates and returns an element to be placed right below the code example
		local Frame = ui.newFrame(80, 40, color(0, 0, 0))
		local counter = 0
		Frame.OnScroll = function()
			counter = counter + 1
			Frame:setText("FiraCode.ttf", tostring(counter), 18)
		end
		return Frame
	end;
})

return {
	["Meta"] = meta;
	["Content"] = content;
}