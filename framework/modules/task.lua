
----------------------------------------------------[[ == VARIABLES & IMPORTS == ]]----------------------------------------------------

local module = {}
module.Active = {}


local task = {}
task.__index = task



----------------------------------------------------[[ == MODULE METHODS == ]]----------------------------------------------------

-- hook into the love.update function
function module:initialize()
	if not module.Initialized then
		module.Initialized = true
	else
		return
	end

	-- Monkey Patching love.update such that tasks are executed at the start of the update loop
	local update = love.update or function() end
	love.update = function()
		update()
		self:update()
	end
end



function module:update()
	local dt = love.timer.getDelta()
	local i = 0
	local curTime = love.timer.getTime()
	local CopiedTasks = {} -- copy tasks over into a temporary array to preserve their spots when executing their functions!
	for i = 1, #self.Active do
		CopiedTasks[i] = self.Active[i]
	end
	for i = 1, #CopiedTasks do
		if curTime >= CopiedTasks[i].LastRun + CopiedTasks[i].Interval and CopiedTasks[i].Active then
			CopiedTasks[i].Function(dt, curTime - CopiedTasks[i].ActivatedAt)
			CopiedTasks[i].LastRun = CopiedTasks[i].LastRun + CopiedTasks[i].Interval
			CopiedTasks[i].TimesRan = CopiedTasks[i].TimesRan + 1
			if CopiedTasks[i].TimesRan >= CopiedTasks[i].Repeats then
				CopiedTasks[i]:stop()
			end
		end
	end
end

-- returns a task object with its own functions. f is the function, r is the number of repeats, w is the time between each repeat
local function new(f, r, w)
	local t = {
		["Active"] = false;
		["Function"] = f;
		["Repeats"] = r or 1;
		["TimesRan"] = 0;
		["Interval"] = w or 0; -- 0 seconds means the task is run every frame
		["LastRun"] = -math.huge; -- when the task was last run
		["ActivatedAt"] = 0; -- will be set to the current timestep when resume is called
	}
	return setmetatable(t, task)
end


-- run function f after d seconds and repeat r times with w time between each repeat
local function spawn(f, d, r, w)
	w = w or 0
	local t = new(f, r, w)
	t.LastRun = love.timer.getTime() - w + d
	t:resume()
	return t
end



----------------------------------------------------[[ == TASK METHODS == ]]----------------------------------------------------

function task:resume()
	if not self.Active then
		self.Active = true
		module.Active[#module.Active + 1] = self
		self.ActivatedAt = love.timer.getTime()
	end
end


function task:stop()
	for i = 1, #module.Active do
		if module.Active[i] == self then
			table.remove(module.Active, i)
			self.Active = false
			break
		end
	end
end



----------------------------------------------------[[ == RETURN == ]]----------------------------------------------------

module.new = new
module.spawn = spawn
return setmetatable(module, {__call = function(_, ...) return new(...) end})

