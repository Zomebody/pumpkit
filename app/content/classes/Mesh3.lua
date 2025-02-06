
local meta = {
	["Name"] = "Mesh3";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The Mesh3 instance";
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
	["ValueType"] = "color";
	["Name"] = "Color";
	["Description"] = "The mesh's color. Any textures or lighting applied to the mesh's surface is multiplied by the color So a red mesh with a blue texture will appear black.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "vector3";
	["Name"] = "Id";
	["Description"] = "The identifier of the mesh. Used when mesh:detach() is called to quickly look up the mesh in the scene's list of basic meshes.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "boolean";
	["Name"] = "IsTriplanar";
	["Description"] = "When set to false, the mesh's UV coordinates are used to project the image onto the mesh. When set to true, the texture is projected onto the mesh along the X/Y/Z-axis depending on the direction each face is pointing to.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "mesh";
	["Name"] = "Mesh";
	["Description"] = "The reference to the Love2d mesh object. It is okay to reuse the same Love2d mesh when creating multiple different mesh3 instances as the mesh is only referenced.";
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
	["ValueType"] = "number";
	["Name"] = "TextureScale";
	["Description"] = "When 'IsTriplanar' is set to true, this property determines how large the image is when projected onto the mesh.";
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
	["Type"] = "Property";
	["ValueType"] = "vector2";
	["Name"] = "UVVelocity";
	["Description"] = "The speed at which the mesh's texture 'scrolls'. When using this property, make sure the mesh's image has its wrapping mode set to 'repeat'. This property can be used to make textures move along the surface of the mesh such as when creating waterfalls, lava, and so on.\n\nEach unit of speed corresponds to looping around the width/height of the texture once per second.";
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
	["Description"] = "Links the mesh3 to a scene3. If the mesh is already attached to another scene, it is detached before this is executed.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "clone";
	["Arguments"] = {};
	["Description"] = "Creates a new mesh3 instance with the same properties, except it is not attached to a scene3.";
})


table.insert(content, {
	["Type"] = "Method";
	["Name"] = "detach";
	["Arguments"] = {};
	["Description"] = "Detaches the mesh from the scene it's linked to. This does not destroy the mesh3, meaning it can be re-attached later.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "move";
	["Arguments"] = {"offset"};
	["Description"] = "Translates the position of the mesh3 in world space.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "moveLocal";
	["Arguments"] = {"offset"};
	["Description"] = "Translates the position of the mesh3 in object space.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "rotate";
	["Arguments"] = {"rotation"};
	["Description"] = "Rotates the mesh3 in world space.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "rotateLocal";
	["Arguments"] = {"rotation"};
	["Description"] = "Rotates the mesh3 in object space.";
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