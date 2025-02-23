
local meta = {
	["Name"] = "tween";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The tween Module";
	["Description"] = "A module responsible for the creation and execution of tweens.";
	["CodeMarkup"] = "";
	["Demo"] = function()
		local Container = ui.newFrame(400, 120, color(0, 0, 0))
		Container:setPadding(20, 20)
		local Box = ui.newFrame(80, 80, color(1, 1, 1))
		Box:alignX("left")
		Container:addChild(Box)

		local TweenedObject = {["Value"] = 0}
		local posTween = tween.new(TweenedObject, "sine", 2, {["Value"] = 1})

		Box:on("FullPress", function(x, y, button)
			if button == 1 then
				print(#tween.Active)
				if posTween.State == "playing" then
					posTween:pause()
				else
					posTween:resume()
				end
			end
		end)

		posTween:on("Update", function()
			Box:reposition(TweenedObject.Value, 0, 0, 0)
			Box:setCenter(TweenedObject.Value, 0)
		end)

		return Container
	end;
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Properties";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "dictionary";
	["Name"] = "TweenTypes";
	["Description"] = "A dictionary where keys are all the valid built-in tween types, and the values are functions that take in a variable 'x' between 0 and 1, and output a 'y' where y=0 at x=0 and y=1 at x=1.";
	["ReadOnly"] = true;
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
	["Description"] = "Initializes the tween system. This should be called once when love.load is called. This method will apply 'Monkey Patching' to hook into love.update and automatically update all tweens each frame.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "new";
	["Arguments"] = {"Object", "tweenType", "duration", "Dictionary"};
	["Description"] = "Constructs a tween.\n- Object is the object whose properties should be tweened.\n- tweenType is a function that takes a number argument 'x' and returns a 'y' (where y=0 at x=0 and y=1 at x=1), or tweenType is a string representing a type of tween ('back', 'bounce', 'circle', 'cube', 'linear', 'recoil', 'quad', 'shake', 'sine', 'sqrt').\n- duration is how long the tween takes from start to finish.\n- Dictionary is a dictionary where each key is the property in the target Object and its value is the new value the property should transition towards.\n\nIf the tween module itself is called, this method will be called instead.\n\nBelow is a visualization of each tween type:";
	["Demo"] = function()
		local keys = {}
		for k, _ in pairs(tween.TweenTypes) do
			table.insert(keys, k)
		end
		table.sort(keys)
		local canvas = love.graphics.newCanvas(200, #keys * 130)
		
		canvas:renderTo(
			function()
				love.graphics.setColor(0, 0, 0)
				love.graphics.rectangle("fill", 0, 0, 200, #keys * 130)
				love.graphics.setColor(1, 1, 1)

				local height = 10
				for k = 1, #keys do
					local func = tween.TweenTypes[keys[k]]
					-- graph
					love.graphics.line(20, height, 20, height + 100, 120, height + 100)
					love.graphics.print("1", 5, height)
					love.graphics.print("y", 5, height + 50)
					love.graphics.print("0", 8, height + 102)
					love.graphics.print("x", 60, height + 105)
					love.graphics.print("1", 115, height + 105)
					love.graphics.print(keys[k], 130, height + 85)

					-- graph curve
					local yPrev = func(0)
					for i = 1, 100 do
						local y = func(i / 100) * 100
						love.graphics.line(20 + (i - 1), height + 100 - yPrev, 20 + i, height + 100 - y)
						yPrev = y
					end

					height = height + 130
				end

			end
		)

		return ui.newImageFrame(love.graphics.newImage(canvas:newImageData()))
	end
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "update";
	["Arguments"] = {};
	["Description"] = "Updates the values of all tweened objects. Also stops tweens that have finished and marks them as inactive. This function is called automatically when the tween system is initialized.";
})

return {
	["Meta"] = meta;
	["Content"] = content;
}