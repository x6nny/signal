--!strict
local event = {}
event.__index = event

--> types
export type event<T...> = {
	enable : (event<T...>, enabled : boolean) -> (),
	Limit : (event<T...>, amount : number, callBack : (T...) -> ()) -> () -> (),
	Connect : (event<T...>, funct : (T...) -> ()) -> () -> (),
	Once : (event<T...>, funct : (T...) -> ()) -> (),
	Wait : (event<T...>) -> T...,
	WaitUntil : (event<T...>, TimeOut : number?) -> T...,
	Eval : (event<T...>, evaluator : (T...) -> boolean, callBack : (T...) -> ()) -> () -> (),
	SetThrottle : (event<T...>, Time : number) -> (),
	RemoveThrottle : (event<T...>) -> (),
	Delay : (event<T...>, Time : number, callBack : (T...) -> ()) -> () -> (),
	
	Fire : (event<T...>, ...any) -> (),
	DisconnectAll : (event<T...>) -> (),
}

--> methods
function event:enable(enabled : boolean)
	self.enabled = enabled
end

function event:Limit<T...>(amount : number, callBack : (T...) -> ())
	local times = 0
	local conn = nil
	
	conn = self:Connect(function(...)
		times += 1
		callBack(...)
		
		if times >= amount then
			conn()
			conn = nil :: any
		end
	end)
	
	return function()
		if conn ~= nil then
			conn()
			conn = nil :: any
		end
	end
end

function event:Eval<T...>(evaluator : (T...) -> boolean, callBack : (T...) -> ())
	local conn = nil
	
	conn = self:Connect(function(...)
		local result = evaluator(...)
		if typeof(result) == 'boolean' and result == true then
			callBack(...)
		end
	end)
	
	return function()
		if conn ~= nil then
			conn()
			conn = nil :: any
		end
	end
end

function event:Connect<T...>(funct : (T...) -> ())
	table.insert(self.connections, funct)
	
	return function()
		local index = table.find(self.connections, funct)
		if index then
			table.remove(self.connections, index)
		end
	end
end

function event:Once<T...>(funct : (T...) -> ())
	local connection
	connection = self:Connect(function(...)
		connection()
		funct(...)
	end)
	
	return connection
end

function event:Wait<T...>() : T...
	local running = coroutine.running()

	self:Once(function(...)
		coroutine.resume(running, ...)
	end)

	return coroutine.yield(running)
end

function event:WaitUntil<T...>(TimeOut : number?)
	local t = coroutine.running()
	
	local timeOut = TimeOut or 60
	
	local connection
	connection = self:Once(function(...)
		connection()
		connection = nil :: any
		
		task.spawn(t, ...)	
	end)

	task.delay(timeOut, function()
		if not connection then
			return
		end
		connection()
		coroutine.resume(t)
	end)

	return coroutine.yield()
end

function event:Delay<T...>(Time : number, callBack : (T...) -> ())
	local conn
	local threads = {}
	
	conn = self:Connect(function(...)
		table.insert(threads, task.delay(Time, callBack, ...))
	end)
	
	return function()
		if conn ~= nil then
			conn()
			conn = nil :: any
		end
		for _, v in threads do
			task.cancel(v)
		end
		threads = nil :: any
	end
end

function event:Fire<T...>(... : T...)
	if self.enabled == false then return end
	
	if self.throttle ~= nil then
		if self.lastTime ~= nil and os.clock() - self.lastTime < self.throttle then
			return
		end
	end
	
	self.lastTime = os.clock()
	
	for i = 1, #self.connections do
		local conn = self.connections[i]
		conn(...)
	end
end

function event:SetThrottle(Time : number)
	self.throttle = Time
end

function event:RemoveThrottle()
	self.throttle = nil
end

function event:DisconnectAll()
	self.connections = {}
end

event.__call = function(self, ...)
	self:Fire(...)
end

--> return
return function<T...>() : event<T...>
	return setmetatable({
		connections = {},
		enabled = true,
		throttle = nil,
		lastTime = nil,
	}, event) :: any
end