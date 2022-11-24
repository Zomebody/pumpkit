
local here = ...

function load()
	getpath = require("framework.getpath");

	-- data types
	vector = require(getpath(here, "../framework/datatypes/vector"))
	line = require(getpath(here, "../framework/datatypes/line"))
	polygon = require(getpath(here, "../framework/datatypes/polygon"))
	color = require(getpath(here, "../framework/datatypes/color"))
	task = require(getpath(here, "../framework/modules/task"))

	-- weird stuff
	tween = require(getpath(here, "../framework/modules/tween"))
	animation = require(getpath(here, "../framework/modules/animation"))
	font = require(getpath(here, "../framework/modules/font"))
	--signal = require(getpath(here, "../framework/modules/signal"))
	printObject = require(getpath(here, "../framework/objectPrinter"))
	ui = require(getpath(here, "../framework/modules/ui"))

	-- world stuff
	world = require(getpath(here, "../framework/modules/world"))
	scene = require(getpath(here, "../framework/modules/scene"))
	camera = require(getpath(here, "../framework/modules/camera"))
end

return load