
----------------------------------------------------[[ == VARIABLES & IMPORTS == ]]----------------------------------------------------

local module = {}
module.Running = {}


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
	--[[
	local update = love.update or function() end
	love.update = function()
		update()
		self:update()
	end
	]]
	return self.update
end



function module:update()
	local dt = love.timer.getDelta()
	local curTime = love.timer.getTime()
	local Copied = {} -- copy tasks over into a temporary array to preserve their spots when executing their functions!
	for i = 1, #self.Running do
		Copied[i] = self.Running[i]
	end
	for i = 1, #Copied do
		if curTime >= Copied[i].NextRun and Copied[i].Active then -- if curTime >= Copied[i].LastRun + Copied[i].Interval and Copied[i].Active then
			local resumed, msg = coroutine.resume(Copied[i].Routine, dt, curTime - Copied[i].ActivatedAt)
			--[[
			if type(msg) == "string" then
				error("task errored: " .. msg)
			end
			]]
			if not resumed then
				local trace = debug.traceback(Copied[i].Routine, msg)
				error("Task errored:\n" .. trace)
			end


			-- there are two outcomes here. Either the task ran to its completion, or it ran until it encountered a yield, meaning we need to come back after a delay
			if type(msg) == "number" then -- a number means a yield was encountered (through task:wait(secs))
				-- when you yield, set NextRun to when it should continue running
				Copied[i].NextRun = love.timer.getTime() + msg -- msg is how long to yield for
				Copied[i].YieldCount = Copied[i].YieldCount + 1
			else -- msg == nil
				-- if the task ran until its completion, stop it if there are no more repeats, or if there are, create a new coroutine and then wait to run it
				if Copied[i].YieldCount == 0 then -- if no yield were encountered, base the next run on the current 'NextRun' value to prevent miniscule delays from creeping in
					Copied[i].NextRun = Copied[i].NextRun + Copied[i].Interval
				else -- if delays were encountered, we cannot use the current 'NextRun' value to calculate the new 'NextRun', so use the current timer instead
					Copied[i].NextRun = love.timer.getTime() + Copied[i].Interval
				end
				Copied[i].YieldCount = 0 -- reset the yield count after you complete a cycle of the task

				Copied[i].TimesRan = Copied[i].TimesRan + 1
				if Copied[i].TimesRan >= Copied[i].Runs then
					Copied[i]:stop()
				else
					Copied[i].Routine = coroutine.create(Copied[i].Function)
				end
			end
		end
	end
end



-- returns a task object with its own functions. f is the function, r is the number of runs, w is the time between each repeat
local function new(f, r, w)
	local t = {
		["Active"] = false;
		["Function"] = f;
		["Routine"] = nil; -- coroutine gets created when :run() is called, deleted/cancelled when :stop() is called
		["Runs"] = r or 1;
		["TimesRan"] = 0;
		["Interval"] = w or 0; -- 0 seconds means the task is run every frame
		--["LastRun"] = -math.huge; -- when the task was last run
		["NextRun"] = -math.huge; -- used to be LastRun, but is renamed and reworked so it can be combined with task:wait()
		["YieldCount"] = 0; -- how many times a yield was encountered while running a single loop of the task
		["ActivatedAt"] = 0; -- will be set to the current timestep when run is called
	}
	return setmetatable(t, task)
end



-- run function f after d seconds and repeat r times with w time between each repeat
local function spawn(f, d, r, w)
	if d == nil then d = 0 end
	w = w or 0
	local t = new(f, r, w)
	t.NextRun = love.timer.getTime() + d
	t:run()
	return t
end



----------------------------------------------------[[ == TASK METHODS == ]]----------------------------------------------------

function task:run()
	if not self.Active then
		self.Active = true
		self.TimesRan = 0
		self.Routine = coroutine.create(self.Function)
		module.Running[#module.Running + 1] = self
		self.ActivatedAt = love.timer.getTime()
	end
end



function task:stop()
	for i = 1, #module.Running do
		if module.Running[i] == self then
			table.remove(module.Running, i)
			self.Active = false
			self.Routine = nil
			self.YieldCount = 0
			break
		end
	end
end



function task:wait(secs)
	if coroutine.running() ~= self.Routine then
		error("task:wait(secs) can only be called from within the function executed by the task.")
	end
	if secs == nil then secs = 0 end
	self.YieldCount = self.YieldCount + 1
	coroutine.yield(secs)
end



----------------------------------------------------[[ == RETURN == ]]----------------------------------------------------

module.new = new
module.spawn = spawn
return setmetatable(module, {__call = function(_, ...) return new(...) end})

