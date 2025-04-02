
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
	["Description"] = "The time between each function call. In case of multiple repeats, the interval will remain consistent and not build up any delay - but using task:wait() breaks this guarantee.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "NextRun";
	["Description"] = "When the stored function will be run next. When task.spawn() is called, the NextRun value is set to the current time plus the delay to delay the execution of the task.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "function";
	["Name"] = "Routine";
	["Description"] = "The coroutine that will run the function stored in 'Function'. Coroutines are used so that tasks can yield through task:wait(). When an error occurs in a coroutine it will correctly be returned to the main thread and thrown there.";
	["ReadOnly"] = true;
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "number";
	["Name"] = "Runs";
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
	["Name"] = "YieldCount";
	["Description"] = "How often the execution of the task was halted through calling task:wait(). This property exists to guarantee that tasks without yields are executed at consistent intervals.";
	["ReadOnly"] = true;
})


table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "run";
	["Arguments"] = {};
	["Description"] = "Runs the task and sets its \"Active\" property to true.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "stop";
	["Arguments"] = {};
	["Description"] = "Stops the current task and sets its \"Active\" property to false.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "wait";
	["Arguments"] = {"seconds"};
	["Description"] = "Yields the task for the given number of seconds. This method can only be called from *within* the task's function itself. If a task or function tries to call :wait() on a different task, it will error.";
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