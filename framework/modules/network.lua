
local connection = require("framework.connection")

local network = {}
network.__index = network


local client = {}
client.__index = client


local server = {}
server.__index = server



local ActiveServers = {}
local serversCreated = 0


function network:startServer(ip, slots)
	assert(type(ip) == "string", "network:startServer(ip, slots) expects 'ip' to be of type 'string'.")
	assert(type(slots) == "number", "network:startServer(ip, slots) expects 'slots' to be of type 'number'.")
	assert(slots > 0, "network:startServer(ip, slots) expects 'slots' to be at least 1 or higher.")

	serversCreated = serversCreated + 1

	local Obj = {
		["Id"] = serversCreated;
		["OpenPorts"] = {};
		["ClientToName"] = {}; -- key = integer, value = string. Could have holes!
		["Events"] = {};
	}

	-- for each slot, create a thread that accepts one client on that slot/port and listens to information they send over, and sends them information back when needed
	for i = 1, slots do
		local slotThread = love.thread.newThread([=[
			local socket = require("socket")
			local ip, clientSlot = ...

			print("ip and client slot", ip, clientSlot)

			local serverSocket = socket.tcp()
			serverSocket:bind(ip, 0)
			serverSocket:listen(1)

			local _, port = serverSocket:getsockname()
			love.thread.getChannel("socket_port"):push(port)

			local client = serverSocket:accept()
			--client:settimeout(2)
			local username = client:receive("*l") -- the first thing a client always sends is their username!
			love.thread.getChannel("username" .. clientSlot):push(username)

			while true do
				-- check if you need to break out of the server loop
				local event = love.thread.getChannel("alive" .. tostring(port)):pop()
				if event ~= nil then
					love.thread.getChannel("alive" .. tostring(port)):release()
					break
				end

				-- keep receiving data from the client until there is no more data to read or too much data has been read temporarily
				serverSocket:settimeout(2)
				local readData = nil
				local counter = 0
				repeat
					counter = counter + 1
					readData, err = client:receive("*l")
					print(err)
				until readData == nil or counter >= 10

				if readData ~= nil then
					print("readData:", readData)
					for word in string.gmatch(readData, "([^|]+)") do -- split string on a 'pipe' character
					print(word)
						love.thread.getChannel("client_sent" .. clientSlot):push(word) -- push individual arguments into the queue
					end
					love.thread.getChannel("client_sent" .. clientSlot):push("|") -- signal the end of the data transmission from the client
				end

				-- send any server event data over to the client
				local sendData = nil
				repeat
					sendData = love.thread.getChannel("server_send" .. clientSlot):pop()
					if sendData ~= nil then
						client:send(sendData .. string.char(10))
					end
				until sendData == nil
				client:send(string.char(10)) -- send empty data to the client to inform them that no more data is being sent currently, to prevent them from yielding infinitely

			end

			love.thread.getChannel("username" .. clientSlot):pop() -- pop the username to indicate to the outside world that this client has disconnected from the given socket
			client:send("disconnect" .. string.char(10)) -- inform the client of the connection loss

			client:close()
		]=])

		-- run the server thread. A port is chosen automatically, which is stored in a channel. Fetch it from the channel to store it on this side
		local slot = tostring(i)
		slotThread:start(ip, slot)
		local port = love.thread.getChannel("socket_port"):demand()
		love.thread.getChannel("socket_port"):release()
		Obj.OpenPorts[i] = port
		
		-- spawn a task that awaits until a client has connected to the socket in the thread
		-- it keeps looping until the server goes offline, so even if a player disconnects it keeps going because a new player might join and fill in that spot
		local t
		t = task.spawn(
			function()
				-- while the player is connected on slot 'X', the usernameX channel will contain their username. One it's empty, the player disconnected
				local username = love.thread.getChannel("username" .. slot):peek()
				if username ~= nil then
					Obj.ClientToName[i] = username
				else
					Obj.ClientToName[i] = nil
					t:stop()
				end
				
			end,
			0, math.huge, 0
		)
	end

	setmetatable(Obj, server)
	table.insert(ActiveServers, Obj)
	return Obj
end


local totalConnectionsAttempted = 0
function network:connect(ip, port, username, callback)
	assert(type(ip) == "string", "network:connect(ip, port, username) expects 'ip' to be of type 'string'.")
	assert(type(port) == "number", "network:connect(ip, port, username) expects 'port' to be of type 'number'.")
	assert(type(username) == "string", "network:connect(ip, port, username) expects 'username' to be of type 'string'.")

	totalConnectionsAttempted = totalConnectionsAttempted + 1
	local curAttempt = totalConnectionsAttempted

	local Obj = {
		["Username"] = username;
		["Events"] = {};
	}

	local clientThread = love.thread.newThread([=[
		local socket = require("socket")
		local ip, port, username, totConAttempt = ...
		local client = socket.tcp()

		local success, err = client:connect(ip, port)
		print("connected:", success)
		if success == 1 then
			love.thread.getChannel("server_connect_status" .. tostring(totConAttempt)):push(true)
		else
			love.thread.getChannel("server_connect_status" .. tostring(totConAttempt)):push(err)
			return
		end

		client:setoption("tcp-nodelay", true)

		client:send(username)

		print("entering client while loop")

		while true do
			-- send any client event data over to the server
			local sendData = nil
			local disconnected = false
			repeat
				sendData = love.thread.getChannel("client_send"):pop()
				if sendData ~= nil then
					print("sendData:", sendData)
					client:send(sendData .. string.char(10))
					if sendData == "disconnect" then
						disconnected = true
					end
				end
			until sendData == nil or disconnected

			if disconnected then
				client:close()
				break
			else
				client:send(string.char(10))
			end

			
		end
	]=])

	local t
	t = task.spawn(
		function()
			local conStatus = love.thread.getChannel("server_connect_status" .. tostring(curAttempt)):pop()
			if conStatus ~= nil then
				callback(conStatus) -- either 'true' or a string with the error
				t:stop()
			end
			
		end,
		0, math.huge, 0
	)
	clientThread:start(ip, port, username, totalConnectionsAttempted)

	return setmetatable(Obj, client)
end




function server:on(eventName, func)
	if self.Events[eventName] == nil then
		self.Events[eventName] = {}
	end
	local index = #self.Events[eventName] + 1
	local Conn = connection.new(self, eventName)
	self.Events[eventName][index] = {func, Conn}
	return Conn
end



function server:close()
	-- remove self from ActiveServers
	for i = 1, #ActiveServers do
		if ActiveServers[i].Id == self.Id then
			table.remove(ActiveServers, i)
			break
		end
	end

	-- TODO: for any remaining clients that are connected to the server, inform them that the server is closed
	for i = 1, self.OpenPorts do
		love.thread.getChannel("alive" .. tostring(self.OpenPorts[i])):push(false) -- this will make the server threads close themselves and inform connected clients
	end
end



function server:getOpenPorts()
	local t = {}
	for i = 1, #self.OpenPorts do
		t[i] = self.OpenPorts[i]
	end
	return t
end



function server:nextOpenPort()
	return self.OpenPorts[1]
end



function server:broadcast(eventName, ...)
	assert(type(eventName) == "string", "server:broadcast(eventName, ...) expects 'eventName' to be a string.")
	assert(eventName:find("|") == nil, "server:broadcast(eventName, ...) expects 'eventName' to contain no '|' character.")
	local args = {...}
	local argsString = ""
	for i = 1, #args do
		assert(tostring(args[i]):find("|") == nil, "server:broacast(eventName, ...) expects all arguments to contain no '|' characters.")
		if i ~= #args then
			argsString = argsString .. tostring(args[i]) .. "|"
		else
			argsString = argsString .. tostring(args[i])
		end
	end

	for slot, username in pairs(self.ClientToName) do
		local argsChannel = "server_send" .. tostring(slot)
		love.thread.getChannel(argsChannel):push(argsString)
	end
	return true
end



function server:send(username, eventName, ...)
	assert(type(username) == "string", "server:send(username, eventName, ...) expects 'username' to be a string.")
	assert(type(eventName) == "string", "server:send(username, eventName, ...) expects 'eventName' to be a string.")
	assert(eventName:find("|") == nil, "server:send(username, eventName, ...) expects 'eventName' to contain no '|' characters.")
	local args = {...}
	local argsString = ""
	for i = 1, #args do
		assert(tostring(args[i]):find("|") == nil, "server:send(username, eventName, ...) expects all arguments to contain no '|' character.")
		if i ~= #args then
			argsString = argsString .. tostring(args[i]) .. "|"
		else
			argsString = argsString .. tostring(args[i])
		end
	end
	for slot, uname in pairs(self.ClientToName) do
		if uname == username then
			local argsChannel = "server_send" .. tostring(slot)
			love.thread.getChannel(argsChannel):push(argsString)
			return true
		end
	end
	return false
end




function client:on(eventName, func)
	if self.Events[eventName] == nil then
		self.Events[eventName] = {}
	end
	local index = #self.Events[eventName] + 1
	local Conn = connection.new(self, eventName)
	self.Events[eventName][index] = {func, Conn}
	return Conn
end



function client:send(eventName, ...)
	assert(type(eventName) == "string", "client:send(eventName, ...) expects 'eventName' to be a string.")
	assert(eventName ~= "disconnect", "client:send(\"disconnect\") is a reserved event and cannot be used.")
	assert(eventName:find("|") == nil, "client:send(eventName, ...) expects 'eventName' to contain no '|' characters.")
	local args = {...}
	local argsString = ""
	for i = 1, #args do
		assert(tostring(args[i]):find("|") == nil, "client:send(username, eventName, ...) expects all arguments to contain no '|' character.")
		if i ~= #args then
			argsString = argsString .. tostring(args[i]) .. "|"
		else
			argsString = argsString .. tostring(args[i])
		end
	end
	print(argsString)
	love.thread.getChannel("client_send"):push(argsString)
end



function client:disconnect()
	love.thread.getChannel("client_send"):push("disconnect")
end



-- monkey patching love.update() to process client events every frame
local oldUpdate = love.update or function() end

love.update = function(...)
	oldUpdate(...)

	for i = 1, #ActiveServers do
		-- look into the queue of event arguments of every individual client connected to that server
		for slot, username in pairs(ActiveServers[i].ClientToName) do
			-- empty the queue and call the server events
			local argsChannel = "client_sent" .. tostring(slot)
			while love.thread.getChannel(argsChannel):peek() ~= nil do -- there's something in the channel, time to read it until the end-of-event arguments is found
				local ended = false
				local item = nil
				local args = {}
				repeat
					item = love.thread.getChannel(argsChannel):pop()
					if item ~= nil then
						if item == "|" and #args > 1 then -- #args should always be at least 2, but just in case it's no issue in putting this here
							ended = true
							local eventName = table.remove(args, 1)
							connection.doEvents(ActiveServers[i].Events[eventName], username, unpack(args)) -- fire event on the server
							-- clear arguments to prepare it for the next event
							args = {}
						else
							args[#args + 1] = item
						end
					end
				until ended
			end

		end
	end
end





return network

