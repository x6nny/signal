# ⚡ Signal Module

A lightweight and **type-safe signal system** for Roblox, built in Luau with `--!strict` type checking.
This module provides two powerful abstractions:

* **`event`** – an advanced, customizable event emitter (like `BindableEvent`, but more flexible).
* **`funct`** – a callable function wrapper (similar to `BindableFunction`).

Perfect for communication between systems in a clean, decoupled way.

---

## 📦 Module Structure

```
Signal
├── event.lua   # Event system (Connect, Once, Wait, etc.)
├── function.lua # Function wrapper (Invoke-style callable)
└── init.lua     # Exports both event and funct
```

---

## 🚀 Installation

1. Grab the rbxm from the releases page and drag and drop it into studio
2. Require it in your scripts:

   ```lua
   local Signal = require(path.to.Signal)
   local Event = Signal.event
   local Funct = Signal.funct
   ```

---

## 🧩 Usage Examples

### 🟢 Events

```lua
local Event = Signal.event()

-- Connect to the event
local disconnect = Event:Connect(function(message)
	print("Received:", message)
end)

-- Fire the event
Event:Fire("Hello, world!")

-- Disconnect listener
disconnect()

-- Wait for next fire
task.spawn(function()
	print("Waited for:", Event:Wait())
end)

-- Fire again
Event:Fire("Hi again!")
```

### 🔵 Function Wrappers

```lua
local Add = Signal.funct(function(a: number, b: number): number
	return a + b
end)

-- Invoke normally
print(Add:Invoke(2, 3)) -- 5

-- Or call directly (thanks to __call)
print(Add(10, 20)) -- 30
```

---

## 🧠 Event API Reference

### `event() → Event<T...>`

Creates a new event instance.

---

### **Methods**

| Method                                  | Description                                                                    |
| --------------------------------------- | ------------------------------------------------------------------------------ |
| `Event:Connect(callback)`               | Connects a listener; returns a disconnect function.                            |
| `Event:Once(callback)`                  | Connects a listener that runs once, then disconnects automatically.            |
| `Event:Fire(...args)`                   | Fires the event and calls all listeners with `...args`.                        |
| `Event:Wait()`                          | Yields the current thread until the event is fired; returns fired arguments.   |
| `Event:WaitUntil(timeout: number?)`     | Waits until fired or timeout expires.                                          |
| `Event:Enable(enabled: boolean)`        | Enables or disables firing.                                                    |
| `Event:Limit(amount: number, callback)` | Connects a listener that will be called only a fixed number of times.          |
| `Event:Eval(evaluator, callback)`       | Connects a listener that triggers callback only when evaluator returns `true`. |
| `Event:SetThrottle(seconds)`            | Limits how often the event can fire (rate limiting).                           |
| `Event:RemoveThrottle()`                | Removes any throttle applied.                                                  |
| `Event:Delay(time, callback)`           | Calls the callback after a delay when the event fires.                         |
| `Event:DisconnectAll()`                 | Removes all connected listeners.                                               |

---

### **Example: Using `Eval` and `Limit`**

```lua
-- Only triggers when condition passes
local event = Signal.event()

event:Eval(function(n)
	return n > 5
end, function(n)
	print("Only fires for numbers > 5:", n)
end)

event:Fire(3)  -- ignored
event:Fire(10) -- printed
```

```lua
-- Fires exactly 3 times, then disconnects
event:Limit(3, function(msg)
	print("Limited:", msg)
end)

event:Fire("one")
event:Fire("two")
event:Fire("three")
event:Fire("four") -- ignored
```

---

## ⚙️ Function API Reference

### `funct(OnInvoke: (T...) -> B...) → Funct<T..., B...>`

Creates a new function-like object with an `OnInvoke` callback.

---

### **Methods**

| Method                  | Description                                                  |
| ----------------------- | ------------------------------------------------------------ |
| `Funct:Invoke(...args)` | Invokes the `OnInvoke` callback with the provided arguments. |
| `Funct(...args)`        | Shortcut for `Funct:Invoke(...)`.                            |

---

### **Example:**

```lua
local Multiply = Signal.funct(function(a: number, b: number): number
	return a * b
end)

print(Multiply(4, 5))  --> 20
```

---

## 🧾 Type Definitions

```lua
type event<T...> = {
	Connect: (self, (T...) -> ()) -> (() -> ()),
	Once: (self, (T...) -> ()) -> (),
	Wait: (self) -> T...,
	Fire: (self, ...any) -> (),
	DisconnectAll: (self) -> (),
}
```

```lua
type funct<T..., B...> = {
	OnInvoke: (T...) -> B...,
	Invoke: (self, T...) -> B...,
}
```

---

## 🧰 Design Notes

* Written with **`--!strict`** typing for better Luau type inference.
* Inspired by **`BindableEvent`** and **`BindableFunction`**, but more flexible and lightweight.
* Functions and events are both **callable** (using metatables `__call`).

---

## 📜 License

MIT License © 2025 — You’re free to use, modify, and distribute.
