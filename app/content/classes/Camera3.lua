
local meta = {
	["Name"] = "Camera3";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The Camera3 instance";
	["Description"] = "A Camera3 is an object which contains properties and methods related to transforming 3D spaces. They are used in scene3s to properly draw the scene from the right position and angle. So far only perspective cameras are supported.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Properties";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "FieldOfView";
	["Description"] = "The camera3's (vertical) field of view in radians.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "matrix4";
	["Name"] = "Matrix";
	["Description"] = "A matrix4 describing the position and rotation of the camera3. This gets updated automatically whenever the camera is rotated or moved by any of the methods.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "Offset";
	["Description"] = "An additional offset backwards in raw units in the camera's object space. This can be useful when programming a pivot camera as the camera's Position property will remain the same as the camera rotates, while the martix will be updated to account for the offset, as the offset is applied before rotating and translation is applied.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "vector3";
	["Name"] = "Position";
	["Description"] = "The position of the camera in the scene3.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "vector3";
	["Name"] = "Rotation";
	["Description"] = "The rotation of the camera in the scene3 in euler angles XYZ.";
	["ReadOnly"] = true;
})



table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "scene3";
	["Name"] = "Scene3";
	["Description"] = "The scene3 instance that the camera is tied to.";
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
	["Arguments"] = {"vec3"};
	["Description"] = "Translate the camera3 in world-space coordinates.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "moveLocal";
	["Arguments"] = {"vec3"};
	["Description"] = "Translate the camera3 in local-space coordinates, so moving the camera (-1,0,0) will always move the camera 'to the left' relative to its own perspective.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "on";
	["Arguments"] = {"eventName", "function"};
	["Description"] = "Registers a function to be called when the given event triggered. When this method is called multiple times, each function will be called in the same order as they were registered.\n\nReturns a Connection object.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "pitch";
	["Arguments"] = {"radians"};
	["Description"] = "Applies a pitch (rotation along the x-axis) to the camera's Rotation property.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "detach";
	["Arguments"] = {};
	["Description"] = "Unlinks the camera from the scene3 it is attached to. If the camera is attached to another scene3, this method is automatically called.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "roll";
	["Arguments"] = {"radians"};
	["Description"] = "Applies a roll (rotation along the z-axis) to the camera's Rotation property.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "screenToRay";
	["Arguments"] = {"xFactor", "yFactor", "aspectRatio"};
	["Description"] = "Converts a screen coordinate (where xFactor and yFactor are numbers between 0 and 1 starting at the top-left) to a line3 of length 1 at the camera's position pointed in the direction of the screen position.\n\n'aspectRatio' is an optional parameter. If none is supplied, the graphics' width and height are used to calculate an aspect ratio.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "set";
	["Arguments"] = {"position", "rotation", "offset"};
	["Description"] = "Sets the camera3's position, rotation and offset all at once, where the former two are vector3s and the latter is a number. A position must always be supplied, but rotation and offset could remain nil.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "setFOV";
	["Arguments"] = {"fov"};
	["Description"] = "Sets the field of view of the camera in radians.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "yaw";
	["Arguments"] = {"radians"};
	["Description"] = "Applies a yaw (rotation along the y-axis) to the camera's Rotation property.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "offset";
	["Arguments"] = {"number"};
	["Description"] = "Adds an additional offset to the camera.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "updateCameraMatrices";
	["Arguments"] = {};
	["Description"] = "FOR INTERNAL USE ONLY. Updates the camera3's Matrix property and sends it over to the shader(s) of the scene3 the camera is attached to.";
})


table.insert(content, {
	["Type"] = "Method";
	["Name"] = "__tostring";
	["Arguments"] = {};
	["Description"] = "Returns a string representation of the camera3 object.";
})


table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Events";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Event";
	["Name"] = "Attached";
	["Arguments"] = {"scene3"};
	["Description"] = "Called whenever the camera3 has been attached to a scene3.";
})

table.insert(content, {
	["Type"] = "Event";
	["Name"] = "Detached";
	["Arguments"] = {"scene3"};
	["Description"] = "Called whenever the camera3 has been detached from a scene3.";
})


return {
	["Meta"] = meta;
	["Content"] = content;
}