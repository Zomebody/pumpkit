
local meta = {
	["Name"] = "Particles3";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The Particles3 instance";
	["Description"] = "A particle emission system/instance that will emit 2d images in 3d space using instancing.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Properties";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "boolean";
	["Name"] = "Blends";
	["Description"] = "If false, particles are drawn directly to the screen with depth testing in some undetermined order and thus semi-transparent images will have sorting issues. If this is instead set to true, particles are drawn to an intermediate canvas first where overlapping particles have their colors mixed. Mixing does not take ordering into account so results may look unrealistic.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "Brightness";
	["Description"] = "The brightness of the particles where 0 means fully affected by lighting and 1 means not at all affected by lighting.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "texture";
	["Name"] = "DataTexture";
	["Description"] = "A 64x2 image that stores the particle image's gradient and particle size curve.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "Drag";
	["Description"] = "Determines the fraction of velocity left after each second compared to the previous second using the formula 0.5^x where 'x' is the drag.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "vector3";
	["Name"] = "Direction";
	["Description"] = "The direction in which the particles will be emitted from the source. This should be a unit vector but the constructor does not normalize any input.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "DirectionDeviation";
	["Description"] = "An angle in radians determining the maximum cone angle at which emitted particles may randomly deviate.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "boolean";
	["Name"] = "FacesCamera";
	["Description"] = "Particles are oriented in 4 different ways depending on the value of FacesCamera and FacesVelocity:\n- If both are true: The particle acts as a billboard but the image is rotated in screen space towards its velocity.\n- If both are false: The particle faces world-up.\n- If FacesCamera is true and FacesVelocity is false: The particles act like billboards.\n If FacesCamera is false and FacesVelocity is true: The particles are facing the direction they are moving in.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "boolean";
	["Name"] = "FacesVelocity";
	["Description"] = "See 'FacesCamera'.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "FlipbookFrames";
	["Description"] = "Determines the number of flipbook frames to play over the particles' lifetimes if FlipbookSize is higher than 1. Each frame is displayed for the same duration. If this number is smaller than the squares in the flipbook then the remaining sprites are ignored. If this number is larger than the number of sprites in the flipbook it will wrap back around.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "FlipbookSize";
	["Description"] = "Defaults to 1. Determines how many squares the texture is divided into on both the x and y axis. A FlipbookSize of 3 means the image is split into 9 equally sized sprites.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "gradient";
	["Name"] = "Gradient";
	["Description"] = "How the particles' colors change during their lifetime.\n\nA 64 pixel wide image is initialized upon creation of the instance with the gradient's colors that is used in the shader to set the colors. This means that changing this property later on won't do anything as of now.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "vector3";
	["Name"] = "Gravity";
	["Description"] = "Defines the direction the particles accelerate towards.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "Id";
	["Description"] = "The id of the object.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "range";
	["Name"] = "Lifetime";
	["Description"] = "The minimum and maximum lifetime in seconds that any particle may be emitted at.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "array";
	["Name"] = "MatricesData";
	["Description"] = "An internal array that stores each particles' emission location and emission velocity which are referenced by certain methods.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "MaxParticles";
	["Description"] = "The number of particles in the emitter's pool. When more particles are emitted than are available in the pool, the oldest particles get cut short and are emitted again.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "range";
	["Name"] = "Rotation";
	["Description"] = "Determines the rotation of the particle's image when it is emitted. A random value between the minimum and maximum is chosen.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "range";
	["Name"] = "RotationSpeed";
	["Description"] = "The minimum and maximum speed in radians per second at which the particles' image rotates around itself.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "scene3";
	["Name"] = "Scene";
	["Description"] = "The scene this particles3 instance is attached to.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "numbercurve";
	["Name"] = "Size";
	["Description"] = "The size of the particles in world units over the course of its lifetime. The size curve is encoded into an image during initialization thus changing this property during run-time won't work.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "numbercurve";
	["Name"] = "SizeDeviation";
	["Description"] = "A curve determining the maximum deviation in the particles' sizes at any given moment in their lifetime. The size curve is encoded into an image during initialization thus changing this property during run-time won't work.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "vector3/line3";
	["Name"] = "Source";
	["Description"] = "The position from which particles are emitted. This property can be changed while particles are active, but only newly emitted particles will appear in the new location. If you want to move all existing particles you should use one of the instance's methods for it instead.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "SpawnIndex";
	["Description"] = "An internal value that tells the emitter which particle in the pool should be emitted next.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "SpawnRadius";
	["Description"] = "A radius determining the area around the source from which particles may spawn. The area is a circular plane pointed in the particle's Direction vector.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "range";
	["Name"] = "Speed";
	["Description"] = "The minimum and maximum speed at which the particle can be emitted. A random value between these two is chosen for each particle.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "ZOffset";
	["Description"] = "How many units forward the particles are shifted towards the camera. You can use this in certain cases to reduce clipping when particles are near walls.";
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
	["Description"] = "Attaches the particles3 to the given scene3. If it's already attached to one it will first be detached.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "detach";
	["Arguments"] = {};
	["Description"] = "Detaches the particles3 from the scene3. Returns true or false depending on if it was detached or not.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "draw";
	["Arguments"] = {};
	["Description"] = "Internal method that is called by a scene3 to render particles to their canvas(es).";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "emit";
	["Arguments"] = {"count"};
	["Description"] = "Emits the given number of particles at once from the source. If there aren't enough inactive particles in the pool to emit, the oldest active particles will be used instead.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "move";
	["Arguments"] = {"vec3"};
	["Description"] = "Moves the emitter and any currently emitted particles by some given offset in world units. Particles will keep their relative position.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "moveTo";
	["Arguments"] = {"vec3"};
	["Description"] = "Moves the emitter and any currently emitted particles to the target position. Particles will keep their relative position.\n\nThis method unfortunately only works when the Source is a vector3. It does not work if the source is a line3.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "redirect";
	["Arguments"] = {"direction"};
	["Description"] = "Sets the direction of the emitter to the given vector. Any particles that are currently emitted will move along with the rotation in a relative manner.";
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