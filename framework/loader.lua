

function load()
	filepath = require("framework.filepath")

	vector2 = require(filepath("../framework/datatypes/vector2", "."))
	vector3 = require(filepath("../framework/datatypes/vector3", "."))
	vector4 = require(filepath("../framework/datatypes/vector4", "."))
	matrix3 = require(filepath("../framework/datatypes/matrix3", "."))
	matrix4 = require(filepath("../framework/datatypes/matrix4", "."))
	line2 = require(filepath("../framework/datatypes/line2", "."))
	line3 = require(filepath("../framework/datatypes/line3", "."))
	polygon = require(filepath("../framework/datatypes/polygon", "."))
	triangle = require(filepath("../framework/datatypes/triangle", "."))
	bezier = require(filepath("../framework/datatypes/bezier", "."))
	color = require(filepath("../framework/datatypes/color", "."))
	gradient = require(filepath("../framework/datatypes/gradient", "."))
	numbercurve = require(filepath("../framework/datatypes/numbercurve", "."))
	range = require(filepath("../framework/datatypes/range", "."))
	task = require(filepath("../framework/modules/task", "."))

	-- data structures
	quadtree = require(filepath("../framework/modules/quadtree", "."))
	navmesh = require(filepath("../framework/modules/navmesh", "."))

	-- weird stuff
	tween = require(filepath("../framework/modules/tween", "."))
	animation = require(filepath("../framework/modules/animation", "."))
	font = require(filepath("../framework/modules/font", "."))
	signal = require(filepath("../framework/modules/signal", "."))
	callbacks = require(filepath("../framework/modules/callbacks", "."))
	printObject = require(filepath("../framework/objectPrinter", "."))
	importMesh = require(filepath("../framework/meshimporter", "."))
	ui = require(filepath("../framework/modules/ui", "."))

	-- world stuff
	world = require(filepath("../framework/modules/world", "."))
	scene = require(filepath("../framework/modules/scene", "."))
	scene3 = require(filepath("../framework/modules/scene3", "."))
	camera = require(filepath("../framework/modules/camera", "."))
	camera3 = require(filepath("../framework/modules/camera3", "."))
	entity = require(filepath("../framework/modules/entity", "."))
	particles3 = require(filepath("../framework/modules/particles3", "."))
	network = require(filepath("../framework/modules/network", "."))

	-- initialization
	callbacks:initialize()
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

love.update:
	- ui -- ui should be first because it updates ui.CursorFocus which other modules might want to use the same frame!
	- task -- task should go second
	- tween -- tween should go after task so that a task could create a tween and that same tween can the be updated within the same frame
	- animation
	- world -- world goes last because it may use... (I forgot)

love.draw:
	- world

love.resize:
	- callbacks
	- ui
	- camera -- camera goes after ui because the ui updates the position and size of elements and the camera might want to read those variables on resize!

love.mousemoved:
	- callbacks
	- ui

love.mousepressed:
	- callbacks
	- ui

love.mousereleased:
	- callbacks
	- ui

love.wheelmoved:
	- callbacks
	- ui

love.keypressed:
	- callbacks
	- ui


]]