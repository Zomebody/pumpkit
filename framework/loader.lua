

function load()
	filepath = require("framework.filepath")
	connection = require("framework.connection")

	vector2 = require(filepath("../framework/datatypes/vector2", "."))
	vector3 = require(filepath("../framework/datatypes/vector3", "."))
	vector4 = require(filepath("../framework/datatypes/vector4", "."))
	matrix3 = require(filepath("../framework/datatypes/matrix3", "."))
	matrix4 = require(filepath("../framework/datatypes/matrix4", "."))
	quaternion = require(filepath("../framework/datatypes/quaternion", "."))
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
	floodmap = require(filepath("../framework/modules/floodmap", "."))
	
	-- weird stuff
	tween = require(filepath("../framework/modules/tween", "."))
	animation = require(filepath("../framework/modules/animation", "."))
	font = require(filepath("../framework/modules/font", "."))
	signal = require(filepath("../framework/modules/signal", "."))
	callbacks = require(filepath("../framework/modules/callbacks", "."))
	printObject = require(filepath("../framework/objectPrinter", "."))
	ui = require(filepath("../framework/modules/ui", "."))

	-- importers
	--importMesh = require(filepath("../framework/meshimporter", "."))
	importMesh = require(filepath("../framework/meshimporter2", "."))
	importNavmesh = require(filepath("../framework/navimporter", "."))
	importCollision = require(filepath("../framework/colimporter", "."))

	-- world stuff
	world = require(filepath("../framework/modules/world", "."))
	scene = require(filepath("../framework/modules/scene", "."))
	scene3 = require(filepath("../framework/modules/scene3", "."))
	camera = require(filepath("../framework/modules/camera", "."))
	camera3 = require(filepath("../framework/modules/camera3", "."))
	mesh3 = require(filepath("../framework/modules/mesh3", "."))
	spritemesh3 = require(filepath("../framework/modules/spritemesh3", "."))
	ripplemesh3 = require(filepath("../framework/modules/ripplemesh3", "."))
	mesh3group = require(filepath("../framework/modules/mesh3group", "."))
	trip3 = require(filepath("../framework/modules/trip3", "."))
	trip3group = require(filepath("../framework/modules/trip3group", "."))
	foliage3 = require(filepath("../framework/modules/foliage3", "."))
	plant3 = require(filepath("../framework/modules/plant3", "."))
	blob3 = require(filepath("../framework/modules/blob3", "."))
	light3 = require(filepath("../framework/modules/light3", "."))
	entity = require(filepath("../framework/modules/entity", "."))
	particles3 = require(filepath("../framework/modules/particles3", "."))
	trail3 = require(filepath("../framework/modules/trail3", "."))
	network = require(filepath("../framework/modules/network", "."))

	-- profiling
	profiler = require(filepath("./profiler", "."))

	-- fix cull-mode being the opposite
	love.graphics.setFrontFaceWinding("cw")

	-- initialization
	callbacks:initialize() -- monkey patches all callbacks except for update, draw, errhand, errorhandler, load
	
	local update_ui, mousepressed_ui, mousemoved_ui, mousereleased_ui, wheelmoved_ui, keypressed_ui, resize_ui = ui:initialize()
	local textblock = require(filepath("../framework/modules/textblock", "."))
	local update_textblock = textblock:initialize()
	local update_task = task:initialize()
	local update_tween = tween:initialize()
	local update_animation = animation:initialize()
	local resize_camera = camera:initialize()
	
	local update = love.update or function() end
	love.update = function(...)
		profiler:pushLabel("update")
		profiler:pushLabel("update-standard")
		update(...)
		profiler:popLabel()
		profiler:pushLabel("update-ui")
		update_ui(...)
		profiler:popLabel()

		profiler:pushLabel("update-textblock")
		update_textblock(...)
		profiler:popLabel()

		-- since the :update() method is returned in task, tween, animation, pass them as the first argument so that 'self' can be indexed
		profiler:pushLabel("update-task")
		update_task(task, ...) -- task after UI because it might want to access the latest ui.CursorFocus
		profiler:popLabel()
		profiler:pushLabel("update-tween")
		update_tween(tween, ...) -- tween after task because if a task creates and runs a tween you want to update the tween asap
		profiler:popLabel()
		profiler:pushLabel("update-animation")
		update_animation(animation, ...)
		profiler:popLabel()
		profiler:popLabel()
	end

	local resize = love.resize or function() end
	love.resize = function(...)
		profiler:pushLabel("resize")
		profiler:pushLabel("resize-standard")
		resize(...)
		profiler:popLabel()
		profiler:pushLabel("resize-ui")
		resize_ui(...)
		profiler:popLabel()
		profiler:pushLabel("resize-camera")
		resize_camera(...)
		profiler:popLabel()
		profiler:popLabel()
	end

	local mousepressed = love.mousepressed or function() end
	love.mousepressed = function(...)
		profiler:pushLabel("mousepressed")
		profiler:pushLabel("pressed-standard")
		mousepressed(...)
		profiler:popLabel()
		profiler:pushLabel("pressed-ui")
		mousepressed_ui(...)
		profiler:popLabel()
		profiler:popLabel()
	end

	local mousemoved = love.mousemoved or function() end
	love.mousemoved = function(...)
		profiler:pushLabel("mousemoved")
		profiler:pushLabel("moved-standard")
		mousemoved(...)
		profiler:popLabel()
		profiler:pushLabel("moved-ui")
		mousemoved_ui(...)
		profiler:popLabel()
		profiler:popLabel()
	end

	local mousereleased = love.mousereleased or function() end
	love.mousereleased = function(...)
		profiler:pushLabel("mousereleased")
		profiler:pushLabel("release-standard")
		mousereleased(...)
		profiler:popLabel()
		profiler:pushLabel("release-ui")
		mousereleased_ui(...)
		profiler:popLabel()
		profiler:popLabel()
	end

	local wheelmoved = love.wheelmoved or function() end
	love.wheelmoved = function(...)
		profiler:pushLabel("wheelmoved")
		profiler:pushLabel("wheel-standard")
		wheelmoved(...)
		profiler:popLabel()
		profiler:pushLabel("wheel-ui")
		wheelmoved_ui(...)
		profiler:popLabel()
		profiler:popLabel()
	end

	local keypressed = love.keypressed or function() end
	love.keypressed = function(...)
		profiler:pushLabel("keypressed")
		profiler:pushLabel("key-standard")
		keypressed(...)
		profiler:popLabel()
		profiler:pushLabel("key-ui")
		keypressed_ui(...)
		profiler:popLabel()
		profiler:popLabel()
	end

	local draw = love.draw or function() end
	love.draw = function(...)
		profiler:pushLabel("draw")
		draw(...)
		profiler:popLabel()
		profiler:finishFrame()
	end
	


end

return load


--[[

order in which the following Love2D callbacks are being used by the modules:

love.update:
	- ui -- ui should be first because it updates ui.CursorFocus which other modules might want to use the same frame!
	- task -- task should go second
	- tween -- tween should go after task so that a task could create a tween and that same tween can the be updated within the same frame
	- animation

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