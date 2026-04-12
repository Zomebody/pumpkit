
-- TODO: figure out a better way of invorporating the OpenGL labels utility into the profiler
-- OpenGL utility from: https://www.love2d.org/forums/viewtopic.php?t=92481

----------------------------------------------------[[ == OPENGL LABELS == ]]----------------------------------------------------

local ffi = require("ffi")
local OpenGL = {}
OpenGL.GL = {}
OpenGL.SDL = ffi.os == "Windows" and ffi.load("SDL2") or ffi.C


function OpenGL.init()
	local definitions = [[
		//---------------------
		// OpenGL
		//---------------------
		typedef char GLchar;
		typedef int GLsizei;
		typedef unsigned int GLuint;
		typedef unsigned int GLenum;

		// void glPushDebugGroup( GLenum source, GLuint id, GLsizei length, const GLchar *message );
		typedef void (APIENTRYP PFNGLPUSHDEBUGGROUPPROC) (GLenum source, GLuint id, GLsizei length, const GLchar *message);

		// void glPopDebugGroup( void );
		typedef void (APIENTRYP PFNGLPOPDEBUGGROUPPROC) (void);

		//---------------------
		// SDL
		//---------------------
		typedef bool SDL_bool;
		SDL_bool SDL_GL_ExtensionSupported( const char *extension );
		void* SDL_GL_GetProcAddress( const char *proc );
	]]

	if ffi.os == "Windows" then
		definitions = definitions:gsub("APIENTRYP", "__stdcall *")
	else
		definitions = definitions:gsub("APIENTRYP", "*")
	end

	ffi.cdef(definitions)

	-- https://registry.khronos.org/OpenGL/api/GL/glext.h
	local names = {
		{"glPushDebugGroup", "PFNGLPUSHDEBUGGROUPPROC"},
		{"glPopDebugGroup", "PFNGLPOPDEBUGGROUPPROC"}
	}
	local procName = ""
	local GLName = ""

	for i = 1, #names do
		GLName = names[i][1]
		procName = names[i][2]
		local Function = ffi.cast(procName, OpenGL.SDL.SDL_GL_GetProcAddress(GLName))
		rawset(OpenGL.GL, GLName, Function)
	end
end


OpenGL.init()



----------------------------------------------------[[ == PROFILER == ]]----------------------------------------------------

local profiler = {
	["CurFrame"] = 0;
	["FrameLimit"] = 0;
	["Enabled"] = false;
	["History"] = {};
}


function profiler:flush()
	self.History = {}
end


function profiler:pushLabel(name)
	OpenGL.GL.glPushDebugGroup(0, 0, string.len(name), name)
	if self.Enabled then
		table.insert(self.History[self.CurFrame], {love.timer.getTime(), name})
	end
end



function profiler:popLabel()
	OpenGL.GL.glPopDebugGroup()
	if self.Enabled then
		table.insert(self.History[self.CurFrame], {love.timer.getTime()}) -- no second variable means 'pop'
	end
end



function profiler:finishFrame()
	if self.FrameLimit > self.CurFrame then
		self.CurFrame = self.CurFrame + 1
		self.Enabled = true
	else
		self.Enabled = false
	end
end



function profiler:runFor(frames)
	if self.Enabled then
		error("profiler:runFor(frames) failed because profiler is already running.")
	end
	self.History = {}
	for i = 1, frames do
		self.History[i] = {}
	end
	self.FrameLimit = frames
	self.CurFrame = 0
end



function profiler:print(x, y, width, barHeight)
	local randState = love.math.getRandomState()
	love.math.setRandomSeed(1) -- ensures all labels keep their random colors across different frames

	if (not self.History) or #self.History == 0 then
		return
	end

	--local profileStart = self.History[1][1] and self.History[1][1][1] or 0 -- frame 1, label 1, first value
	--local lastFrame = self.History[#self.History]
	--local lastLabel = lastFrame[#lastFrame]
	--local profileEnd = lastLabel and lastLabel[1] or profileStart + 1 -- last frame, last label, first value

	local sumFrameDurations = 0
	local frameDurations = {}
	for i = 1, #self.History do
		-- add frame time to total time
		local duration = (self.History[i][#self.History[i]][1] - self.History[i][1][1])
		frameDurations[i] = duration
		sumFrameDurations = sumFrameDurations + duration
	end

	local r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(1, 1, 1)


	local function drawFrame(frameNum)
		local frame = self.History[frameNum]
		local frameStartTime = frame[1][1]
		if not frame then return end
		--print("frame exists")

		local durationUpToFrame = 0
		for o = 1, frameNum - 1 do
			durationUpToFrame = durationUpToFrame + frameDurations[o]
		end

		-- draw line that signals the start of the frame
		local frameFraction = durationUpToFrame / sumFrameDurations
		local frameX = x + frameFraction * width
		love.graphics.setColor(1, 0, 0)
		love.graphics.print("frame: " .. tostring(frameNum), frameX, 2)
		love.graphics.line(frameX, 10, frameX, 100)

		local barIndex = 1
		local barLayer = 0

		repeat
			local entry = frame[barIndex]
			if not entry then break end
			--print("entry exists")

			if entry[2] ~= nil then-- is a push
				barLayer = barLayer + 1

				-- keep iterating until you find a matching 'pop'
				local pushStart = entry[1]
				local labelName = entry[2]
				local i = barIndex
				local popsToGo = 1

				while popsToGo > 0 and i < #frame do
					i = i + 1
					local nextEntry = frame[i]
					if nextEntry[2] == nil then -- is a 'pop'
						popsToGo = popsToGo - 1
					else
						popsToGo = popsToGo + 1
					end
				end

				local popEntry = frame[i]
				local popStart = popEntry and popEntry[1] or (pushStart + 0.001)
				--print("pushStart, popStart:", pushStart, popStart)

				-- draw the bar using pushStart and popStart
				--local xFracFrom = (pushStart - profileStart) / (profileEnd - profileStart)
				--local xFracTo = (popStart - profileStart) / (profileEnd - profileStart)
				

				local xFracFrom = (durationUpToFrame / sumFrameDurations) + (pushStart - frameStartTime) / sumFrameDurations
				local xFracTo = (durationUpToFrame / sumFrameDurations) + (popStart - frameStartTime) / sumFrameDurations

				local atX = x + xFracFrom * width
				local barWidth = (xFracTo - xFracFrom) * width
				local atY = y + barLayer * barHeight

				local v1 = love.math.random()
				local v2 = love.math.random()
				local v3 = love.math.random()
				love.graphics.setColor(0.5 * v1 + 0.5, 0.5 * v2 + 0.5, 0.5 * v3 + 0.5)
				--print(atX, atY, barWidth, barHeight)
				love.graphics.rectangle("fill", atX, atY, barWidth, barHeight)
				love.graphics.setColor(0, 0, 0)
				love.graphics.setScissor(atX, atY, barWidth, barHeight)
				love.graphics.print(labelName, atX, atY)
				love.graphics.setScissor()
			else
				barLayer = barLayer - 1
			end

			barIndex = barIndex + 1

		until barIndex > #frame
	end

	for frameNum = 1, #self.History do
		drawFrame(frameNum)
	end

	love.graphics.setColor(r, g, b, a)

	love.math.setRandomState(randState)

end




return profiler