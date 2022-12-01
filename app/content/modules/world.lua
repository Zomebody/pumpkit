
local meta = {
	["Name"] = "world";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The world Module";
	["Description"] = "A module used to manage scenes. The world can contain a current scene with entities for gameplay purposes. A world is basically an overarching game state manager.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "getCamera";
	["Arguments"] = {};
	["Description"] = "Returns the camera of the current scene. If no scene is set, this returns nil.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "getScene";
	["Arguments"] = {};
	["Description"] = "Returns the current scene that has been set.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "initialize";
	["Arguments"] = {};
	["Description"] = "FOR INTERNAL USE ONLY. Initializes the world module. This method is automatically called when loading the framework.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "render";
	["Arguments"] = {};
	["Description"] = "Draws the current scene to the screen.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "setScene";
	["Arguments"] = {"sceneObject"};
	["Description"] = "Sets the current scene to the given scene object. If a scene has been set, its 'Unloading' event will be called. A new scene is then added whose 'Loading' event will be called. Alternatively, nil can be passed to only remove the current scene.";
})

return {
	["Meta"] = meta;
	["Content"] = content;
}