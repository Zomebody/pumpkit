
local meta = {
	["Name"] = "ui";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The UI Module";
	["Description"] = "A module used to create different types of UI primitives and render them on screen. It also supports many different events.\n\nThe UI system has its own hierarchy. The root of the hierarchy is the UI module itself: This module has a 'Children' property which is an array containing UI elements. Each UI element can have its own children as well. Each child has one Parent property, which can be used to traverse the UI hierarchy back up.\n\nIn order to draw an element, it has to be parented to the UI system, either as a child of the module's root, or as the child of another UI element that is part of the UI hierarchy.\n\nThe order in which children are drawn depends on the order in which they are parented. Newly parented children are appended to the end of the element's children array. Objects are drawn in a 'Preorder' sequence, meaning children at the end of a list are drawn last (on top) and the child of an element is always drawn later than its parent.\n\nBelow is an example hierarchy that is color-coded. Next to it is a recreation showing how the elements overlap in practice, generated with code.";
	["Demo"] = function()
		local Container = ui.newFrame(500, 200, color(1, 1, 1, 0))

		local Img = love.graphics.newImage("test_images/hierarchy.png")
		local Example = ui.newImageFrame(Img)
		Example.CornerRadius = 6
		Container:addChild(Example)

		local Tree = ui.newFrame(150, 200, color(1, 1, 1))
		Tree.CornerRadius = 6
		Tree:setPadding(10, 10)

		local C1 = ui.newFrame(70, 100, color.fromHex("#D5E8D4"))
		C1.ClipContent = false
		C1:setBorder(color(C1.Color):darken(0.25), 5)
		Tree:addChild(C1)
		local C2 = ui.newFrame(70, 100, color.fromHex("#FFCE9F"))
		C2.ClipContent = false
		C2:setBorder(color(C2.Color):darken(0.25), 5)
		C2:alignX("right")
		C2:alignY("bottom")
		Tree:addChild(C2)

		local L1 = ui.newFrame(40, 40, color.fromHex("#D4E1F5"))
		L1:setBorder(color(L1.Color):darken(0.25), 5)
		L1:alignX("right")
		C1:addChild(L1)
		local L2 = ui.newFrame(60, 60, color.fromHex("#FFF2CC"))
		L2.CornerRadius = 40
		L2:setBorder(color(L2.Color):darken(0.25), 5)
		L2:alignX("right")
		L2:alignY("bottom")
		L2.Center = vector(0.6, 0.6)
		C1:addChild(L2)
		local L3 = ui.newFrame(40, 40, color.fromHex("#F8CECC"))
		L3:setBorder(color(L3.Color):darken(0.25), 5)
		L3:alignX("center")
		L3:alignY("center")
		C2:addChild(L3)

		Tree:alignX("right")
		Container:addChild(Tree)

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
	["ValueType"] = "boolean";
	["Name"] = "Changed";
	["Description"] = "A boolean indicating whether or not the visual layout of the UI hierarchy has changed during this frame. This boolean is set to true when the ContentOffset, Size, Position, PaddingX, PaddingY or Hidden property changes on any object, or when an object is reparented. This boolean is used internally to check if CursorFocus should be recalculated at the end of the ui update cycle.";
	["ReadOnly"] = true;
	["CodeMarkup"] = nil;
	["Demo"] = nil;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "Object";
	["Name"] = "Children";
	["Description"] = "A list of UI elements that are parented directly to the UI root. Elements can be added through the :addChild() method. UI elements need to be descendants of the UI root in order to be drawn.";
	["ReadOnly"] = true;
	["CodeMarkup"] = nil;
	["Demo"] = nil;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "Object";
	["Name"] = "CursorFocus";
	["Description"] = "Either nil or a reference to a UI object that the mouse is currently targeting. An element that is hidden cannot become the CursorFocus. This property is used internally to trigger events on UI objects and to color elements.";
	["ReadOnly"] = true;
	["CodeMarkup"] = nil;
	["Demo"] = nil;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "boolean";
	["Name"] = "DragActive";
	["Description"] = "A boolean indicating if an element is currently undergoing a drag. An element does not need to have drag-related callbacks for a drag to become active. DragActive is set to false after the mouserelease event is triggered, so it can be used within the mouserelease function to check if a drag was active prior.";
	["ReadOnly"] = true;
	["CodeMarkup"] = nil;
	["Demo"] = nil;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "vector";
	["Name"] = "DragStart";
	["Description"] = "A vector describing the x and y location of the cursor where it was on screen when the drag first started.";
	["ReadOnly"] = true;
	["CodeMarkup"] = nil;
	["Demo"] = nil;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "Object";
	["Name"] = "DragTarget";
	["Description"] = "A reference to the UI element that is currently experiencing a drag. An element does not need to have any drag-related callbacks for it to become a drag target.";
	["ReadOnly"] = true;
	["CodeMarkup"] = nil;
	["Demo"] = nil;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "table";
	["Name"] = "KeyboardFocus";
	["Description"] = "An array with UI elements that currently have keyboard focus.";
	["ReadOnly"] = true;
	["CodeMarkup"] = nil;
	["Demo"] = nil;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "table";
	["Name"] = "KeyboardFocusMode";
	["Description"] = "An array with two indexes of the form {mode, argument} where 'mode' is a string representing the type of action that will cause the keyboard focus to be lost automatically and 'argument' is additional data for the current mode. See ui:focusKeyboard() for more details.";
	["ReadOnly"] = true;
	["CodeMarkup"] = nil;
	["Demo"] = nil;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "KeyboardFocusState";
	["Description"] = "A semaphore number that keeps track of how often keyboard focus changes.";
	["ReadOnly"] = true;
	["CodeMarkup"] = nil;
	["Demo"] = nil;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "PressedButton";
	["Description"] = "A variable used internally for drag events to keep track of which button is pressed. This should not be used.";
	["ReadOnly"] = true;
	["CodeMarkup"] = nil;
	["Demo"] = nil;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "Object";
	["Name"] = "PressedElement";
	["Description"] = "The current UI element that is being held down by the cursor. This property should eventually be replaced with a dictionary listing for the different mouse buttons, finger taps or gamepad buttons which ones are holding down which elements. This property is used internally to trigger events on UI objects and to color elements.";
	["ReadOnly"] = true;
	["CodeMarkup"] = nil;
	["Demo"] = nil;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "vector";
	["Name"] = "Size";
	["Description"] = "A vector describing the size of the viewport in which UI can be rendered. This property is used internally to update the AbsolutePosition of UI elements.";
	["ReadOnly"] = true;
	["CodeMarkup"] = nil;
	["Demo"] = nil;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "TotalCreated";
	["Description"] = "A number indicating how many UI objects have ever been created. This property is used internally to assign a unique ID to each UI element.";
	["ReadOnly"] = true;
	["CodeMarkup"] = nil;
	["Demo"] = nil;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "vector";
	["Name"] = "Visible";
	["Description"] = "If true, UI is rendered. If false, no UI is rendered. This property can be used to disable UI during cutscenes or to add a 'screenshot mode'.";
	["ReadOnly"] = true;
	["CodeMarkup"] = nil;
	["Demo"] = nil;
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
	["Description"] = "Sets the parent of the given object to the UI root. It also removes the child from the old parent's child list.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "at";
	["Arguments"] = {"x", "y"};
	["Description"] = "This method will return for the given x and y coordinate which element is being drawn at that location on the screen. This method is also used internally to set the CursorFocus property.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "find";
	["Arguments"] = {"name"};
	["Description"] = "Returns an array of objects that have been marked with the given name. If no results are found, the array is empty.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "focusKeyboard";
	["Arguments"] = {"Objects", "focusMode", "modeArg"};
	["Description"] = "Set the keyboard to focus on the given object or list of objects (UI elements). When a UI element has keyboard focus, any key-press will trigger the OnKeyEntered event of that UI element. 'focusMode' must either be the string 'key' or 'click' or nil:\n\n- When set to 'key', the 'modeArg' argument must be a string representing a key, or an array of key strings. When any of those keys are pressed, the UI element automatically loses focus.\n\n- When set to 'click', the 'modeArg' variable must be set to 'self' to lose keyboard focus when the UI element is clicked, or 'other', to indicate anything but the UI element itself must be clicked to lose focus. Additionally, nil can be used to always lose keyboard focus on a click.\n\nIf no objects are passed, the keyboard focus will be (re)set to nothing.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "hasKeyboardFocus";
	["Arguments"] = {"element"};
	["Description"] = "Returns 'true' if the given UI element has keybord focus. If not, 'false' is returned.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "initialize";
	["Arguments"] = {"autoRender = true"};
	["Description"] = "This method can only be called once. It will initialize the UI module by hooking into other Love2D functions and adding additional behavior there to make the system run. This method should be called right when the program first loads. After that, the system will be initialized and run forever.\r\rIf autoRender is set to true, ui:render() will automatically be called at the end of each love.draw call.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "getCursorSpeed";
	["Arguments"] = {"frameCount = 20"};
	["Description"] = "Returns a vector of the average speed of the cursor (in pixels per second) during the last few frames. If no argument is passed, the average speed of the last 20 is used. The maximum is 30.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "hide";
	["Arguments"] = {};
	["Description"] = "If the Visible property is set to true, this will set the property to false. Any highlighted element will lose its focus.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "render";
	["Arguments"] = {};
	["Description"] = "This method will render all UI on the screen by recursively calling :draw() on all of the UI root's children.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "renderTo";
	["Arguments"] = {"canvas", "mipmaps"};
	["Description"] = "Draw the whole UI to a given canvas object. Mipmaps is the number of mipmaps used when drawing to the canvas. The UI properly resizes itself to fit the canvas' size.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "show";
	["Arguments"] = {};
	["Description"] = "If the Visible property is set to false, this will set the property back to true so the UI can be drawn again.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "unfocusKeyboard";
	["Arguments"] = {"Objects"};
	["Description"] = "Removes keyboard focus from the given object or list of objects. See the focusKeyboard method for more information.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Events";
	["Description"] = "UI events are processed in different ways by hooking into Love2D's events, such as e.g. love.mousemoved and love.mousepressed.\n\nWhen the UI system is first initialized by the ui:initialize() method, a process called 'Monkey Patching' takes place, which will replace the defined mousemoved, update, mousepressed and other functions with new functions that call the old ones. But those new functions will add new behavior as well. By doing this, the UI system remains isolated within its own files, meaning you only have to call ui:initialize() once for the system to run permanently.\n\nThe following love functions have received an additional boolean argument at the end to indicate if the input will take place on top of a UI element:\n- love.mousepressed()\n- love.mousereleased()\n- love.wheelmoved()";
})

return {
	["Meta"] = meta;
	["Content"] = content;
}