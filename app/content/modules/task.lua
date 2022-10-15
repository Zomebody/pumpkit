
local meta = {
	["Name"] = "task";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The task Module";
	["Description"] = "A module that lets you create tasks; blocks of code to be executed either immediately or in the near future.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Constructors";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "new";
	["Arguments"] = {"function", "repeats", "interval"};
	["Description"] = "Create and return a new task. Argument 'function' is the function to run, 'repeats' is how many times the function should run in total and 'interval' is the time between each function call in seconds.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "spawn";
	["Arguments"] = {"function", "delay", "repeats", "interval"};
	["Description"] = "Create and immediately resume a task. Returns the created task. Argument 'function' is the function to run, 'delay' is how long it takes for the function to run the first time, 'repeats' is how many times the function should run in total and 'interval' is the time between each function call in seconds.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "initialize";
	["Arguments"] = {};
	["Description"] = "Initializes the task system. This should be called once when love.load is called. This method will apply 'Monkey Patching' to hook into love.update and automatically evaluate all tasks each frame.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "update";
	["Arguments"] = {};
	["Description"] = "Evaluates all current tasks. This function is called automatically after the task system is initialized.";
})

return {
	["Meta"] = meta;
	["Content"] = content;
}