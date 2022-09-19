
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
	["Name"] = "Repeats";
	["Description"] = "How often the task is run. Defaults to '1'.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "TimesRan";
	["Description"] = "How many times the task's function has been called already.'";
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
	["Name"] = "resume";
	["Arguments"] = {};
	["Description"] = "Resumes the task and sets its \"Active\" property to true.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "stop";
	["Arguments"] = {};
	["Description"] = "Stops the current task and sets its \"Active\" property to false.";
})


table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Events";
	["Description"] = "";
})


return {
	["Meta"] = meta;
	["Content"] = content;
}