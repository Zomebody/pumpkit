
local meta = {
	["Name"] = "Entity";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The Entity instance";
	["Description"] = "An Entity is an object that can be added to a scene for gameplay purposes. There are two types of Entities, 'Creature' and 'Prop' entities. Creatures can have multiple states with their own animations, whereas props are static images.";
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
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "vector";
	["Name"] = "ImageScale";
	["Description"] = "A vector representing a multiplier on the X-axis and Y-axis for when the image is drawn. This can be used to, for example, animate an entity growing larger or smaller.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "vector";
	["Name"] = "Pivot";
	["Description"] = "A vector with values between 0 and 1. This is used to determine how the image is drawn in relation to its position. A pivot of (0,0) draws the top-left corner on the Entity's Position coordinate. A pivot of (1,1) is the bottom-right corner.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "vector";
	["Name"] = "Position";
	["Description"] = "A vector representing the position of the entity in the current scene.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "Scene";
	["Name"] = "Scene";
	["Description"] = "A reference to the scene in which this entity is currently active. If nil, the entity is currently not part of any scene.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "vector";
	["Name"] = "Size";
	["Description"] = "The size of the Entity's visuals. In the case of a Creature Entity, this property reflects the size of the animation currently drawn on screen. In case of a Prop, this is the image's size.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "string";
	["Name"] = "Shape";
	["Description"] = "Either \"ellipse\" or \"rectangle\". This property determines the entity's hitbox and is used in different polling methods such as Scene:at().";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "vector";
	["Name"] = "ShapeSize";
	["Description"] = "The size of the entity's shape property.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "integer";
	["Name"] = "ZIndex";
	["Description"] = "A number from 1 to 100. When drawing entities in a scene, the entities with a higher ZIndex are drawn on top of entities with a lower ZIndex value. If the two values are tied however, the Position.y value determines the priority, where entities with a higher Position.y value are drawn on top of entities with a lower one.";
	["ReadOnly"] = false;
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "moveTo";
	["Arguments"] = {"x", "y"};
	["Description"] = "Move the entity to the given x and y coordinates. Alternatively, you may also pass a vector instead.\n\nWhen moving the object, its position in the current scene's Entities array may change. Even with many entities in the scene, changing the position should be incredibly fast.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "on";
	["Arguments"] = {"eventName", "function"};
	["Description"] = "Registers a function to be called when the given event triggered. When this method is called multiple times, each function will be called in the same order as they were registered.\n\nReturns a Connection object.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "setImageScale";
	["Arguments"] = {"x", "y"};
	["Description"] = "Set the ImageScale property of the entity. You may either pass and x and y coordinate, a single x coordinate which will also be used as the y coordinate, or a vector with the x and y coordinates.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "setShape";
	["Arguments"] = {"shape", "size"};
	["Description"] = "Set the Shape property of the entity to either \"ellipse\" or \"rectangle\". Optionally, a size vector can be passed to also set the ShapeSize property.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "__tostring";
	["Arguments"] = {};
	["Description"] = "Returns a string representation of the Entity object.";
})


table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Events";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Event";
	["Name"] = "Added";
	["Arguments"] = {};
	["Description"] = "Called when the entity is added to a scene. You can check the new scene by accessing the Entity's Scene property.";
})
--[[
table.insert(content, {
	["Type"] = "Event";
	["Name"] = "Removed";
	["Arguments"] = {};
	["Description"] = "Called when the scene is removed as the world's current scene. You could use this event to clean up any objects that are not used when the scene is inactive.";
})
]]

return {
	["Meta"] = meta;
	["Content"] = content;
}