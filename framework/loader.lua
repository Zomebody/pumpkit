
local locale = ...

function load()
	getpath = require("framework.getpath");
	vector = require(getpath(locale, "../framework/datatypes/vector"))
	line = require(getpath(locale, "../framework/datatypes/line"))
	polygon = require(getpath(locale, "../framework/datatypes/polygon"))
	color = require(getpath(locale, "../framework/datatypes/color"))
	task = require(getpath(locale, "../framework/modules/task"))
	tween = require(getpath(locale, "../framework/modules/tween"))
	animation = require(getpath(locale, "../framework/modules/animation"))
	font = require(getpath(locale, "../framework/modules/font"))
	printObject = require(getpath(locale, "../framework/objectPrinter"))
	ui = require(getpath(locale, "../framework/modules/ui"))
end

return load