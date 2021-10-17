
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

		Box.OnFullPress = function(x, y, button)
			if button == 1 then
				print(#tween.Active)
				if posTween.State == "playing" then
					posTween:pause()
				else
					posTween:resume()
				end
			end
		end

		posTween.OnUpdate = function()
			Box:reposition(TweenedObject.Value, 0, 0, 0)
			Box:setCenter(TweenedObject.Value, 0)
		end

		return Container
	end;
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
	["Description"] = "Constructs a tween. Object is the object whose properties should be tweened. tweenType is a string representing the type of tween ('back', 'bounce', 'circle', 'cube', 'linear', 'recoil', 'quad', 'shake', 'sine', 'sqrt'). The duration parameter is how long the tween takes from start to finish. Dictionary is a dictionary where each key is the property in the target Object and its value is the new value the property should transition towards.\n\nIf the tween module itself is called, this method will be called instead.";
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