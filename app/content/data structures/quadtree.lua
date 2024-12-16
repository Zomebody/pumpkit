
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
	["Arguments"] = {"position", "size", "bucketSize", "maxSplits"};
	["Description"] = "Creates a new quadtree instance and returns it.\n- position: A vector2 indicating the top left position the quadtree starts at.\n- size: A vector2 indicating the width and height of the quadtree (to the left and down).\n- bucketSize: How many items can be stored within the same cell. If an item is inserted into a full cell, the cell is instead split into 4 quadrants and the item is inserted into the right children.\n- maxSplits: The total number of times a quadtree can be split. 'bucketSize' is ignored when at the deepest allowed layer.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Properties";
	["Description"] = "Note that these are the properties of a quadtree, not of the module creating the quadtrees!";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "BucketSize";
	["ValueType"] = "number";
	["ReadOnly"] = true;
	["Description"] = "The number of items that may be stored in the quadtree.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "Items";
	["ValueType"] = "array";
	["ReadOnly"] = true;
	["Description"] = "An array of items that are stored inside the current quadtree cell. Each item in the list has an 'Item' property which is the stored object, a 'Position' vector2 and a 'Radius' value.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "MaxSplits";
	["ValueType"] = "number";
	["ReadOnly"] = true;
	["Description"] = "The maximum number of splits which the current quadtree allows. When a quadtree is split, its children will have a MaxSplits value of 1 less than their parent quadtree.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "Position";
	["ValueType"] = "vector2";
	["ReadOnly"] = true;
	["Description"] = "The top-left position of the current quadtree.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "Size";
	["ValueType"] = "vector2";
	["ReadOnly"] = true;
	["Description"] = "The width and height of the current quadtree.";
})

table.insert(content, {
	["Type"] = "Property";
	["Name"] = "Splits";
	["ValueType"] = "array";
	["ReadOnly"] = true;
	["Description"] = "An array with child quadtrees. This array always contains either 0 items or 4 items depending on if the quadtree has been split or not.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "Note that these are the methods of a quadtree, not of the module creating the quadtrees!";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "at";
	["Arguments"] = {"vector2"};
	["Description"] = "Return a list of items which overlap the given position vector2.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "draw";
	["Arguments"] = {};
	["Description"] = "A debug method to draw the quadtree. Note that this method is INCREDIBLY SLOW for large quadtrees as items may be inserted into multiple sub-trees. As such, they may be drawn multiple times!";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "findClosest";
	["Arguments"] = {"vector2"};
	["Description"] = "Return the item closest to the given position vector2.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "getInRange";
	["Arguments"] = {"vector2", "radius"};
	["Description"] = "Return a list of items which are within 'radius' units of the given position vector2.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "insert";
	["Arguments"] = {"Object", "vector2", "radius"};
	["Description"] = "Insert the given object into the quadtree at the given position vector2 and a given radius number. If the quadtree's bucket size has been reached, the object is instead inserted into child quadtrees.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "remove";
	["Arguments"] = {"Object", "vector2", "radius"};
	["Description"] = "Removes the given object from the quadtree. The 'vector2' and 'radius' arguments are optional but will speed up the removal process a lot if you can supply the circular region in which the object is found!";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "split";
	["Arguments"] = {};
	["Description"] = "FOR INTERNAL USE ONLY. When a quadtree's bucket size has been reached when an item is inserted, this method is called to create 4 new quadtrees as children of the current quadtree. Newly inserted items are inserted into these child quadtrees instead.";
})

return {
	["Meta"] = meta;
	["Content"] = content;
}