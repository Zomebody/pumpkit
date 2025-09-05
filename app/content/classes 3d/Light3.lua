
local meta = {
	["Name"] = "Light3";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The Light3 instance";
	["Description"] = "A Light3 is a point light that can be added to a Scene3 to light up specific areas. Light3 objects do not cast any shadows and will light up geometry through walls.\n\nNote: when changing a light property, it won't update on screen unless Scene3.LightsDirty is set to true or the light is re-attached.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Properties";
	["Description"] = "";
})


table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "color";
	["Name"] = "Color";
	["Description"] = "The light's color that it will (additively) cast onto nearby geometry.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "Id";
	["Description"] = "The identifier of the light. Used when light:detach() is called to quickly look up the light in the scene's list of lights.";
	["ReadOnly"] = true;
})


table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "vector3";
	["Name"] = "Position";
	["Description"] = "The light's position.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "Range";
	["Description"] = "How far the light reaches, i.e. its radius.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "Scene3";
	["Name"] = "Scene";
	["Description"] = "The scene that the light is attached to.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "Strength";
	["Description"] = "How intense the light is.";
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