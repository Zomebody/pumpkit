
local meta = {
	["Name"] = "Client";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "A Client instance";
	["Description"] = "A Client is an instance created when connecting to a server through the 'network' module.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Properties";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "string";
	["Name"] = "Username";
	["Description"] = "The username of the client. When connecting to a server you supply a unique username, which is also stored on the client in this property. It has no real purpose.";
	["ReadOnly"] = true;
})


table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "disconnect";
	["Arguments"] = {};
	["Description"] = "Disconnect from the server. You will no longer receive and process server information. When calling this method, you internallt send a 'disconnect' event to the server.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "on";
	["Arguments"] = {"eventName", "function"};
	["Description"] = "Registers a function to be called when the given event is triggered. Unlike with other 'on' methods of instances, this one triggers when a Server instance sends an event signal to the client over the network. Some event names are reserved and will throw an error when used.\n\nReturns a Connection object.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "send";
	["Arguments"] = {"eventName", "..."};
	["Description"] = "Send an event to the Server instance you're connected to. Following parameter are event arguments. If the server has connected to the event you sent with their 'on' method, the server will trigger that event.";
})



return {
	["Meta"] = meta;
	["Content"] = content;
}