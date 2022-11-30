
local meta = {
	["Name"] = "callbacks";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The callbacks Module";
	["Description"] = "A module used to easily (un)link functions to default Love2D callbacks. All default callbacks of the Love2D module are supported except for the 'loade', 'update', 'draw' and 'errorhandler' callbacks.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "on";
	["Arguments"] = {"callbackName", "function"};
	["Description"] = "Link a given Love2D callback to the given function. Arguments normally provided to the Love2D callback will also be passed to the given function. Note that unlike other event names, Love2D callbacks are all lower-case.\n\nReturns a Connection object.";
})


return {
	["Meta"] = meta;
	["Content"] = content;
}