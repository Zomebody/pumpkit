
local meta = {
	["Name"] = "TiledScene";
	["SuperClass"] = "Scene"
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The TiledScene instance";
	["Description"] = "A TiledScene acts as an isolated environment in which game logic can be run. Namely, a scene consists out of a background and entities that can be interacted with. A TiledScene extends the Scene class as it contains additional logic to construct its tiled background.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Properties";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "table";
	["Name"] = "Quads";
	["Description"] = "A 2D array containing Quad instances. Each index in the 2D array represents a tile in the texture atlas and the quad is positioned onto the corresponding sub-image in the texture atlas.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "SpriteBatch";
	["Name"] = "SpriteBatch";
	["Description"] = "A SpriteBatch object containing all the quads that will be used to draw the background.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "draw";
	["Arguments"] = {};
	["Description"] = "This will draw the scene to the current render target. First the background is drawn. Then, entities are drawn on top. a TiledScene has different logic for drawing its background. It uses a SpriteBatch instead to draw many different quads to the screen at once in one draw call.";
})


return {
	["Meta"] = meta;
	["Content"] = content;
}