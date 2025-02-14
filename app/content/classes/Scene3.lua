
local meta = {
	["Name"] = "Scene";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The Scene3 instance";
	["Description"] = "A Scene3 acts as an isolated 3d environment that can be rendered to the screen, with additional methods to help facilitate 3d gameplay.\n\nA Scene3 stores different canvases and shaders as internal properties that should not be touched and thus remain undocumented here.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Properties";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "boolean";
	["Name"] = "AOEnabled";
	["Description"] = "If screen-space ambient occlusion is enabled. If enabled, additional procedures are run to apply AO to the rendered scene.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "Image";
	["Name"] = "Background";
	["Description"] = "A background image drawn behind the scene when it is being rendered.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "table";
	["Name"] = "BasicMeshes";
	["Description"] = "An array containing mesh3 instances (work in progress). These each take up one draw call.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "Camera3";
	["Name"] = "Camera3";
	["Description"] = "The Camera instance whose view point is used to draw the 3d scene. When a camera is moved around, so are meshes. The scene3's background and foreground will remain static however.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "DiffuseStrength";
	["Description"] = "How intense the diffuse lighting is. Should be a value between 0 and 1.\n- When set to 0, a surface is lit purely based on the distance to the light source.\n- When set to 1, a surface's orientation w.r.t. the light source's position is strongly considered when lighting the surface.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "Image";
	["Name"] = "Foreground";
	["Description"] = "An overlaying image drawn on top of the scene after is has been rendered.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "Id";
	["Description"] = "The unique identifier of the given Scene3 instance.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "table";
	["Name"] = "InstancedMeshes";
	["Description"] = "An array containing instanced meshes. Instanced meshes take up fewer draw calls, but comes at the cost of having less flexibility. Each index has these properties:\n- Mesh: the Love2d mesh object.\n- Instances: the instance mesh.\n- IsTriplanar: boolean indicating if its texture is applied using triplanar projection.\n- TextureScale: if IsTriplanar is set to true, this indicates the scale at which the texture is applied.\n- Count: the number of meshes that were instanced.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "table";
	["Name"] = "Lights";
	["Description"] = "An array containing exactly 16 lights (might change in the future). Each light has the properties:\n- Position (vector3)\n- Color (color)\n- Range (number)\n- Strength (number)\nLights are disabled if their strength and/or range is set to 0.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "MSAA";
	["Description"] = "How much larger the scene is being rendered at so that it can be downscaled when drawn to the screen as a very simply - though expensive - form of anti-aliasing.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "table";
	["Name"] = "Particles";
	["Description"] = "An array containing particles3 instances. Particles are added to the scene3 through the addParticles() method.";
	["ReadOnly"] = true;
})



table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "addInstancedMesh";
	["Arguments"] = {"mesh", "positions", "rotations", "scales", "colors", "texScale"};
	["Description"] = "Adds a Love2d mesh to the scene that uses mesh instancing to draw multiple copies and different locations with different properties. Arguments 'positions', 'rotations', 'scales' and 'colors' are all arrays of equal length.\n- mesh: The Love2d mesh object using a specific format that is initialized by the loadMesh() method.\n-positions: array of vector3s.\nrotations: array of vector3s describing the rotation of the mesh in euler angles XYZ.\n- scales: array of vector3s.\n- colors: array of color datatypes.\n- texScale: a number representing the scale of the triplanar projection on the mesh's texture. If 'nil', the mesh texture is applied using UV-coordinates instead.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "addParticles";
	["Arguments"] = {"particles3"};
	["Description"] = "Adds a particles3 instance to the scene's list of particles that will be drawn. Each particles3 instance takes up one draw call.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "applyAmbientOcclusion";
	["Arguments"] = {};
	["Description"] = "FOR INTERNAL USE ONLY. This will apply ambient occlusion to the canvas that is currently being prepared for rendering.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "attachBasicMesh";
	["Arguments"] = {"mesh3"};
	["Description"] = "Adds a mesh3 instance to the scene's list of meshes that will be drawn. Each mesh takes up one draw call. A mesh cannot be added multiple times. If the mesh is already attached to a scene, it is first detached.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "detachBasicMesh";
	["Arguments"] = {"mesh3"};
	["Description"] = "Removes a basic mesh3 from the scene's list of meshes. This does not destroy the mesh, so they can be added back later.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "draw";
	["Arguments"] = {"canvas"};
	["Description"] = "This will draw the Scene3 to the supplied canvas, or simply the screen if none is supplied.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "getCamera";
	["Arguments"] = {};
	["Description"] = "Returns the current Camera3 used in the scene.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "on";
	["Arguments"] = {"eventName", "function"};
	["Description"] = "Registers a function to be called when the given event triggered. When this method is called multiple times, each function will be called in the same order as they were registered.\n\nReturns a Connection object.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "rescaleCanvas";
	["Arguments"] = {"width", "height", "msaa"};
	["Description"] = "Rescales any internal canvases to the given width and height. If no width and height is supplied, the current graphics size is used. 'msaa' is an upscaling factor. If none is supplied it defaults to 1. Higher values such as 2 or 4 mean the internal canvases will be increased in size which helps with anti-aliasing, but uses significantly more GPU power.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "setAmbient";
	["Arguments"] = {"color", "occlusionColor"};
	["Description"] = "Sets the scene's ambient and occlusion color. Ambient color is applied to the whole scene while the occlusion color is applied only in corners.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "setAO";
	["Arguments"] = {"strength", "scale"};
	["Description"] = "Sets the scene's ambient occlusion. 'strength' should be a value roughly between 0 and 1. A 'scale' of 1 means ambient occlusion spreads up to 1 unit out of corners.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "setCamera";
	["Arguments"] = {"index", "position", "color", "range", "strength"};
	["Description"] = "Updates the light at the given internal index to be positioned at the given vector3 position, with a given color, range and strength.\n\nCurrently, 16 indexes are supported meaning a scene can have up to 16 unique light sources. To disable a light you can set its range or strength to 0.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "setDiffuse";
	["Arguments"] = {"strength"};
	["Description"] = "Sets the scene's diffuse lighting strength.\n- When set to 0, a surface is lit purely based on the distance to the light source.\n- When set to 1, a surface's orientation w.r.t. the light source's position is strongly considered when lighting the surface.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "setLight";
	["Arguments"] = {"Camera3"};
	["Description"] = "Sets the scene's camera to be used to the given Camera3 instance.";
})


table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Events";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Event";
	["Name"] = "CameraAttached";
	["Arguments"] = {"camera3"};
	["Description"] = "Called when a camera3 has been attached to the scene3.";
})

table.insert(content, {
	["Type"] = "Event";
	["Name"] = "CameraDetached";
	["Arguments"] = {"camera3"};
	["Description"] = "Called when a camera3 has been detached from the scene3.";
})

table.insert(content, {
	["Type"] = "Event";
	["Name"] = "Loading";
	["Arguments"] = {};
	["Description"] = "Called when the scene3 is set as the world's current scene.";
})

table.insert(content, {
	["Type"] = "Event";
	["Name"] = "MeshAttached";
	["Arguments"] = {"mesh3"};
	["Description"] = "Called when a basic mesh is added to the scene, supplies the mesh3 that was attached.";
})

table.insert(content, {
	["Type"] = "Event";
	["Name"] = "MeshDetached";
	["Arguments"] = {"mesh3"};
	["Description"] = "Called when a basic mesh is detached from the scene, supplies the mesh3 that was detached.";
})

table.insert(content, {
	["Type"] = "Event";
	["Name"] = "ParticlesAttached";
	["Arguments"] = {"particles3"};
	["Description"] = "Called when a basic mesh is added to the scene, supplies the particles3 that was attached.";
})

table.insert(content, {
	["Type"] = "Event";
	["Name"] = "ParticlesDetached";
	["Arguments"] = {"particles3"};
	["Description"] = "Called when a basic mesh is detached from the scene, supplies the particles3 that was detached.";
})

table.insert(content, {
	["Type"] = "Event";
	["Name"] = "Unloading";
	["Arguments"] = {};
	["Description"] = "Called when the scene3 is removed as the world's current scene.";
})


return {
	["Meta"] = meta;
	["Content"] = content;
}