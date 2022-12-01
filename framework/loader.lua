
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
	entity = require(getpath(here, "../framework/modules/entity"))

	ui:initialize()
	task:initialize()
	tween:initialize()
	animation:initialize()
	world:initialize()
	camera:initialize()
end

return load


--[[

order in which the following Love2D callbacks are being used by the modules:

love.update: (ui, world, tween, animation, task)
	- ui -- ui should be first because it updates ui.CursorFocus which other modules might want to use the same frame!
	- task -- task should go second
	- tween -- tween should go after task so that a task could create a tween and that same tween can the be updated within the same frame
	- animation
	- world -- world goes last because it may use 

love.draw: (world)
	- world

love.resize: (camera, ui)
	- ui
	- camera -- camera goes after ui because the ui updates the position and size of elements and the camera might want to read those variables on resize!

love.mousemoved: (ui)
	- ui

love.mousepressed: (ui)
	- ui

love.mousereleased: (ui)
	- ui

love.wheelmoved: (ui)
	- ui

love.keypressed: (ui)
	- ui


]]