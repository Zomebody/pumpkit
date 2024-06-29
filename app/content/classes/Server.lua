
local meta = {
	["Name"] = "Server";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "A Server instance";
	["Description"] = "A Server is an instance created when you call the 'startServer' method of the 'network' module.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Properties";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "dictionary";
	["Name"] = "ClientToName";
	["Description"] = "A dictionary that maps a server 'slot' (one of the threads running for one of the open ports) to the username of who is connected on that port.";
	["ReadOnly"] = true;
})


table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "Id";
	["Description"] = "The identifier of this server. A simple counter goes up each time a server is created and sets that counter's value as the server identifier.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "dictionary";
	["Name"] = "OpenPorts";
	["Description"] = "An array containing the port numbers that are listening to connections. Ports that are currently in use will not be removed from this array.";
	["ReadOnly"] = true;
})


table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "broadcast";
	["Arguments"] = {"eventName", "..."};
	["Description"] = "Send an event to all connected clients. Following parameter are event arguments. If the client has connected to the event you sent with their 'on' method, the client will trigger that event.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "close";
	["Arguments"] = {};
	["Description"] = "Closes the server. All connected clients will be sent a 'disconnect' event.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "getOpenPorts";
	["Arguments"] = {};
	["Description"] = "Returns an array of ports that were opened by the server. It does not list which ports are in use.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "kick";
	["Arguments"] = {"username"};
	["Description"] = "Disconnect the given username from the server. Triggers a 'disconnect' event on both the server and the kicked client.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "nextFreePort";
	["Arguments"] = {};
	["Description"] = "Returns the number of the first port that is open and has no client connected to it. If no ports are left this returns nil.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "on";
	["Arguments"] = {"eventName", "function"};
	["Description"] = "Registers a function to be called when the given event is triggered. Unlike with other 'on' methods of instances, this one triggers when a Client instance sends an event signal to the server over the network. Some event names are reserved and will throw an error when used.\n\nReturns a Connection object.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "send";
	["Arguments"] = {"username", "eventName", "..."};
	["Description"] = "Send an event to the client with the given username. Following parameter are event arguments. If the client has connected to the event you sent with their 'on' method, the client will trigger that event.";
})



return {
	["Meta"] = meta;
	["Content"] = content;
}