--[[@
	@name on
	@desc Sets an event emitter that is triggered everytime a specific behavior happens.
	@desc See the available events in @see Events.
	@param eventName<string> The name of the event.
	@param callback<function> The function that must be called when the event is triggered.
]]
Client.on = function(self, eventName, callback)
	return self.event:on(eventName, coroutine_makef(callback))
end
--[[@
	@name once
	@desc Sets an event emitter that is triggered only once a specific behavior happens.
	@desc See the available events in @see Events.
	@param eventName<string> The name of the event.
	@param callback<function> The function that must be called only once when the event is triggered.
]]
Client.once = function(self, eventName, callback)
	return self.event:once(eventName, coroutine_makef(callback))
end
--[[@
	@name waitFor
	@desc Yields the running coroutine and will resume it when the given event is triggered.
	@desc If a timeout (in milliseconds) is provided, the function will return after that timeout expires unless the given event has been triggered before.
	@desc If a predicate is provided, events that do not pass the predicate will be ignored.
	@desc See the available events in @see Events.
	@param eventName<string> The name of the event.
	@param timeout?<int> The time to timeout the yield.
	@param predicate?<function> The predicate that checks whether the triggered event refers to the right one. Must return a boolean.
	@returns boolean Whether it has not timed out and triggered successfully.
	@returns ... The parameters of the event.
]]
Client.waitFor = function(self, eventName, timeout, predicate)
	return self.event:waitFor(eventName, timeout, predicate)
end
--[[@
	@name emit
	@desc Emits an event.
	@desc See the available events in @see Events. You can also create your own events / emitters.
	@param eventName<string> The name of the event.
	@param ...?<*> The parameters to be passed during the emitter call.
]]
Client.emit = function(self, eventName, ...)
	return self.event:emit(eventName, ...)
end
