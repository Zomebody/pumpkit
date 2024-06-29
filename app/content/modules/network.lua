
local meta = {
	["Name"] = "network";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The network Module";
	["Description"] = "A module that can be used to connect clients across a network. This acts as a wrapped around the lua-socket library.\n\nYou can create any number of 'server' instances that will run on your PC. However, you can only connect to one server at a time as a client.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "connect";
	["Arguments"] = {"ip", "port", "username", "callback"};
	["Description"] = "Connect to a Server instance and return a Client instance. This method does not yield, connecting to a server will yield, so the callback is only called after a short moment. After connecting to a server the client will automatically send a 'connect' event to the server.\n\n- ip: The ip as a string to connect to.\n- port: A number of the port to connect to. Each port only accepts at most one connection.\n- username: A string of the client's username. Cannot be an empty string and must be a unique string.\n- callback: a function that is called. It has one argument that is 'true' when a connection succeeded, or a string with the error message.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "startServer";
	["Arguments"] = {"ip", "slots"};
	["Description"] = "Start a server at the given ip string. Slots is the number of clients that can connect to the server at most.\n\nThis method returns a 'Server' instance.";
})


return {
	["Meta"] = meta;
	["Content"] = content;
}