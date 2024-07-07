
local meta = {
	["Name"] = "scene";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The scene Module";
	["Description"] = "A module used to create Scene instances. These can be attached to world to render game maps. Scenes normally have a background image that is drawn and entities drawn on top of the background image.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Constructors";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "newScene";
	["Arguments"] = {"sceneCamera", "imageBackground", "imageForeground"};
	["Description"] = "Creates a new Scene instance. The given image will be drawn as a background starting at the (0,0) coordinate of the scene";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "newTiledScene";
	["Arguments"] = {"sceneCamera", "atlasImage", "grid", "tileSize"};
	["Description"] = "Creates a new TiledScene instance. A TiledScene is a scene whose background is built out of square tiles of equal size. These are drawn together in one draw call for great performance.\n\n- atlasImage: An atlas image containing the tile-sheet.\n- grid: A 2D array in which every index grid[x][y] is a vector representing the tile in the tile-sheet to draw at that location in the grid. (1,1) is the top left tile in the tile-sheet.\n- tileSize; an integer indicating the width and height of tiles.\n- sceneCamera: a Camera instance (or nil) that is used to view the scene.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "isScene";
	["Arguments"] = {"Object"};
	["Description"] = "Checks if the given object is a Scene instance. Returns true if so.";
})

return {
	["Meta"] = meta;
	["Content"] = content;
}