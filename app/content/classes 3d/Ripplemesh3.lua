
local meta = {
	["Name"] = "Ripplemesh3";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The Ripplemesh3 instance";
	["Description"] = "Similar to mesh3, but this object can be used to mimic liquids like water, magma and poison using additional texture features..";
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
	["Description"] = "The mesh's color. Any textures or lighting applied to the mesh's surface is multiplied by the color So a red mesh with a blue texture will appear black.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "color";
	["Name"] = "ColorShadow";
	["Description"] = "The mesh's base color when in a shadow. The instanced mesh types generally have this property baked into the instance mesh thus they aren't shown in their documentations.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "texture";
	["Name"] = "DataMap";
	["Description"] = "Contains information about foam and distortion.\n- r = angle of the distortion at that pixel.\n- g = how far the distortion reaches as a fraction of the image size.\n- b = noise values (that should be evenly & gradually distributed between 0 and 1) that determine the shape of the foam.\n- a = foaminess, determines how often foam should appear at that spot where 0 is no foam, 1 is always foam, 0.5 is foam half the time.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "color";
	["Name"] = "FoamColor";
	["Description"] = "The color of the foam.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "color";
	["Name"] = "FoamColorShadow";
	["Description"] = "The mesh's foam's base color when in a shadow.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "FoamInShadow";
	["Description"] = "If 0, no foam is shown while in the shadow. If 1, the foam is fully shown while in a shadow.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "vector4";
	["Name"] = "FoamVelocity";
	["Description"] = "The speed at which the foam moves. The x&y determine the first velocity and the z&w determine the second velocity.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "color";
	["Name"] = "FresnelColor";
	["Description"] = "The mesh's fresnel color if fresnel is enabled. Fresnel applies a glow around the edges of the mesh in this color.";
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
	["Description"] = "The identifier of the mesh. Used when mesh:detach() is called to quickly look up the mesh in the scene's list of basic meshes.";
	["ReadOnly"] = true;
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
	["ValueType"] = "Scene3";
	["Name"] = "Scene";
	["Description"] = "The scene that the ripplemesh3 is attached to.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "texture";
	["Name"] = "Texture";
	["Description"] = "The mesh's color map texture. If no texture is supplied a default 1x1 white pixel will be used as a substitute in the shader. All pixels must be opaque.";
	["ReadOnly"] = false;
})


table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "vector4";
	["Name"] = "WaterVelocity";
	["Description"] = "The speed at which the water texture and the water distortion move. The x&y properties determine the UV speed of the water texture. Yhe z&w determine the speed of the texture distortion.";
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