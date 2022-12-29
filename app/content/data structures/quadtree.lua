
local meta = {
	["Name"] = "quadtree";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "Quadtree data structure";
	["Description"] = "A quadtree can store items at certain locations within the quadtree's borders. It contains spatial queries to quickly find items at a specific location within the quadtree.\n\nThis implementation of the quadtree allows inserted objects to be given a size as well, through a 'radius' variable. If the circle described by the item's location and radius overlaps multiple quadtree cells, the object is inserted into all touching cells. This makes some look-ups faster, at the cost of making item removal more difficult.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Constructors";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "new";
	["Arguments"] = {"bucketSize", "maxSplits", "position", "size"};
	["Description"] = "Creates a new quadtree instance and returns it.\n- bucketSize: How many items can be stored within the same cell. If an item is inserted into a full cell, the cell is instead split into 4 quadrants and the item is inserted into the right children.\n- maxSplits: The total number of times a quadtree can be split. 'bucketSize' is ignored when at the deepest allowed layer.\n- position: A vector indicating the top left position the quadtree starts at.\n- size: A vector indicating the width and height of the quadtree (to the left and down).";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "insert";
	["Arguments"] = {"Object", "vector", "radius"};
	["Description"] = "Insert the given object into the quadtree at the given position vector and a given radius number. If the quadtree's bucket size has been reached, the object is instead inserted into child quadtrees.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "findClosest";
	["Arguments"] = {"vector"};
	["Description"] = "Return the item closest to the given position vector.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "getInRange";
	["Arguments"] = {"vector", "radius"};
	["Description"] = "Return a list of items which are within 'radius' units of the given position vector.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "split";
	["Arguments"] = {"vector"};
	["Description"] = "FOR INTERNAL USE ONLY. When a quadtree's bucket size has been reached when an item is inserted, this method is called to create 4 new quadtrees as children of the current quadtree. Newly inserted items are inserted into these child quadtrees instead.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "at";
	["Arguments"] = {"vector"};
	["Description"] = "Return a list of items which overlap the given position vector.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "draw";
	["Arguments"] = {};
	["Description"] = "A debug method to draw the quadtree. Note that this method is INCREDIBLY SLOW for large quadtrees as items may be inserted into multiple sub-trees. As such, they may be drawn multiple times!";
})

return {
	["Meta"] = meta;
	["Content"] = content;
}