
local meta = {
	["Name"] = "Blob3";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The Blob3 instance";
	["Description"] = "A Blob3 is a blob shadow that can be added to a Scene3 to darken specific areas. They are essentially the opposite of a Light3. The color depends on the scene's ambient lighting.\n\nNote: when changing a blob's property, it won't update on screen unless Scene3.BlobsDirty is set to true or the blob is re-attached.";
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
	["Description"] = "The identifier of the blob. Used when blob:detach() is called to quickly look up the blob in the scene's list of blobs.";
	["ReadOnly"] = true;
})


table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "vector3";
	["Name"] = "Position";
	["Description"] = "The blob's position.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "Range";
	["Description"] = "How far the blob reaches, i.e. its radius.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "Scene3";
	["Name"] = "Scene";
	["Description"] = "The scene that the blob is attached to.";
	["ReadOnly"] = false;
})


table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})


table.insert(content, {
	["Type"] = "Method";
	["Name"] = "clone";
	["Arguments"] = {};
	["Description"] = "Creates a new light3 instance with the same properties, except it is not attached to a scene3.";
})


table.insert(content, {
	["Type"] = "Method";
	["Name"] = "detach";
	["Arguments"] = {};
	["Description"] = "Detaches the light from the scene it's linked to. This does not destroy the light3, meaning it can be re-attached later.";
})


table.insert(content, {
	["Type"] = "Method";
	["Name"] = "move";
	["Arguments"] = {"offset"};
	["Description"] = "Translates the position of the light3 in world space.";
})




table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Events";
	["Description"] = "";
})



return {
	["Meta"] = meta;
	["Content"] = content;
}