
local meta = {
	["Name"] = "Trip3Group";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The Trip3Group instance";
	["Description"] = "A Trip3Group is an instanced version of Trip3. These objects are static and have fewer options but have the benefit of winning a lot of performance by being drawn in only 1 call. Using semi-transparent images with trip3group objects is discouraged due to mesh sorting limitations unless all pixels are fully opaque or fully transparent but may still have artefacts.";
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
	["ValueType"] = "number";
	["Name"] = "Bloom";
	["Description"] = "How much bloom the mesh group emits. If set to 0, the bloom is disabled. If set to 1, it emits maximum bloom. Bloom can be set to higher than 1 to make the bloom more white, but generally this value should be set in the range 0-1.";
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
	["ValueType"] = "color";
	["Name"] = "FresnelColor";
	["Description"] = "The group's fresnel color if fresnel is enabled. Fresnel applies a glow around the edges of any of the group's meshes in this color.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "FresnelPower";
	["Description"] = "The positive 'power' in the fresnel formula. Higher values give more gradual fresnel. Lower values - especially below 1 - give sporadic fresnel.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "FresnelStrength";
	["Description"] = "A value between 0 and 1. This defaults to 0 which disables the fresnel. As it increases to 1 the fresnel becomes more apparent until it's fully enabled at a value of 1.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "Id";
	["Description"] = "The identifier of the trip3group. Used when trip3group:detach() is called to quickly look up the group in the scene's list of group meshes.";
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
	["ValueType"] = "number";
	["Name"] = "TextureScale";
	["Description"] = "How large the texture is when it is projected onto the mesh. A larger scale corresponds to a higher pixel density, thus the individual tiling is smaller.";
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
	["Description"] = "Links the trip3group to a scene3. If the mesh is already attached to another scene, it is detached before this is executed.";
})


table.insert(content, {
	["Type"] = "Method";
	["Name"] = "detach";
	["Arguments"] = {};
	["Description"] = "Detaches the mesh from the scene it's linked to. This does not destroy the trip3group, meaning it can be re-attached later.";
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