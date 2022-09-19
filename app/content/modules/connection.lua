
local meta = {
	["Name"] = "connection";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The connection Module";
	["Description"] = "FOR INTERNAL USE ONLY!\n\nThis module is responsible for the creation of Connection instances.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Constructors";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "newConnection";
	["Arguments"] = {"Object", "eventName"};
	["Description"] = "FOR INTERNAL USE ONLY!\n\nWhen the :on() method is called on an object, it will create a new connection with itself as the object reference and the name passed by the :on() arguments. Connections are stored within the object's Event dictionary alongside the function to call.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "doEvents";
	["Arguments"] = {"array", "..."};
	["Description"] = "FOR INTERNAL USE ONLY!\n\nWhen the framework triggers an event, it does so by calling this method. The first argument is the event array, which is the array within an object's Event dictionary for the given event name. Any other passed arguments are the event's variables that are passed to the functions to call within the event array.";
})

return {
	["Meta"] = meta;
	["Content"] = content;
}