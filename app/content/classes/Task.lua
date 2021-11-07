
local meta = {
	["Name"] = "Task";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The task data type";
	["Description"] = "A task object that can run a function (multiple times) after a certain delay.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Properties";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "boolean";
	["Name"] = "Active";
	["Description"] = "Whether or not the task has been started yet. :resume() can only be called if this value is false.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "function";
	["Name"] = "Function";
	["Description"] = "The function to run. A delta-time argument is passed as the only argument, which is the time between the current and previous frame.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "Interval";
	["Description"] = "The time between each function call. In case of multiple repeats, the interval will remain consistent and not build up any delay.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "LastRun";
	["Description"] = "When the Function argument was last called. When task.spawn() is called, the LastRun value is set to the current time minus the delay to delay the execution of the task.";
	["ReadOnly"] = true;
})


table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "getProgress";
	["Arguments"] = {};
	["Description"] = "Returns the current progress of the tween, which is a number between 0 and 1.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "getValue";
	["Arguments"] = {"key"};
	["Description"] = "Returns the current tweened value from the given key. The key must be one that has been provided upon creation of the tween object.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "play";
	["Arguments"] = {"reversed", "inverted"};
	["Description"] = "This will play the tween from the start. A tween can only be played if its state is \"idle\". Reversed and inverted are booleans. Reversed will play the tween backwards. Inverted will flip the tweened values. Returns true on success.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "pause";
	["Arguments"] = {};
	["Description"] = "Changes the state of the tween to \"paused\". This only takes effect if the state is \"playing\". Returns true on success.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "resume";
	["Arguments"] = {};
	["Description"] = "Resumes the tween. If the tween is idle, it calls :play() instead. If the tween is paused, its state will be set to \"playing\" to resume the tween. Returns true on success.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "stop";
	["Arguments"] = {};
	["Description"] = "Stops the current tween and sets its state to \"idle\". A tween must not be idle in order to be stopped. Returns true on success.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "update";
	["Arguments"] = {"dt"};
	["Description"] = "This will progress the tween to the next step. This method is called automatically when any tween whose state equals \"playing\". Dt is the time passed during the last frame. Returns true if the tween completed and should be removed from the list of active tweens. This is also done automatically.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "__tostring";
	["Arguments"] = {};
	["Description"] = "Prints the tween in readable format. Contains the tween type and duration.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Callbacks";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Callback";
	["Name"] = "OnStop";
	["Arguments"] = {"state"};
	["Description"] = "Called right after the tween stopped. State is either \"completed\" if the tween stopped on its own when reaching the end, or \"cancelled\" if it was stopped manually with a :stop() call.";
})

table.insert(content, {
	["Type"] = "Callback";
	["Name"] = "OnUpdate";
	["Arguments"] = {};
	["Description"] = "Called anytime the tween's values are updated.";
})


return {
	["Meta"] = meta;
	["Content"] = content;
}