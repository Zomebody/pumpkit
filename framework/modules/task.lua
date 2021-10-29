
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
		self:update()
		update()
	end
end

-- update all tasks
function module:update()
	local dt = love.timer.getDelta()
	local i = 0
	local curTime = love.timer.getTime()
	while i < #self.Active do
		i = i + 1
		if curTime >= module.Active[i].LastRun + module.Active[i].Interval then
			module.Active[i].Function(dt)
			-- increase LastRun by self.Interval instead of setting it to love.timer.getTime() to prevent rounding errors from stacking up on low frame-rates!
			module.Active[i].LastRun = module.Active[i].LastRun + module.Active[i].Interval
			module.Active[i].TimesRan = module.Active[i].TimesRan + 1
			if module.Active[i].TimesRan >= module.Active[i].Repeats then
				table.remove(self.Active, i)
				i = i - 1
			end
		end
	end
end


-- returns a task object with its own functions. f is the function, r is the number of repeats, w is the time between each repeat
local function new(f, r, w)
	local t = {
		["Function"] = f;
		["Repeats"] = r or 1;
		["TimesRan"] = 0;
		["Interval"] = w or 0; -- 0 seconds means the task is run every frame
		["LastRun"] = -math.huge; -- when the task was last run
	}
	return setmetatable(t, task)
end


-- run function f after d seconds and repeat r times with w time between each repeat
local function spawn(f, d, r, w)
	w = w or 0
	local t = new(f, r, w)
	t.LastRun = love.timer.getTime() - w + d
	t:resume()
end



----------------------------------------------------[[ == TASK METHODS == ]]----------------------------------------------------

function task:resume()
	module.Active[#module.Active + 1] = self
end


function task:remove()
	for i = 1, #module.Active do
		if module.Active[i] == self then
			table.remove(module.Active, i)
			break
		end
	end
end



----------------------------------------------------[[ == RETURN == ]]----------------------------------------------------

module.new = new
module.spawn = spawn
return setmetatable(module, {__call = function(_, ...) return new(...) end})

