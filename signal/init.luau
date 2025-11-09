--!strict
local event = require('@self/event')
local funct = require('@self/function')

export type event<T...> = event.event<T...>
export type funct<T..., B...> = funct.funct<T..., B...>

return {
	event = event,
	funct = funct
}