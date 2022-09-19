
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
	["ValueType"] = "vector";
	["Name"] = "AbsoluteSize";
	["Description"] = "The exact size of the element in pixels. This property is updates whenever any method or event is called that manipulates positions or sizes. The computed values will be rounded down to prevent blurriness in the resulting draw calls.";
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
	["Description"] = "The width of the inner border of the element. When this is 0, no border is drawn. Otherwise, a border is drawn with a thickness in pixels equal to this property.\n\nNote: when a rotated element has a border, there may be a small gap between the border and the inner visuals, because the border is drawn around the element, rather than on top. Using some form of anti-aliasing may help reduce this problem. Otherwise, use a parent element with padding as a border.";
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
	["ValueType"] = "number";
	["Name"] = "CornerRadius";
	["Description"] = "Set to 0 by default. If this value is higher than 0, a rounded corner with a radius in pixels equal to this value will be drawn on the element.";
	["ReadOnly"] = false;
	["CodeMarkup"] = nil;
	["Demo"] = function()
		local Container = ui.newFrame(300, 50, color(0, 0, 0, 0))
		local f1 = ui.newFrame(140, 50, color(1, 1, 1))
		f1.CornerRadius = 0
		f1:setText("FiraCode.ttf", {{0, 0, 0}, "Radius = 0"}, 14)
		f1.TextBlock:alignX("center")
		f1.TextBlock:alignY("center")
		Container:addChild(f1)
		local f2 = ui.newFrame(140, 50, color(1, 1, 1))
		f2.CornerRadius = 16
		f2:alignX("right")
		f2:setText("FiraCode.ttf", {{0, 0, 0}, "Radius = 16"}, 14)
		f2.TextBlock:alignX("center")
		f2.TextBlock:alignY("center")
		Container:addChild(f2)
		return Container
	end;
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
		LargeSpeech:resize(0, 0, 100, 50)
		Container:addChild(LargeSpeech)
		local SmallSpeech = ui.newSlicedFrame(SpeechImg, vector(16, 16), vector(24, 24), 200, 200, nil, 7/10)
		SmallSpeech.FitTextOnResize = true
		SmallSpeech:setPadding(4)
		SmallSpeech:setText("FiraCode.ttf", {{0, 0, 0}, "Speech"}, 12)
		SmallSpeech.TextBlock:alignX("center")
		SmallSpeech.TextBlock:alignY("center")
		SmallSpeech:resize(0, 0, 70, 35)
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
	["Name"] = "Name";
	["Description"] = "The non-unique name of the instance. Names can be combined with the :child(name) method to find the first child with the given name in some parent instance.";
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
	["ValueType"] = "vector";
	["Name"] = "Padding";
	["Description"] = "Adds a padding to the UIBase.\n\n- Padding.x determines the padding in pixels on the left and right.\n- Padding.y determines the padding in pixels at the top and bottom.\n\nThis property applies to child elements and the UIBase's TextBlock. This value can be changed with :setPadding().";
	["ReadOnly"] = true;
	["CodeMarkup"] = nil;
	["Demo"] = nil;
})
--[[
table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "PaddingY";
	["Description"] = "Adds a padding on the top and bottom side of the UIBase in pixels. This property applies to child elements and the UIBase's TextBlock. This value can be changed with :setPadding().";
	["ReadOnly"] = true;
	["CodeMarkup"] = nil;
	["Demo"] = nil;
})
]]
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
	["ValueType"] = "vector";
	["Name"] = "Pivot";
	["Description"] = "Determines the point within the element to rotate around when a rotation is applied. vector(0,0) it the top left corner. vector(1,1) is the bottom right corner.";
	["ReadOnly"] = false;
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
	["Description"] = "How many degrees to rotate the object clockwise around its middle point.\n\nLimitations:\n\t- Visuals do not apply to children; They treat their parent as if there is no rotation.\n\t- Rotation does not change the hitbox of any click events.\n\t- When ClipContent is set to true, corners will be cut-off when rotated outside of the original orientation box.\n\t- Rotated elements may not render correctly if they barely stick out on the edge of the screen.";
	["ReadOnly"] = false;
	["CodeMarkup"] = nil;
	["Demo"] = function()
		local Container = ui.newFrame(130, 130)
		Container.Opacity = 0
		local Rotato = ui.newFrame(100, 100, color(0.3, 0.8, 0.7))
		Rotato.ClipContent = false
		Rotato:setPadding(10)
		--Rotato.CornerRadius = 18
		Rotato:setBorder(8)
		Rotato.Rotation = 20
		--Rotato.Color = color(0.3, 0.8, 0.7)
		Rotato.Pivot = vector(0.5, 0.5)
		Rotato:setText("FiraCode.ttf", "Rotated text!", 16)
		Rotato.TextBlock:alignX("left")
		Rotato.TextBlock:alignY("bottom")
		Rotato:alignX("center")
		Rotato:alignY("center")
		Container:addChild(Rotato)
		return Container
	end;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "Object";
	["Name"] = "Size";
	["Description"] = "An object with two properties: Scale and Offset. Both are vectors.\n\n- Scale determines the size as a fraction of its parent (while respecting padding). So a scale of 0.5 is half its parents size if no padding is present in the parent.\n- Offset is an additional size in absolute pixels, independent of its parent.";
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
		local function onClick()
			if Clickable.Position.Scale.x == 1 then
				Clickable:alignX("left")
			else
				Clickable:alignX("right")
			end
		end
		Clickable:on("FullPress", onClick)
		Clickable:on("Scroll", onClick)
		Clickable:on("Drag", onClick)
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
	["CodeMarkup"] = "<k>local</k> FrameCyan1 <k>=</k> ui.<f>newFrame</f>(<n>60</n>, <n>60</n>, <f>color</f>(<n>0</n>, <n>0.5</n>, <n>1</n>))\n<k>local</k> FrameCyan2 <k>=</k> ui.<f>newFrame</f>(<n>60</n>, <n>60</n>, <f>color</f>(<n>0</n>, <n>0.5</n>, <n>1</n>))\nFrameCyan1:<f>addTag</f>(<s>\"cyan\"</s>)\nFrameCyan2:<f>addTag</f>(<s>\"cyan\"</s>)\n<k>local</k> ButtonRed <k>=</k> ui.<f>newFrame</f>(<n>60</n>, <n>60</n>, <f>color</f>(<n>0.8</n>, <n>0.2</n>, <n>0.2</n>))\nFrameCyan2:<f>putNextTo</f>(FrameCyan1, <s>\"right\"</s>, <n>20</n>)\nButtonRed:<f>putNextTo</f>(FrameCyan2, <s>\"right\"</s>, <n>20</n>)\nButtonRed:<f>setText</f>(<s>\"FiraCode.ttf\"</s>, <s>\"Click to find cyan\"</s>, <n>18</n>)\nButtonRed:<f>on</f>(\"FullPress\", <f>function</f>()\n\t<k>local</k> Objects <k>=</k> ui:<f>find</f>(<s>\"cyan\"</s>)\n\t<k>for</k> i <k>=</k> 1, #Objects <k>do</k>\n\t\tObjects[i]:<f>setText</f>(<s>\"FiraCode.ttf\"</s>, <s>\"I am cyan!\"</s>, <n>18</n>)\n\t<k>end</k>\n<k>end</k>)";
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
		--[[
		ButtonRed.OnFullPress = function()
			local Objects = ui:find("cyan")
			for i = 1, #Objects do
				Objects[i]:setText("FiraCode.ttf", "I am cyan!", 18)
			end
		end
		]]
		ButtonRed:on("FullPress", function()
			local Objects = ui:find("cyan")
			for i = 1, #Objects do
				Objects[i]:setText("FiraCode.ttf", "I am cyan!", 18)
			end
		end)
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
	["Name"] = "child";
	["Arguments"] = {"name"};
	["Description"] = "Find the first child of the instance that has the given name. If no child is found, nil is returned. Otherwise, return the child object.";
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
--[[
table.insert(content, {
	["Type"] = "Method";
	["Name"] = "getPixelPadding";
	["Arguments"] = {};
	["Description"] = "Returns the padding on the x-axis and the y-axis.";
})
]]
table.insert(content, {
	["Type"] = "Method";
	["Name"] = "hasKeyboardFocus";
	["Arguments"] = {};
	["Description"] = "Returns 'true' if the current element has keyboard focus. If not, this returns 'false'.";
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
	["Name"] = "on";
	["Arguments"] = {"eventName", "function"};
	["Description"] = "Registers a function to be called when the given event triggered. When this method is called multiple times, each function will be called in the same order as they were registered.\n\nReturns a Connection object.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "positionContent";
	["Arguments"] = {"x", "y"};
	["Description"] = "Sets the ContentOffset property to the specified x and y coordinates.";
	["CodeMarkup"] = "<k>local</k> Container <k>=</k> ui.<f>newFrame</f>(<n>250</n>, <n>100</n>, <f>color</f>(<n>0</n>, <n>0</n>, <n>0</n>))\n<k>local</k> Child <k>=</k> ui.<f>newFrame</f>(<n>100</n>, <n>100</n>, <f>color</f>(<n>1</n>, <n>1</n>, <n>1</n>))\nChild:<f>on</f>(<s>\"FullPress\"</s>, <f>function</f>()\n\t<k>if</k> Container.ContentOffset.x <k>==</k> <n>0</n> <k>then</k>\n\t\tContainer:<f>positionContent</f>(<n>150</n>, <n>0</n>)\n\t<k>else</k>\n\t\tContainer:<f>positionContent</f>(<n>0</n>, <n>0</n>)\n\t<k>end</k>\n<k>end</k>)\nContainer:<f>addChild</f>(Child)";
	["Demo"] = function()
		local Container = ui.newFrame(250, 100, color(0, 0, 0))
		local Child = ui.newFrame(100, 100, color(1, 1, 1))
		--Child.OnFullPress = function()
		Child:on("FullPress", function()
			if Container.ContentOffset.x == 0 then
				Container:positionContent(150, 0)
			else
				Container:positionContent(0, 0)
			end
		end)
		Container:addChild(Child)
		return Container
	end
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "putNextTo";
	["Arguments"] = {"Object", "side", "offset"};
	["Description"] = "Moves the element to be positioned next to 'Object'. 'side' is a string determining on which of the four sides the object should be placed. The value can be either 'top'/'above', 'bottom'/'under'/'below', 'left' or 'right'. The offset value determines a distance in pixels between the two elements.\n\nNote: The position of an element may be unknown before being assigned a parent, in which case this method may not position the element correctly.";
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
	["Name"] = "renderTo";
	["Arguments"] = {"canvas", "mipmaps"};
	["Description"] = "Draw the UI object and its children to a given canvas object. Mipmaps is the number of mipmaps used when drawing to the canvas. The UI properly resizes itself to fit the canvas' size.";
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
	["Arguments"] = {"a", "b", "c", "d"};
	["Description"] = "Resizes the element. This also updates the AbsolutePosition and AbsoluteSize of the element and its children. There are multiple ways of calling this method:\n\n1. The first two arguments are numbers. This will only set the Offset part of the Size property and the Scale part will be zero.\n\n2. The first two arguments are vectors. This will set the Scale property of the element to the first vector and the Offset property to the second vector.\n\n3. All four arguments are numbers. This will set the Scale property to a vector using the first two numbers and the Offset property to a vector using the last two numbers.";
	["CodeMarkup"] = "<k>local</k> Frame1 <k>=</k> ui.<f>newFrame</f>(<n>100</n>, <n>100</n>, <f>color</f>(<n>0</n>, <n>0</n>, <n>0</n>))\nFrame1:<f>setText</f>(<s>\"FiraCode.ttf\"</s>, <s>\"Frame 1\"</s>, <n>18</n>)\n<k>local</k> Frame2 <k>=</k> ui.<f>newFrame</f>(<n>100</n>, <n>100</n>, <f>color</f>(<n>0</n>, <n>0</n>, <n>0</n>))\nFrame2:<f>setText</f>(<s>\"FiraCode.ttf\"</s>, <s>\"Frame 2\"</s>, <n>18</n>)\nFrame2:<f>resize</f>(<n>130</n>, <n>80</n>)";
	["Demo"] = function() -- function that creates and returns an element to be placed right below the code example
		local Container = ui.newFrame(300, 100)
		Container.Opacity = 0
		local Frame1 = ui.newFrame(100, 100, color(0, 0, 0))
		Frame1:setText("FiraCode.ttf", "Frame 1", 18)
		local Frame2 = ui.newFrame(100, 100, color(0, 0, 0))
		Frame2:setText("FiraCode.ttf", "Frame 2", 18)
		Frame2:putNextTo(Frame1, "right", 20)
		Frame2:resize(0, 0, 130, 80)
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
	["Description"] = "Sets the horizontal and vertical padding of an element. If the second argument is missing, the first argument replaces it. Horizontal and vertical padding applies on both of their edges. Padding will apply to the object's childrens' positions and the object's TextBlock.";
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
	["CodeMarkup"] = "<k>local</k> Container <k>=</k> ui.<f>newFrame</f>(<n>250</n>, <n>100</n>, <f>color</f>(<n>0</n>, <n>0</n>, <n>0</n>))\n<k>local</k> Child <k>=</k> ui.<f>newFrame</f>(<n>100</n>, <n>100</n>, <f>color</f>(<n>1</n>, <n>1</n>, <n>1</n>))\nChild:<f>on</f>(<s>\"FullPress\"</s>, <f>function</f>()\n\t<k>if</k> Container.ContentOffset.x <k><</k> <n>150</n> <k>then</k>\n\t\tContainer:<f>shiftContent</f>(<n>25</n>, <n>0</n>)\n\t<k>else</k>\n\t\tContainer:<f>shiftContent</f>(<n>-150</n>, <n>0</n>)\n\t<k>end</k>\n<k>end</k>)\nContainer:<f>addChild</f>(Child)";
	["Demo"] = function()
		local Container = ui.newFrame(250, 100, color(0, 0, 0))
		local Child = ui.newFrame(100, 100, color(1, 1, 1))
		--Child.OnFullPress = function()
		Child:on("FullPress", function()
			if Container.ContentOffset.x < 150 then
				Container:shiftContent(25, 0)
			else
				Container:shiftContent(-150, 0)
			end
		end)
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
		--frameLeft.OnPressStart = function() frameLeft:toBack() end
		frameLeft:on("PressStart", function() frameLeft:toBack() end)
		local frameRight = ui.newFrame(160, 120, color(0.3, 0.5, 0.7))
		frameRight:alignX("right")
		frameRight:setPadding(10, 10)
		frameRight:setText("FiraCode.ttf", "Click me!", 18)
		frameRight.TextBlock:alignX("right")
		frameRight:on("PressStart", function() frameRight:toBack() end)
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
		frameLeft:on("PressStart", function() frameLeft:toFront() end)
		local frameRight = ui.newFrame(160, 120, color(0.3, 0.5, 0.7))
		frameRight:alignX("right")
		frameRight:setPadding(10, 10)
		frameRight:setText("FiraCode.ttf", "Click me!", 18)
		frameRight.TextBlock:alignX("right")
		frameRight:on("PressStart", function() frameRight:toFront() end)
		Container:addChild(frameLeft)
		Container:addChild(frameRight)
		return Container
	end;
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Events";
	["Description"] = "";
})


table.insert(content, {
	["Type"] = "Event";
	["Name"] = "Drag";
	["Arguments"] = {"dx", "dy", "button", "offX", "offY"};
	["Description"] = "Called when you drag an element. A drag is when you first press the element and then move the cursor while keeping the press active. A drag may go outside the box of the element and it will still count as an active press. dx and dy are numbers indicating the relative movement in the current frame. button is the mouse button (1 for touch drags). offX and offY are an offset in pixels relative to the starting point of the drag.";
	["CodeMarkup"] = "<k>local</k> Draggable <k>=</k> ui.<f>newFrame</f>(<n>80</n>, <n>80</n>, <f>color</f>(<n>1</n>, <n>1</n>, <n>1</n>))\n<k>local</k> x, y <k>=</k> <n>0</n>, <n>0</n>\nDraggable:<f>on</f>(<s>\"PressStart\"</s>, <f>function</f>()\n\tx <k>=</k> Draggable.Position.Offset.x\n\ty <k>=</k> Draggable.Position.Offset.y\n<k>end</k>)\nDraggable:<f>on</f>(<s>\"Drag\"</s>, <f>function</f>(<a>dx</a>, <a>dy</a>, <a>button</a>, <a>offX</a>, <a>offY</a>)\n\t<k>if</k> button <k>==</k> <n>1</n> <k>then</k>\n\t\t<k>local</k> clampedX = math.<f>min</f>(<n>220</n>, math.<f>max</f>(<n>0</n>, x <k>+</k> offX))\n\t\t<k>local</k> clampedY = math.<f>min</f>(<n>220</n>, math.<f>max</f>(<n>0</n>, y <k>+</k> offY))\n\t\tDraggable:<f>reposition</f>(<n>0</n>, <n>0</n>, clampedX, clampedY)\n\t<k>end</k>\n<k>end</k>)";
	["Demo"] = function() -- function that creates and returns an element to be placed right below the code example
		local Container = ui.newFrame(300, 180, color(0, 0, 0))
		local Draggable = ui.newFrame(80, 80, color(1, 1, 1))
		local x, y = 0, 0
		Draggable:on("PressStart", function()
			x = Draggable.Position.Offset.x
			y = Draggable.Position.Offset.y
		end)
		Draggable:on("Drag", function(dx, dy, button, offX, offY)
			if button == 1 then
				local clampedX = math.min(220, math.max(0, x + offX))
				local clampedY = math.min(100, math.max(0, y + offY))
				Draggable:reposition(0, 0, clampedX, clampedY)
			end
		end)
		Container:addChild(Draggable)
		return Container
	end;
})

table.insert(content, {
	["Type"] = "Event";
	["Name"] = "DragEnd";
	["Arguments"] = {"offX", "offY", "button"};
	["Description"] = "Called when you stop dragging the element. offX and offY are an offset in pixels relative to the starting point of the drag. button is the mouse button id (1 for touch drags).";
})

table.insert(content, {
	["Type"] = "Event";
	["Name"] = "FullPress";
	["Arguments"] = {"x", "y", "button", "istouch", "presses"};
	["Description"] = "Called when you hold down and release your cursor on the element without leaving its bounding box in the process. x and y are the absolute cursor location on the screen. 'button' is the identifier of the mouse button, if applicable. istouch is a boolean indicating if the press was a touch event. The presses argument is the number of recent presses, which can be used to check for double-clicks.";
	["CodeMarkup"] = "<k>local</k> Frame <k>=</k> ui.<f>newFrame</f>(<n>80</n>, <n>40</n>, <f>color</f>(<n>0</n>, <n>0</n>, <n>0</n>))\n<k>local</k> counter <k>=</k> <n>0</n>\nFrame:<f>on</f>(<s>\"FullPress\"</s>, <f>function</f>()\n\tcounter <k>=</k> counter <k>+</k> <n>1</n>\n\tFrame:<f>setText</f>(<s>\"FiraCode.ttf\"</s>, <f>tostring</f>(counter), <n>18</n>)\n<k>end</k>)";
	["Demo"] = function() -- function that creates and returns an element to be placed right below the code example
		local Frame = ui.newFrame(80, 40, color(0, 0, 0))
		local counter = 0
		Frame:on("FullPress", function()
			counter = counter + 1
			Frame:setText("FiraCode.ttf", tostring(counter), 18)
		end)
		return Frame
	end;
})

table.insert(content, {
	["Type"] = "Event";
	["Name"] = "HoverEnd";
	["Arguments"] = {};
	["Description"] = "Called when the mouse leaves the bounding box of the UI element.";
	["CodeMarkup"] = "<k>local</k> Frame <k>=</k> ui.<f>newFrame</f>(<n>80</n>, <n>40</n>, <f>color</f>(<n>0</n>, <n>0</n>, <n>0</n>))\n<k>local</k> counter <k>=</k> <n>0</n>\nFrame:<f>on</f>(<s>\"HoverEnd\"</s>, <f>function</f>()\n\tcounter <k>=</k> counter <k>+</k> <n>1</n>\n\tFrame:<f>setText</f>(<s>\"FiraCode.ttf\"</s>, <f>tostring</f>(counter), <n>18</n>)\n<k>end</k>)";
	["Demo"] = function() -- function that creates and returns an element to be placed right below the code example
		local Frame = ui.newFrame(80, 40, color(0, 0, 0))
		local counter = 0
		Frame:on("HoverEnd", function()
			counter = counter + 1
			Frame:setText("FiraCode.ttf", tostring(counter), 18)
		end)
		return Frame
	end;
})

table.insert(content, {
	["Type"] = "Event";
	["Name"] = "HoverStart";
	["Arguments"] = {};
	["Description"] = "Called when the mouse enters the bounding box of the UI element.";
	["CodeMarkup"] = "<k>local</k> Frame <k>=</k> ui.<f>newFrame</f>(<n>80</n>, <n>40</n>, <f>color</f>(<n>0</n>, <n>0</n>, <n>0</n>))\n<k>local</k> counter <k>=</k> <n>0</n>\nFrame:<f>on</f>(<s>\"HoverStart\"</s>, <f>function</f>()\n\tcounter <k>=</k> counter <k>+</k> <n>1</n>\n\tFrame:<f>setText</f>(<s>\"FiraCode.ttf\"</s>, <f>tostring</f>(counter), <n>18</n>)\n<k>end</k>)";
	["Demo"] = function() -- function that creates and returns an element to be placed right below the code example
		local Frame = ui.newFrame(80, 40, color(0, 0, 0))
		local counter = 0
		Frame:on("HoverStart", function()
			counter = counter + 1
			Frame:setText("FiraCode.ttf", tostring(counter), 18)
		end)
		return Frame
	end;
})

table.insert(content, {
	["Type"] = "Event";
	["Name"] = "KeyboardFocus";
	["Arguments"] = {};
	["Description"] = "Called when ui:focusKeyboard() puts the current UI element as one of its focus targets. Note that this does not trigger when focusKeyboard is called when the current element already has focus.";
})

table.insert(content, {
	["Type"] = "Event";
	["Name"] = "KeyboardLost";
	["Arguments"] = {};
	["Description"] = "Called when the keyboard focus is lost, which is when ui:focusKeyboard() is called and the given element is no longer supplied as one of the focus targets.";
})

table.insert(content, {
	["Type"] = "Event";
	["Name"] = "KeyEntered";
	["Arguments"] = {"key", "scancode"};
	["Description"] = "Called when a key on the keyboard is pressed while the current UI element has focus through the ui:focusKeyboard() method. The 'key' and 'scancode' arguments are the same as the Love2D ones for keypressed. You can use this event to implement your own text fields.";
	["Demo"] = function()
		local base = color(0.95, 0.95, 0.95)
		local highlight = color(0.7, 0.7, 0.7)
		local TF = ui.newFrame(240, 30, base)
		TF:setBorder(color(0.8, 0.8, 0.8), 2)
		TF:setText("FiraCode.ttf", "text field (click me!)", 14)
		TF.TextBlock:alignX("center")
		TF.TextBlock:alignY("center")
		TF.TextBlock.Color = color(0.2, 0.2, 0.2)
		TF:on("PressStart", function()
			ui:focusKeyboard({TF}, "click", "other")
		end)
		TF:on("KeyboardFocus", function()
			TF.TextBlock:setText("")
			TF.Color = highlight
			TF.ColorFocus = highlight
			TF.ColorHold = highlight
		end)
		TF:on("KeyboardLost", function()
			TF.Color = base
			TF.ColorFocus = base
			TF.ColorHold = base
		end)
		TF:on("KeyEntered", function(key, scancode)
			print(key, scancode, key:byte())
			if scancode == "backspace" then
				TF.TextBlock:setText(TF.TextBlock:getText():sub(1, -2))
			elseif scancode == "space" then
				TF.TextBlock:setText(TF.TextBlock:getText() .. " ")
			elseif string.len(key) == 1 then
				if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
					TF.TextBlock:setText(TF.TextBlock:getText() .. key:upper())
				else
					TF.TextBlock:setText(TF.TextBlock:getText() .. key)
				end
			end
		end)
		return TF
	end;
})

table.insert(content, {
	["Type"] = "Event";
	["Name"] = "NestedDrag";
	["Arguments"] = {"dx", "dy", "button", "offX", "offY"};
	["Description"] = "Called when you drag an element, or any of its descendants. A drag is when you first press the element and then move the cursor while keeping the press active. A drag may go outside the box of the element and it will still count as an active press. dx and dy are numbers indicating the relative movement in the current frame. button is the mouse button id (1 for touch drags). offX and offY are an offset in pixels relative to the starting point of the drag.";
})

table.insert(content, {
	["Type"] = "Event";
	["Name"] = "NestedDragEnd";
	["Arguments"] = {"offX", "offY", "button"};
	["Description"] = "Called when you stop dragging the element, or any of its descendants. offX and offY are an offset in pixels relative to the starting point of the drag. button is the mouse button id (1 for touch drags).";
})

table.insert(content, {
	["Type"] = "Event";
	["Name"] = "NestedPressEnd";
	["Arguments"] = {"x", "y", "button", "istouch", "presses"};
	["Description"] = "Similar to OnPressEnd. This is triggered when you release a press on an element, or any of its descendants.";
	["CodeMarkup"] = "<k>local</k> Frame <k>=</k> ui.<f>newFrame</f>(<n>80</n>, <n>40</n>, <f>color</f>(<n>0</n>, <n>0</n>, <n>0</n>))\n<k>local</k> SubFrame <k>=</k> ui.<f>newFrame</f>(<n>80</n>, <n>40</n>, <f>color</f>(<n>0</n>, <n>0</n>, <n>0</n>, <n>0</n>))\n<k>local</k> counter <k>=</k> <n>0</n>\nFrame:<f>on</f>(<s>\"NestedPressEnd\"</s>, <f>function</f>()\n\tcounter <k>=</k> counter <k>+</k> <n>1</n>\n\tFrame:<f>setText</f>(<s>\"FiraCode.ttf\"</s>, <f>tostring</f>(counter), <n>18</n>)\n<k>end</k>)\nFrame:<f>addChild</f>(SubFrame)<c> -- Frame is covered, but press still works</c>";
	["Demo"] = function() -- function that creates and returns an element to be placed right below the code example
		local Frame = ui.newFrame(80, 40, color(0, 0, 0))
		local SubFrame = ui.newFrame(80, 40, color(0, 0, 0, 0))
		local counter = 0
		Frame:on("NestedPressEnd", function()
			counter = counter + 1
			Frame:setText("FiraCode.ttf", tostring(counter), 18)
		end)
		Frame:addChild(SubFrame)
		return Frame
	end;
})

table.insert(content, {
	["Type"] = "Event";
	["Name"] = "NestedPressStart";
	["Arguments"] = {"x", "y", "button", "istouch", "presses"};
	["Description"] = "Similar to OnPressStart. This is triggered when you start a press on an element, or any of its descendants. This can be useful to program scrolling frames with drag functionality.";
	["CodeMarkup"] = "<k>local</k> Frame <k>=</k> ui.<f>newFrame</f>(<n>80</n>, <n>40</n>, <f>color</f>(<n>0</n>, <n>0</n>, <n>0</n>))\n<k>local</k> SubFrame <k>=</k> ui.<f>newFrame</f>(<n>80</n>, <n>40</n>, <f>color</f>(<n>0</n>, <n>0</n>, <n>0</n>, <n>0</n>))\n<k>local</k> counter <k>=</k> <n>0</n>\nFrame:<f>on</f>(<s>\"NestedPressStart\"</s>, <f>function</f>()\n\tcounter <k>=</k> counter <k>+</k> <n>1</n>\n\tFrame:<f>setText</f>(<s>\"FiraCode.ttf\"</s>, <f>tostring</f>(counter), <n>18</n>)\n<k>end</k>)\nFrame:<f>addChild</f>(SubFrame)<c> -- Frame is covered, but press still works</c>";
	["Demo"] = function() -- function that creates and returns an element to be placed right below the code example
		local Frame = ui.newFrame(80, 40, color(0, 0, 0))
		local SubFrame = ui.newFrame(80, 40, color(0, 0, 0, 0))
		local counter = 0
		Frame:on("NestedPressStart", function()
			counter = counter + 1
			Frame:setText("FiraCode.ttf", tostring(counter), 18)
		end)
		Frame:addChild(SubFrame)
		return Frame
	end;
})

table.insert(content, {
	["Type"] = "Event";
	["Name"] = "NestedScroll";
	["Arguments"] = {"x", "y"};
	["Description"] = "Called when the scroll wheel is moved when the mouse is focused on the element or one of its descendants. x and y are values indicating the direction of the scroll action. In most cases only the y-value is not zero.";
	["CodeMarkup"] = "<k>local</k> Frame <k>=</k> ui.<f>newFrame</f>(<n>80</n>, <n>40</n>, <f>color</f>(<n>0</n>, <n>0</n>, <n>0</n>))\n<k>local</k> FrameCover <k>=</k> ui.<f>newFrame</f>(<n>80</n>, <n>40</n>, <f>color</f>(<n>1</n>, <n>1</n>, <n>1</n>, <n>0</n>))\nFrame:<f>addChild</f>(FrameCover) <c>-- cover the Frame's OnScroll callback</c>\n<k>local</k> counter <k>=</k> <n>0</n>\nFrame:<f>on</f>(<s>\"NestedScroll\"</s>, <f>function</f>()\n\tcounter <k>=</k> counter <k>+</k> <n>1</n>\n\tFrame:<f>setText</f>(<s>\"FiraCode.ttf\"</s>, <f>tostring</f>(counter), <n>18</n>)\n<k>end</k>)";
	["Demo"] = function() -- function that creates and returns an element to be placed right below the code example
		local Frame = ui.newFrame(80, 40, color(0, 0, 0))
		local FrameCover = ui.newFrame(80, 40, color(1, 1, 1, 0))
		Frame:addChild(FrameCover)
		local counter = 0
		Frame:on("NestedScroll", function()
			counter = counter + 1
			Frame:setText("FiraCode.ttf", tostring(counter), 18)
		end)
		return Frame
	end;
})

table.insert(content, {
	["Type"] = "Event";
	["Name"] = "PressEnd";
	["Arguments"] = {"x", "y", "button", "istouch", "presses"};
	["Description"] = "Called when you release a press while being focused on the element. x and y are the absolute cursor location on the screen. 'button' is the identifier of the mouse button, if applicable. istouch is a boolean indicating if the press was a touch event. The presses argument is the number of recent presses, which can be used to check for double-clicks.";
	["CodeMarkup"] = "<k>local</k> Frame <k>=</k> ui.<f>newFrame</f>(<n>80</n>, <n>40</n>, <f>color</f>(<n>0</n>, <n>0</n>, <n>0</n>))\n<k>local</k> counter <k>=</k> <n>0</n>\nFrame:<f>on</f>(<s>\"PressEnd\"</s>, <f>function</f>()\n\tcounter <k>=</k> counter <k>+</k> <n>1</n>\n\tFrame:<f>setText</f>(<s>\"FiraCode.ttf\"</s>, <f>tostring</f>(counter), <n>18</n>)\n<k>end</k>)";
	["Demo"] = function() -- function that creates and returns an element to be placed right below the code example
		local Frame = ui.newFrame(80, 40, color(0, 0, 0))
		local counter = 0
		Frame:on("PressEnd", function()
			counter = counter + 1
			Frame:setText("FiraCode.ttf", tostring(counter), 18)
		end)
		return Frame
	end;
})

table.insert(content, {
	["Type"] = "Event";
	["Name"] = "PressStart";
	["Arguments"] = {"x", "y", "button", "istouch", "presses"};
	["Description"] = "Called when you initiate a press while being focused on the element. x and y are the absolute cursor location on the screen. 'button' is the identifier of the mouse button, if applicable. istouch is a boolean indicating if the press was a touch event. The presses argument is the number of recent presses, which can be used to check for double-clicks.";
	["CodeMarkup"] = "<k>local</k> Frame <k>=</k> ui.<f>newFrame</f>(<n>80</n>, <n>40</n>, <f>color</f>(<n>0</n>, <n>0</n>, <n>0</n>))\n<k>local</k> counter <k>=</k> <n>0</n>\nFrame:<f>on</f>(<s>\"PressStart\"</s>, <f>function</f>()\n\tcounter <k>=</k> counter <k>+</k> <n>1</n>\n\tFrame:<f>setText</f>(<s>\"FiraCode.ttf\"</s>, <f>tostring</f>(counter), <n>18</n>)\n<k>end</k>)";
	["Demo"] = function() -- function that creates and returns an element to be placed right below the code example
		local Frame = ui.newFrame(80, 40, color(0, 0, 0))
		local counter = 0
		Frame:on("PressStart", function()
			counter = counter + 1
			Frame:setText("FiraCode.ttf", tostring(counter), 18)
		end)
		return Frame
	end;
})

table.insert(content, {
	["Type"] = "Event";
	["Name"] = "Resize";
	["Arguments"] = {};
	["Description"] = "Called when the UI object changes its size, which can happen when the window changes size, a parent element changes its size or the UI object itself changes its size. This is called at most once per frame.";
})

table.insert(content, {
	["Type"] = "Event";
	["Name"] = "Scroll";
	["Arguments"] = {"x", "y"};
	["Description"] = "Called when the mouse wheel scrolls when hovering over the element. x and y are values indicating the direction of the scroll action. In most cases only the y-value is not zero.";
	["CodeMarkup"] = "<k>local</k> Frame <k>=</k> ui.<f>newFrame</f>(<n>80</n>, <n>40</n>, <f>color</f>(<n>0</n>, <n>0</n>, <n>0</n>))\n<k>local</k> counter <k>=</k> <n>0</n>\nFrame:<f>on</f>(<s>\"Scroll\"</s>, <f>function</f>()\n\tcounter <k>=</k> counter <k>+</k> <n>1</n>\n\tFrame:<f>setText</f>(<s>\"FiraCode.ttf\"</s>, <f>tostring</f>(counter), <n>18</n>)\n<k>end</k>)";
	["Demo"] = function() -- function that creates and returns an element to be placed right below the code example
		local Frame = ui.newFrame(80, 40, color(0, 0, 0))
		local counter = 0
		Frame:on("Scroll", function()
			counter = counter + 1
			Frame:setText("FiraCode.ttf", tostring(counter), 18)
		end)
		return Frame
	end;
})

return {
	["Meta"] = meta;
	["Content"] = content;
}