
local meta = {
	["Name"] = "Spritemesh3";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The Spritemesh3 instance";
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
	["Name"] = "Brightness";
	["Description"] = "A value between 0 and 1 which defaults to 0. The higher the brightness of the mesh, the less it is affected by the scene's ambient, lights and diffusion. Ambient occlusion still applies.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "Bloom";
	["Description"] = "How much bloom the mesh emits. If set to 0, the bloom is disabled. If set to 1, it emits maximum bloom. Bloom can be set to higher than 1 to make the bloom more white, but generally this value should be set in the range 0-1.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "color";
	["Name"] = "Color";
	["Description"] = "The mesh's base color while exposed to the sun. Any textures or lighting applied to the mesh's surface is multiplied by the color so a red mesh with a blue texture will appear black.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "color";
	["Name"] = "ColorShadow";
	["Description"] = "The mesh's base color when in a shadow.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "Id";
	["Description"] = "The identifier of the mesh. Used when mesh:detach() is called to quickly look up the mesh in the scene's list of basic meshes.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "mesh";
	["Name"] = "Mesh";
	["Description"] = "The reference to the Love2d mesh object. It is okay to reuse the same Love2d mesh when creating multiple different spritemesh3 instances as the mesh is only referenced.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "vector3";
	["Name"] = "Position";
	["Description"] = "The mesh's position.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "vector3";
	["Name"] = "Rotation";
	["Description"] = "The mesh's rotation in euler angles XYZ.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "vector3";
	["Name"] = "Scale";
	["Description"] = "The mesh's scale.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "Scene3";
	["Name"] = "Scene";
	["Description"] = "The scene that the sprite mesh is attached to.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "vector2";
	["Name"] = "SheetSize";
	["Description"] = "The size of the sprite sheet in *images* along the x-axis and y-axis.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "vector2";
	["Name"] = "SpritePosition";
	["Description"] = "The index of the current sprite to-be-drawn in reading order. Note that the top-left sprite starts at position (1,1)!";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "texture";
	["Name"] = "Texture";
	["Description"] = "The mesh's texture. If no texture is supplied a default 1x1 white pixel will be used as a substitute in the shader. Textures with non-opaque pixels are allowed and will not be clipped unless they are almost fully transparent, but transparency may be prone to artefacts.\n\nWhen using semi-transparent pixels consider setting the mesh's Transparency to 0.999 or lower to enable proper sorting at the cost of some performance.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "Transparency";
	["Description"] = "A value between 0 and 1 which is defaulted to 0. Currently, draw calls aren't sorted to transparency does not apply properly.";
	["ReadOnly"] = false;
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
	["Description"] = "Links the spritemesh3 to a scene3. If the mesh is already attached to another scene, it is detached before this is executed.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "clone";
	["Arguments"] = {};
	["Description"] = "Creates a new spritemesh3 instance with the same properties, except it is not attached to a scene3.";
})


table.insert(content, {
	["Type"] = "Method";
	["Name"] = "detach";
	["Arguments"] = {};
	["Description"] = "Detaches the spritemesh3 from the scene it's linked to. This does not destroy the spritemesh3, meaning it can be re-attached later.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "move";
	["Arguments"] = {"offset"};
	["Description"] = "Translates the position of the spritemesh3 in world space.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "moveLocal";
	["Arguments"] = {"offset"};
	["Description"] = "Translates the position of the spritemesh3 in object space.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "rotate";
	["Arguments"] = {"rotation"};
	["Description"] = "Rotates the spritemesh3 in world space.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "rotateLocal";
	["Arguments"] = {"rotation"};
	["Description"] = "Rotates the spritemesh3 in object space.";
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