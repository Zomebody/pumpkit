
local meta = {
	["Name"] = "Foliage3";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The Foliage3 instance";
	["Description"] = "A Foliage3 is an instanced version of Mesh3. They work similar to a Mesh3Group but the difference is that they are specialized to work with harsh alpha clipping and are intented to use for leaves, grass and such. They also contain fewer properties for faster rendering.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Properties";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "Brightness";
	["Description"] = "A value between 0 and 1 which defaults to 0. The higher the brightness of the group, the less it is affected by the scene's ambient, lights and diffusion. Ambient occlusion still applies.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "boolean";
	["Name"] = "CastShadow";
	["Description"] = "When set to true, all meshes in the group will cast a shadow onto other geometry through the shadowmap.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "Count";
	["Description"] = "The number of meshes in this group.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "Id";
	["Description"] = "The identifier of the mesh3group. Used when mesh3group:detach() is called to quickly look up the group in the scene's list of group meshes.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "mesh";
	["Name"] = "Instances";
	["Description"] = "The Love2d instance mesh.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "mesh";
	["Name"] = "Mesh";
	["Description"] = "The reference to the Love2d mesh object. It is okay to reuse the same Love2d mesh when creating multiple different objects as the mesh is only referenced.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "image";
	["Name"] = "NormalMap";
	["Description"] = "Optionally a normal map for better diffuse lighting calculations. Green channel goes upwards, red channel goes to the right.\n\nIf no normal map is a set, a replacement flat normal map is used.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "texture";
	["Name"] = "Texture";
	["Description"] = "The texture applied to all meshes in the group. If no texture is supplied a default 1x1 white pixel will be used as a substitute in the shader. Textures with non-opaque pixels are allowed but this is heavily discouraged as semi-transparent pixels will not blend properly. Fully transparent pixels will be discarded however, though may still leave behind artefacts.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "Scene3";
	["Name"] = "Scene";
	["Description"] = "The scene that the mesh group is attached to.";
	["ReadOnly"] = true;
})


table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "attach";
	["Arguments"] = {"scene3"};
	["Description"] = "Links the foliage3 to a scene3. If the foliage3 is already attached to another scene, it is detached before this is executed.";
})


table.insert(content, {
	["Type"] = "Method";
	["Name"] = "detach";
	["Arguments"] = {};
	["Description"] = "Detaches the foliage3 from the scene it's linked to. This does not destroy the foliage3, meaning it can be re-attached later.";
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