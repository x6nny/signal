--!strict
local funct = {}
funct.__index = funct

--> types
export type funct<T..., B...> = {
	OnInvoke : (T...) -> B...,
	Invoke : (funct<T..., B...>, T...) -> B...,
}

--> methods
function funct:Invoke<T..., B...>(... : T...) : B...
	return self.OnInvoke(...)
end


funct.__call = function(self, ...)
	return self:Invoke(...)
end

--> return
return function<T..., B...>(OnInvoke : (T...) -> B...) : funct<T..., B...>
	return setmetatable({
		OnInvoke = OnInvoke
	}, funct) :: any
end