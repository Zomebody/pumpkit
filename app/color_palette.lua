
local getpath = require("framework.getpath")
local color = require(getpath("", "framework.datatypes.color"))

local Colors = {
	["BackgroundDark"] = color.fromHex("#141d24");
	["BackgroundSemiDark"] = color.fromHex("#202c36");
	["Background"] = color.fromHex("#273540");
	["BackgroundLight"] = color.fromHex("#323f4a");
	["Border"] = color.fromHex("#1d2933");
	["TextWhite"] = color(1, 1, 1, 1);
	["TextPrimary"] = color.fromHex("#c1c6c9");
	["TextAlternative"] = color.fromHex("#8a7ccf");
	["TextComment"] = color.fromHex("#ffba52");
	["TextTableHeader"] = color.fromHex("#f5cc51");
	["Transparent"] = color(0, 0, 0, 0);
	["ButtonHover"] = color(0, 0, 0, 0.24);
	["ButtonHold"] = color(0, 0, 0, 0.55);
	["MonokaiNumber"] = color.fromRGB(174, 129, 255);
	["MonokaiBoolean"] = color.fromRGB(174, 129, 255);
	["MonokaiString"] = color.fromRGB(230, 219, 90);
	["MonokaiText"] = color.fromRGB(248, 248, 242);
	["MonokaiFunction"] = color.fromRGB(102, 217, 239);
	["MonokaiComment"] = color.fromRGB(121, 121, 121);
	["MonokaiArgument"] = color.fromRGB(253, 151, 31);
	["MonokaiKeyword"] = color.fromRGB(249, 38, 114);
}

return Colors

