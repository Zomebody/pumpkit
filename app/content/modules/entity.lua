
local meta = {
	["Name"] = "entity";
}

local content = {}

table.insert(content, {
	["Type"] = "IntroHeader";
	["Name"] = "The entity Module";
	["Description"] = "A module used to create entities. There are two types of entities, Creature and Prop type entities. Creatures have states where each state has one or more animations attached to them. Props on the other hand have no states and only have a single image that is drawn.";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Constructors";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "newCreature";
	["Arguments"] = {"defaultState", "Animation", "evaluation", "..."};
	["Description"] = "Creates a new Creature instance. 'defaultState' is the name of the state that the Creature will have by default. The following two arguments are an Animation instance and a function which returns a number value. You may pass multiple additional animation and function pairs are arguments.\n\nThe Animation instance is one of the animations that will be played in the creature's default state.\nThe evaluation paramater is a function that returns a priority value. When a state has multiple animations, the animation whose corresponding function returns the highest value will be shown on screen.";
	["CodeMarkup"] = "<c>-- create a creature who, in their 'idle' state, alternates between</c>\n<c>-- the breatheIn and breatheOut animation every second!</c>\n<k>local</k> Creature <k>=</k> entity.<f>newCreature</f>(<s>\"idle\"</s>,\n\tbreatheIn, <f>function</f>() <k>return</k> love.timer.<f>getDelta</f>() <k>%</k> <n>2</n> <k>end</k>,\n\tbreatheOut, <f>function</f>() <k>return</k> (love.timer.<f>getDelta</f>() <k>+</k> <n>1</n>) <k>%</k> <n>2</n> <k>end</k>\n)";
})

table.insert(content, {
	["Type"] = "Header";
	["Name"] = "Methods";
	["Description"] = "";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "isCreature";
	["Arguments"] = {"Object"};
	["Description"] = "Checks if the given object is a Creature instance.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "isEntity";
	["Arguments"] = {"Object"};
	["Description"] = "Checks if the given object is either a Creature instance or a Prop instance.";
})

table.insert(content, {
	["Type"] = "Constructor";
	["Name"] = "isProp";
	["Arguments"] = {"Object"};
	["Description"] = "Checks if the given object is a Prop instance.";
})

return {
	["Meta"] = meta;
	["Content"] = content;
}