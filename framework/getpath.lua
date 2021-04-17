
-- selfPath is the absolute file location of the file calling this function
-- relativeChange is a string in the form, e.g. "../../folder2/newfile"
-- you can also call getPath("absolute/file/path") and it will be converted to lua require notation: "absolute.file.path"
local getPath
getPath = function(selfPath, relativeChange)
	if relativeChange == nil then
		return getPath("", selfPath)
	end
	local curPath = ""
	if string.find(selfPath, "%.") ~= nil then -- if no dot is found, it means you're in the top level directory, so the current path would be an empty string
		curPath = selfPath:gsub("%.[^%.]+$", "") -- remove the last word, plus the last dot (so get the current folder you're in)
	end
	for word in string.gmatch(relativeChange, "[^/^\\]+") do
		if word == ".." then
			if string.find(curPath, "%.") ~= nil then -- if no dot is found, it means you're in the top level directory, so the current path would be an empty string
				curPath = curPath:gsub("%.[^%.]+$", "") -- move up a folder
			else
				curPath = ""
			end
		else
			curPath = curPath .. "." .. word -- move down a folder
		end
	end
	if curPath:sub(1, 1) == "." then
		curPath = curPath:sub(2)
	end
	return curPath
end

return getPath
