
local meta = {
	["Name"] = "floodmap";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The floodmap datastructure";
	["Description"] = "A floodmap is a 2d tile-map suited for flood-filling purposes. It supports setting walls and weights, and filling the map at any point and returning any paths.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Constructors";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "new";
	["Arguments"] = {"width", "height"};
	["Description"] = "Creates a new floodmap of the given size.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "fromImage";
	["Arguments"] = {"pathToImage"};
	["Description"] = "Creates a new floodmap where the width equals the image's width and the height equals the image's height. A tile is walkable if a pixel's red component is > 0.5. Otherwise, it's a wall.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Properties";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "CostMap";
	["ValueType"] = "2d array";
	["ReadOnly"] = true;
	["Description"] = "A 2d array where each [x][y] index corresponds to a tile in the flood-map. This array stores per tile how much it costs to travel onto the tile from an adjacent tile. For walls the cost value is set to math.huge.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "Filled";
	["ValueType"] = "number";
	["ReadOnly"] = true;
	["Description"] = "Whether or not a path has been generated on the map. If :fill() is called, this is set to true. When :clearFill() is called, this is set to false.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "Map";
	["ValueType"] = "2d array";
	["ReadOnly"] = true;
	["Description"] = "A 2d array where each [x][y] index corresponds to a tile in the flood-map. This array stores per tile if they can be traversed or not, where 0 means walkable, and 1 means a wall.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "Size";
	["ValueType"] = "vector2";
	["ReadOnly"] = true;
	["Description"] = "The width and height of the map in tiles, meaning it's always integers.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "Start";
	["ValueType"] = "vector2";
	["ReadOnly"] = true;
	["Description"] = "When the map is flood-filled using :fill(), this property indicates the location at which the map was flood-filled. Otherwise it's 0,0.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "WeightMap";
	["ValueType"] = "2d array";
	["ReadOnly"] = true;
	["Description"] = "A 2d array where each [x][y] index corresponds to a tile in the flood-map. This array stores per tile the weighted distance to the start and is used to find a path to a given tile. The map is only initialized when the 'Filled' property is true.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "clearWeights";
	["Arguments"] = {};
	["Description"] = "Resets the weights in the WeightMap to math.huge, but keeps the costs set in the CostMap.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "clearCosts";
	["Arguments"] = {};
	["Description"] = "Resets the traversal costs in the CostMap for every tile to 1.";
})


table.insert(content, {
	["Type"] = "Method";
	["Name"] = "fill";
	["Arguments"] = {"fromVec2"};
	["Description"] = "Fills the map starting at the given vector2. Will error if the given tile is out of bounds.";
	["CodeMarkup"] = "<k>local</k> walls = {<f>vector2</f>(<n>3</n>, <n>1</n>), <f>vector2</f>(<n>3</n>, <n>2</n>),\n\t\t\t<f>vector2</f>(<n>2</n>, <n>3</n>), <f>vector2</f>(<n>5</n>, <n>2</n>),\n\t\t\t<f>vector2</f>(<n>5</n>, <n>4</n>), <f>vector2</f>(<n>5</n>, <n>5</n>)\n\t\t\t<f>vector2</f>(<n>6</n>, <n>3</n>), <f>vector2</f>(<n>7</n>, <n>3</n>)}\n<k>local</k> fm = <f>floodmap</f>(<n>9</n>, <n>5</n>)\n<k>for</k> i = <n>1</n>, <k>#</k>walls <k>do</k>\n\tfm:<f>setWall</f>(walls[i], <b>true</b>)\n<k>end</k>\nfm:<f>fill</f>(<f>vector2</f>(<n>2</n>, <n>2</n>))\n<k>local</k> path = fm:<f>getPath</f>(<f>vector2</f>(<n>6</n>, <n>5</n>))\n<c>-- visualize path here</c>";
	["Demo"] = function()
		local canvas = love.graphics.newCanvas(270, 150)
		canvas:renderTo(
			function()
				local walls = {vector2(3, 1), vector2(3, 2), vector2(2, 3), vector2(5, 2), vector2(5, 4), vector2(5, 5), vector2(6, 3), vector2(7, 3)}
				love.graphics.rectangle("fill", 0, 0, 270, 150)
				love.graphics.setColor(0, 0, 0)
				local fm = floodmap(vector2(9, 5))
				for i = 1, #walls do
					fm:setWall(walls[i], true)
					love.graphics.rectangle("fill", (walls[i].x - 1) * 30 + 2, (walls[i].y - 1) * 30 + 2, 26, 26)
				end
				love.graphics.setColor(0, 0, 1)
				fm:fill(vector2(2, 2))
				local path = fm:getPath(vector2(6, 5))
				for i = 1, #path do
					love.graphics.rectangle("fill", (path[i].x - 1) * 30 + 2, (path[i].y - 1) * 30 + 2, 26, 26)
				end
				love.graphics.setColor(1, 1, 1)
			end
		)
		return ui.newImageFrame(canvas)
	end
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "getCost";
	["Arguments"] = {"vec2"};
	["Description"] = "Returns the traversal cost of the given tile.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "getPath";
	["Arguments"] = {"toVec2"};
	["Description"] = "Returns an ordered array of vector2s describing which tiles are visited on the path from the start point to the given point (including start and end).";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "getReach";
	["Arguments"] = {"fromVec2", "distance"};
	["Description"] = "Returns an array of vector2s that are reachable from the given vector2 within a certain distance. Calling this will clear any weights set by :fill() and reset the Filled and Start properties.";
	["Demo"] = function()
		local canvas = love.graphics.newCanvas(270, 150)
		canvas:renderTo(
			function()
				local walls = {vector2(4, 1), vector2(4, 2), vector2(4, 3), vector2(7, 1), vector2(5, 4)}
				love.graphics.rectangle("fill", 0, 0, 270, 150)
				love.graphics.setColor(0, 0, 0)
				local fm = floodmap(vector2(9, 5))
				fm:setWall(walls, true)
				fm:setCost(vector2(8, 2), 4)
				for i = 1, #walls do
					love.graphics.rectangle("fill", (walls[i].x - 1) * 30 + 2, (walls[i].y - 1) * 30 + 2, 26, 26)
				end
				love.graphics.setColor(0, 0, 1)
				local reach = fm:getReach(vector2(5, 1), 7)
				for i = 1, #reach do
					love.graphics.rectangle("fill", (reach[i].x - 1) * 30 + 2, (reach[i].y - 1) * 30 + 2, 26, 26)
				end
				love.graphics.setColor(1, 1, 1)
			end
		)
		return ui.newImageFrame(canvas)
	end
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "inBounds";
	["Arguments"] = {"vec2"};
	["Description"] = "Checks if the given tile is within bounds of the tile-map. The map starts at 1,1 so checking for x=0 or y=0 will always return false.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "isWall";
	["Arguments"] = {"vec2"};
	["Description"] = "Returns if the given tile is blocked off and prevents any traversal.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "print";
	["Arguments"] = {};
	["Description"] = "Prints the tile-map to the console. If no path has been generated yet, all tiles will be initialized to 'inf'.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "setCost";
	["Arguments"] = {"vec2", "cost"};
	["Description"] = "Sets the traversal cost of a tile. If no cost is supplied, it's defaulted to 1. Costs can still be set for tiles that are blocked off by :setWall(), but won't do much.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "setWall";
	["Arguments"] = {"vec2", "state"};
	["Description"] = "Sets if a given tile can be traversed or not, where 'state' is a boolean. A wall prevents any kind of movement from taking place on that tile.";
})


return {
	["Meta"] = meta;
	["Content"] = content;
}