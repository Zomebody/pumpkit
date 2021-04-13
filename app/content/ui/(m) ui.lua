

local ui = require("framework.ui")
local vector = require("framework.datatypes.vector")
local color = require("framework.datatypes.color")


local meta = {
	["Name"] = "(m) ui";
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
		Container:addChild(Example)

		local Tree = ui.newFrame(150, 200, color(1, 1, 1))
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
	["Description"] = "A boolean indicating whether or not the visual layout of the UI hierarchy has changed during this frame. This boolean is set to true when the ContentOffset, Size, Position, PaddingX, PaddingY or Hidden property changes on any object, or when an object is reparented. This boolean is used internally to check if MouseFocus should be recalculated at the end of the ui update cycle.";
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
	["ValueType"] = "number";
	["Name"] = "NumMouseFocusChanged";
	["Description"] = "An integer which is increased by one anytime the MouseFocus changes during a frame. This property is used internally to check if a full mouse press is valid, by comparing the number at the start and end of a press. TODO: This property should be moved into a local variable so it cannot be read either.";
	["ReadOnly"] = true;
	["CodeMarkup"] = nil;
	["Demo"] = nil;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "Object";
	["Name"] = "MouseFocus";
	["Description"] = "Either nil or a reference to a UI object that the mouse is currently targeting. An element needs to not be Hidden to appear as the MouseFocus. This property is used internally to trigger events on UI objects and to color elements.";
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
	["Name"] = "Size";
	["Description"] = "A vector describing the size of the viewport in which UI can be rendered. This property is used internally to update the AbsolutePosition of UI elements.";
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
	["Description"] = "This method will return for the given x and y coordinate which element is being drawn at that location on the screen. This method is also used internally to set the MouseFocus property.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "initialize";
	["Arguments"] = {};
	["Description"] = "This method can only be called once. It will initialize the UI module by hooking into other Love2D functions and adding additional behavior there to make the system run. This method should be called right when the program first loads. After that, the system will be initialized and run forever.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "render";
	["Arguments"] = {};
	["Description"] = "This method will render all UI on the screen by recursively called :draw() on all of the UI root's children. TODO: Right now you have to call this method every frame, but you should add a method to toggle a property to render the UI which will then be used to automatically determine every frame if the UI should be drawn.";
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