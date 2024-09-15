
local meta = {
	["Name"] = "Camera";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The Camera instance";
	["Description"] = "A Camera is an object which contains properties and methods related to transforming 2D spaces. They are used in scenes to properly draw the scene at a given location. A camera will always center its Position to the middle of the screen.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Properties";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "Id";
	["Description"] = "The unique identifier of the given Scene instance.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "vector2";
	["Name"] = "Position";
	["Description"] = "The position of the camera in the scene. Note that the camera will always center its Position coordinate to the middle of the screen.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "Transform";
	["Name"] = "Transform";
	["Description"] = "The current transform of the camera.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "Zoom";
	["Description"] = "The current zoom of the camera. Higher values indicate that the camera is zoomed in. Lower values indicate that the camera is zoomed out. It is recommended to use powers of 2 when working with pixel-art for better pixel alignments.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "getTransform";
	["Arguments"] = {};
	["Description"] = "Returns the camera's Transform object. This transform is used when drawing objects in a scene to the screen.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "move";
	["Arguments"] = {"x", "y"};
	["Description"] = "Translate the camera in world-space coordinates. You may also pass a vector2 instead of two separate coordinates.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "moveTo";
	["Arguments"] = {"x", "y"};
	["Description"] = "Move the camera to the given world-space coordinates. You may also pass a vector2 instead of two separate coordinates.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "on";
	["Arguments"] = {"eventName", "function"};
	["Description"] = "Registers a function to be called when the given event triggered. When this method is called multiple times, each function will be called in the same order as they were registered.\n\nReturns a Connection object.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "remove";
	["Arguments"] = {};
	["Description"] = "Removes the camera. Currently this method doesn't do much at all.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "screenPointToWorldSpace";
	["Arguments"] = {"x", "y"};
	["Description"] = "Converts the given coordinate from screen space to the world's space. Instead of passing two coordinates, you may also pass a vector2.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "setZoom";
	["Arguments"] = {"number"};
	["Description"] = "Sets the camera's zoom to the given value.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "updateTransform";
	["Arguments"] = {};
	["Description"] = "FOR INTERNAL USE ONLY. Updates the camera's transform property to reflect its properties.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "worldPointToScreenSpace";
	["Arguments"] = {"x", "y"};
	["Description"] = "Converts the given coordinate from world space to the screen's space. Instead of passing two coordinates, you may also pass a vector2.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "__tostring";
	["Arguments"] = {};
	["Description"] = "Returns a string representation of the scene object.";
})


table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Events";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Event";
	["Name"] = "Moved";
	["Arguments"] = {"x", "y"};
	["Description"] = "Called whenever the camera's Position changes.";
})


return {
	["Meta"] = meta;
	["Content"] = content;
}