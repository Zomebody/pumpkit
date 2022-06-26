
local meta = {
	["Name"] = "Connection";
}

local content = {}

table.insert(content, {
	["Type"] = "Header";
	["Name"] = meta.Name;
	["Description"] = "A Connection object is returned by any instance's :on() method. When an event is linked to a function, it returns a Connection object that can be used to unlink the function from that event at a later moment.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Properties";
	["Description"] = "All properties from the Connection object are read-only and are mostly used for internal use only.";
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "boolean";
	["Name"] = "Connected";
	["Description"] = "If the signal is still linked. :disconnect() can only be called if this property is true. Disconnecting the connection will automatically set this value to false.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "string";
	["Name"] = "EventName";
	["Description"] = "The name of the event to disconnect. This property is used to find the right event array to remove the linked function from.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "integer";
	["Name"] = "Id";
	["Description"] = "The unique identifier of the connection object. Connections that were created earlier have lower Id values than ones created after them. The Id property is used to quickly (log2(n)) find the right function to remove from an object's event array, as the connection is stored alongside the linked function.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "Object";
	["Name"] = "LinkedElement";
	["Description"] = "A reference to the object whose :on() method created this Connection instance. The reference is used when the :disconnect() method is called to get the right object to scan their event array.";
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
	["Description"] = "If the Connected property is true, this will unlink the function from the event trigger inside the linked element. If the connection has already been disconnected, this will error instead.";
})


return {
	["Meta"] = meta;
	["Content"] = content;
}