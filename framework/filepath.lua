

function filepath(relativePath, separator)
	if relativePath:sub(1, 1) == "/" then -- path is an absolute path
		return relativePath
	end

	if separator == nil then
		separator = "/"
	end

	-- helpful docs: https://www.gammon.com.au/scripts/doc.php?lua=debug.getinfo
	local info = debug.getinfo(2, "S") -- 2 means 'item 2' on the stack (0 = getinfo, 1 = this function, 2 = the one calling this), "S" = source
	-- the path to the file that called this function
	local pathToFile = info.source:match("^@(.*)$") -- remove the 'at' at the start
	if not pathToFile then
		error("function filepath failed for unknown reason.")
	end

	local pathToDirectory = pathToFile:match("(.*/)") or "./"
	local longPath = pathToDirectory .. relativePath -- path to the directory and then potentially back up again to the file

	-- post-processing on longPath to cut out any 'going up' in the directories
	local segments = {} -- each folder, concatenated later
	for segment in longPath:gmatch("[^/]+") do -- match the words between slashes
		if segment == ".." then
			if #segments > 0 then
				table.remove(segments, #segments)
			end
		elseif segment ~= "." then -- ignore 'current directory'
			table.insert(segments, segment)
		end
	end


	-- concatenate the segments into a full path and return it
	return table.concat(segments, separator)
end


return filepath


