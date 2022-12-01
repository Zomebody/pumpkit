
local meta = {
	["Name"] = "Scene";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The Scene instance";
	["Description"] = "A Scene acts as an isolated environment in which game logic can be run. Namely, a scene consists out of a background and entities that can be interacted with.";
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
	["ValueType"] = "Image";
	["Name"] = "SceneImage";
	["Description"] = "The background image of the scene. This image is drawn at the world origin (0,0) and extends in the direction positive X and positive Y. In the case of a TiledScene, this image is the texture atlas instead.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "Camera";
	["Name"] = "Camera";
	["Description"] = "The Camera instance used to draw the scene with. When you move the camera around, the location of the scene's background and entities will change accordingly.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "table";
	["Name"] = "Entities";
	["Description"] = "A list of Entity instances that are part of the scene. These will be drawn on top of the scene. Entities are sorted by their Position's Y-coordinate, so entities with a larger y are drawn on top.";
	["ReadOnly"] = true;
})


table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "addEntity";
	["Arguments"] = {"Entity"};
	["Description"] = "Adds the given entity to the list of entities in the scene. All entities added to a scene are drawn by default.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "at";
	["Arguments"] = {"x", "y"};
	["Description"] = "Returns the entity located at the given screen coordinates. The Shape and ShapeSize properties of an entity determines what space the entity covers for this method.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "draw";
	["Arguments"] = {};
	["Description"] = "This will draw the scene to the current render target. First the background is drawn. Then, entities are drawn on top.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "drawEntities";
	["Arguments"] = {};
	["Description"] = "FOR INTERNAL USE ONLY. This will draw the entities of a scene onto the current render target. This method is used by the draw() method to draw their entities. It should never have to be used on its own.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "getCamera";
	["Arguments"] = {};
	["Description"] = "Returns the current Camera used in the scene.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "on";
	["Arguments"] = {"eventName", "function"};
	["Description"] = "Registers a function to be called when the given event triggered. When this method is called multiple times, each function will be called in the same order as they were registered.\n\nReturns a Connection object.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "setCamera";
	["Arguments"] = {"Camera"};
	["Description"] = "Sets the scene's camera to be used to the given Camera instance.";
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
	["Name"] = "Loading";
	["Arguments"] = {};
	["Description"] = "Called when the scene is set as the world's current scene. Use this event to correctly initialize the scene, such as correctly setting the location of entities.";
})

table.insert(content, {
	["Type"] = "Event";
	["Name"] = "Unloading";
	["Arguments"] = {};
	["Description"] = "Called when the scene is removed as the world's current scene. You could use this event to clean up any objects that are not used when the scene is inactive.";
})


return {
	["Meta"] = meta;
	["Content"] = content;
}