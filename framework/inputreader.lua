
--[[

DOCUMENTATION:
inputreader is an object used to read certain inputs, such as key presses. It does so by unlinking other input events
and taking over the reading controls. This can be useful, for example, for creating text boxes that require the
keyboard focus without triggering other code in the meantime that listens to keypresses.

]]



----------------------------------------------------[[ == VARIABLES == ]]----------------------------------------------------

local utf8 = require("utf8")

local inputreader = {
	["KeyboardLocked"] = false;
	["OldKeyPressed"] = nil;
	["OldKeyReleased"] = nil;
	["OldTextInput"] = nil;
	["String"] = ""
}



----------------------------------------------------[[ == FUNCTIONS == ]]----------------------------------------------------

-- claim all keyboard input such that all keyboard inputs go towards this system
function inputreader:focusKeyboard(backspaceEnabled, ...) -- arguments are the keys to unlock the keyboard again
	if self.KeyboardLocked then
		return
	end
	local args = {...}
	self.KeyboardLocked = true
	self.String = ""
	self.OldTextInput = love.textinput
	self.OldKeyPressed = love.keypressed
	self.OldKeyReleased = love.keyreleased

	-- replace keypressed while inputreader has keyboard focus
	love.keypressed = function(key, scancode, isrepeat)
		if backspaceEnabled and key == "backspace" then
			-- https://love2d.org/wiki/love.textinput
			local byteoffset = utf8.offset(self.String, -1) -- get the byte offset to the last UTF-8 character in the string.
			if byteoffset then
				-- remove the last UTF-8 character.
				-- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(self.String, 1, -2).
				self.String = string.sub(self.String, 1, byteoffset - 1)
			end
		end
	end

	-- replace keyreleased while inputreader has keyboard focus
	love.keyreleased = function(key, scancode)
		for i = 1, #args do
			if key == args[i] then
				self:releaseKeyboard()
				return
			end
		end
	end

	-- replace textinput while inputreader has keyboard focus. Add to the string
	love.textinput = function(t)
		self.String = self.String .. t
	end
end

-- release all keyboard input and set the keyboard functions back to their old ones
function inputreader:releaseKeyboard()
	if not self.KeyboardLocked then
		return
	end
	self.KeyboardLocked = false
	love.keypressed = self.OldKeyPressed
	love.keyreleased = self.OldKeyReleased
	love.textinput = self.OldTextInput
	self.OldKeyPressed = nil
	self.OldKeyReleased = nil
	self.OldTextInput = nil
end


-- return the current text that has been entered
function inputreader:getString()
	return self.String
end


function inputreader:clear()
	self.String = ""
end



----------------------------------------------------[[ == RETURN == ]]----------------------------------------------------

return inputreader



