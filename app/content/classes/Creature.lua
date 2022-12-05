
local meta = {
	["Name"] = "Creature";
	["SuperClass"] = "Entity"
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The Creature instance";
	["Description"] = "A Creature is a type of entity that can be added to a scene for gameplay purposes. Creatures can have multiple states with their own animations.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Properties";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Property";
	["ValueType"] = "dictionary";
	["Name"] = "States";
	["Description"] = "A dictionary where each key is the name of a state and the value is a dictionary with an 'Animations' key containing an array of the state's animations and a 'Priorities' key containing an array of the corresponding weight functions.";
	["ReadOnly"] = true;
})





table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "draw";
	["Arguments"] = {};
	["Description"] = "Draw the creature to the current render target. This does not take any camera manipulation into consideration.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "addState";
	["Arguments"] = {"name", "Animation", "evaluation", "..."};
	["Description"] = "Add a new state to the creature with the first argument as its name. Duplicate state names are now allowed. The following two arguments are an Animation instance and a function which returns a number value. You may pass multiple additional animation and function pairs are arguments.\n\nThe Animation instance is one of the animations that will be played in this creature's state.\nThe evaluation paramater is a function that returns a priority value. If you pass multiple animations, the animation whose corresponding function returns the highest value will be shown on screen.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "getSprite";
	["Arguments"] = {};
	["Description"] = "Returns the Image and Quad of the animation with the highest current priority. This basically calls the animation:getSprite() method on and returns its results.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "getState";
	["Arguments"] = {"name"};
	["Description"] = "Returns a reference to the creature's current state. A state is a table with two properties:\n- 'Animations': An array with all the animations of the current state.\n- 'Priorities': An array with functions that all return numbers. Each function corresponds to an animation in the Animations array with the same index.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "hasState";
	["Arguments"] = {"name"};
	["Description"] = "Returns if the creature has a state with the given name.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "setState";
	["Arguments"] = {"name"};
	["Description"] = "Sets the creature's state to the given state name. If the creature is already in the passed state, nothing happens.";
})

table.insert(content, {
	["Type"] = "Method";
	["Name"] = "__tostring";
	["Arguments"] = {};
	["Description"] = "Returns a string representation of the creature object.";
})


table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Events";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Event";
	["Name"] = "StateEntered";
	["Arguments"] = {"state"};
	["Description"] = "Called when the entity has its state changed. The provided argument is a string with the name of the new state.";
})

table.insert(content, {
	["Type"] = "Event";
	["Name"] = "StateLeaving";
	["Arguments"] = {"state"};
	["Description"] = "Called when the entity is about to leave its current state. The provided argument is a string with the name of the state that is being left.";
})


return {
	["Meta"] = meta;
	["Content"] = content;
}