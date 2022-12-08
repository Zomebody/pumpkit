
local meta = {
	["Name"] = "signal";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The signal Module";
	["Description"] = "The signal module helps with communicating between different sections of your application without the need to pass or share references. Instead, you can fire signals and listen to them in other parts of your code.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "fire";
	["Arguments"] = {"name", "..."};
	["Description"] = "Fire a signal with the given name. All Listeners that are listening to that signal name will have their function called with all arguments - after the name argument - passed.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "listen";
	["Arguments"] = {"name", "function"};
	["Description"] = "Listen to the given signal name. When the fire method is called with that name, the passed function argument will be called. This method returns a 'connection' object which can be used to disconnect the signal listener at a later moment.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "once";
	["Arguments"] = {"name", "function"};
	["Description"] = "Similar to the listen method, but this function only works once. This method also returns a connection object.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "__call";
	["Arguments"] = {"name", "..."};
	["Description"] = "The __call metamethod. This is a short way of calling the fire() method and uses the same arguments.";
})

return {
	["Meta"] = meta;
	["Content"] = content;
}