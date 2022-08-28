# API

> Implementation Notes:
>
> 1. The indexes of the Joysticks are zero-based (like C) and the same goes for the index of the buttons and the axes.
>
> 2. It is preferred to call `lovr.joystick.setCallback(callback_func)` in `lovr.load` when it's needed while there is no problem with being the callback function outside of `lovr.load`
>
> 3. If no error occurs, Then the `error_code` is zero and `error_message` is set to `nil`
>
> 4. For the user-defined pointers, The initial value is `nil`

### `lovr.joystick.errors`

Contains the list of numeric codes for errors that might occur when calling one of the Joystick functions.

```lua
-- No error has occurred.
lovr.joystick.errors.NONE = 0

-- The function was called that must not be called unless GLFW is initialized.
lovr.joystick.errors.GLFW_UNINITIALIZED = 0x00010001

-- The index for the Joystick/Gamepad or for the button is invalid.
lovr.joystick.errors.INVALID_INDEX = 0x00010003
 
-- One of the arguments passed to the function was an invalid value.
lovr.joystick.errors.INVALID_VALUE = 0x00010004

-- platform-specific error occurred.
lovr.joystick.errors.PLATFORM_SPECIFIC = 0x00010008
```

### `lovr.joystick.events`

Contains the list of the Joystick events that can be used with `lovr.joystick.setCallback`'s callback function.

```lua
--- Joystick is connected.
lovr.joystick.events.CONNECTED = 0x00040001

--- Joystick is disconnected.
lovr.joystick.events.DISCONNECTED = 0x00040002
```

### `lovr.joystick.buttons`

Contains the list of the indexes of the Joystick/Gamepad buttons.

```lua
lovr.joystick.buttons.A = 0
lovr.joystick.buttons.B = 1
lovr.joystick.buttons.X = 2
lovr.joystick.buttons.Y = 3
lovr.joystick.buttons.LB = 4
lovr.joystick.buttons.RB = 5
lovr.joystick.buttons.BACK = 6
lovr.joystick.buttons.START = 7
lovr.joystick.buttons.GUIDE = 8
lovr.joystick.buttons.LT = 9
lovr.joystick.buttons.RT = 10
lovr.joystick.buttons.UP = 11
lovr.joystick.buttons.RIGHT = 12
lovr.joystick.buttons.DOWN = 13
lovr.joystick.buttons.LEFT = 14

-- Aliases to comform with Sony PlayStation
lovr.joystick.buttons.CROSS = lovr.joystick.buttons.A
lovr.joystick.buttons.CIRCLE = lovr.joystick.buttons.B
lovr.joystick.buttons.SQUARE = lovr.joystick.buttons.X
lovr.joystick.buttons.TRIANGLE = lovr.joystick.buttons.Y

-- GLFW thingy
joystick.buttons.LAST = joystick.buttons.LEFT
```

### `lovr.joystick.axes`

Contains the list of the indexes of the Joystick/Gamepad axes.

```lua
lovr.joystick.axes.LEFT_X = 0
lovr.joystick.axes.LEFT_Y = 1
lovr.joystick.axes.RIGHT_X = 2
lovr.joystick.axes.RIGHT_Y = 3
lovr.joystick.axes.LT = 4
lovr.joystick.axes.RT = 5

-- GLFW thingy
lovr.joystick.axes.LAST = lovr.joystick.axes.RT
```

### `lovr.joystick.hat_states`

Contains the list of the states for the Joystick hats.

```lua
lovr.joystick.hat_states.CENTERED = 0
lovr.joystick.hat_states.UP = 1
lovr.joystick.hat_states.RIGHT = 2
lovr.joystick.hat_states.DOWN = 4
lovr.joystick.hat_states.LEFT = 8
lovr.joystick.hat_states.RIGHT_UP = 3
lovr.joystick.hat_states.RIGHT_DOWN = 6
lovr.joystick.hat_states.LEFT_UP = 9
lovr.joystick.hat_states.LEFT_DOWN = 12
```

### `lovr.joystick.isAvailable(idx)`

Returns `true` if the Joystick at index `idx` is available or `false` if not, Along with error's code and message if occurred.

```lua
local joystick_present, error_code, error_message = lovr.joystick.isAvailable(0)

if joystick_present then
  -- The first Joystick is available
end
```

### `lovr.joystick.hasGamepadMappings(idx)`

Returns `true` if the Joystick at index `idx` has gamepad mappings or `false` if not, Along with error's code and message if occurred.

```lua
local gamepad, error_code, error_message = lovr.joystick.hasGamepadMappings(0)

if gamepad then
  -- The first Joystick has gamepad mappings.
end
```

> NOTE: also this function can be used to check if the Joystick is Gamepad.

### `lovr.joystick.getName(idx)`

Retrieves the name of the Joystick at index `idx` as string, Along with error's code and message if occurred.

```lua
local name, error_code, error_message = lovr.joystick.getName(0)

-- Prints the name of the first Joystick, Or prints the error message if error has occurred.
print((name ~= nil) and name or error_message)
```

> NOTE: if the Joystick has gamepad mappings, Then the gamepad name is returned instead.

### `lovr.joystick.getGUID(idx)`

Retrieves the SDL-compatible GUID of the Joystick at index `idx` as string, Along with error's code and message if occurred.

```lua
local guid, error_code, error_message = lovr.joystick.getGUID(0)

-- Prints the SDL-compatible GUID of the first Joystick, Or prints the error message if error has occurred.
print((guid ~= nil) and guid or error_message)
```

### `lovr.joystick.getButtons(idx)`

Retrieves state of the buttons and their count for Joystick at index `idx`, Along with error's code and message if occurred.

```lua
-- Get the state and count of buttons for the first Joystick.
local buttons, buttons_count, error_code, error_message = lovr.joystick.getButtons(0)

if ((buttons ~= nil) and (buttons[lovr.joystick.buttons.X] == 1)) then
  -- Do something if X button is down.
end
```

### `lovr.joystick.isButtonDown(idx, btn)`

Returns `true` if button `btn` in the Joystick at index `idx` is down or `false` if not, Along with error's code and message if occurred.

The button `btn` can be the key or the value from one of `lovr.joystick.buttons`

```lua
if lovr.joystick.isButtonDown(0, "X") then
  -- Button X/Square pressed in the first Joystick.
end

if lovr.joystick.isButtonDown(0, lovr.joystick.buttons.A) then
  -- Button A/Cross pressed in the first Joystick.
end
```

### `lovr.joystick.getAxes(idx)`

Retrieves the values of the axes and the total number of axis for the Joystick at index `idx`, Along with error's code and message if occurred.

```lua
-- Retrieve the values of axes for the first Joystick.
local axes, axis_count, error_code, error_message = lovr.joystick.getAxes(0)

if (axes ~= nil) then
  -- Print the value of left X axis for the first Joystick.
  print(axes[lovr.joystick.axes.LEFT_X])
end
```

> NOTE: if the Joystick has gamepad mappings, Then the state of the gamepad axes is returned instead.

### `lovr.joystick.getAxisValue(idx, axis)`

Retrieves the value of the specified axis from the Joystick at index `idx`, Along with error's code and message if occurred.

The axis can be the key or the value from one of `lovr.joystick.axes`

```lua
-- Prints the value of the left X axis from the first Joystick.
print(lovr.joystick.getAxisValue(0, "LEFT_X"))

-- Prints the value of the right X axis from the first Joystick.
print(lovr.joystick.getAxisValue(0, lovr.joystick.axes.RIGHT_X))
```

### `lovr.joystick.getHats(idx)`

Retrieves the hats and total hats count for the Joystick at index `idx`, Returns them along with error's code and message if occurred.

```lua
-- Shortand xD
local UP = lovr.joystick.hat_states.UP

-- Retrieve the state of the hats for the first Joystick.
local hats, hats_count, error_code, error_message = lovr.joystick.getHats(0)

if ((hats ~= nil) and (bit.band(hats[0], UP) == UP)) then
  -- The state of the first hat from the first Joystick could be Up, Up-Left, or Up-Right.
end
```

### `lovr.joystick.updateGamepadMappings(mappings)`

Parses the specified ASCII encoded string and updates the internal list with any gamepad mappings it finds.

If there is already a gamepad mapping for a given GUID in the internal list, it will be replaced by the one passed to this function. If the library is terminated and re-initialized the internal list will revert to the built-in default.

The gamepad mappings string `mappings` may contain either a single gamepad mapping or many mappings separated by newlines, The parser supports the full format of the `gamecontrollerdb.txt` source file including empty lines and comments.

Returns `true` if updating process was successful or `false` if not, Along with error's code and message if occurred.

```lua
-- Try to open "gamecontrollerdb.txt" for reading.
local f = io.open("./gamecontrollerdb.txt")

-- If failed then error, Else keep going...
if not f then
  error("failed to read gamecontrollerdb.txt to update gamepad mappings!", 2)
else
  -- Read all contents of "gamecontrollerdb.txt" update gamepad mappings with it.
  local mappings = f:read("*a")
  local success, error_code, error_message = lovr.joystick.updateGamepadMappings(mappings)
  
  -- If failed to update gamepad mappings then error, Else close the file handle.
  if not success then
    error(error_message, 2)
  end
  
  f:close()
end
```

### `lovr.joystick.setCallback(callback_func)`

Sets the Joystick configuration callback or removes the currently set callback, Called when a Joystick is connected to or disconnected from the system.

for Joystick connection and disconnection events to be delivered on all platforms, you need to call one of the event processing functions.

Joystick disconnection may also be detected and the callback called by Joystick functions, The function will then return whatever it returns if the Joystick is not present.

`nil` can be passed to `callback_func` to remove the currently set callback.

Returns the previous callback set if exist or `nil`, Along with error's code and message if occurred.

The callback function `callback_func` takes the following form:

```lua
local function joystick_callback(joystick_index, joystick_event)
  -- joystick_index: The index of the Joystick (from 0 to 15)
  -- joystick_event: One of events from lovr.joystick.events (CONNECTED or DISCONNECTED)
end
```

Example:

```lua
local function joystick_callback(joystick_index, joystick_event)
  if (joystick_event == lovr.joystick.events.DISCONNECTED) then
    print("Joystick " .. (joystick_index + 1) .. " is disconnected!")
  end
end

local prev_callback, error_code, error_message = lovr.joystick.setCallback(joystick_callback)

if (error_code ~= 0) then
  error(error_message, 2)
end
```

### `lovr.joystick.getUserPointer(idx)`

Returns the current value of the user-defined pointer of the Joystick at index `idx`, Along with error's code and message if occurred.

This function may be called from the Joystick callback even for a disconnected Joystick.

```lua
-- Retrieve the user-defined pointer for the first Joystick.
local ptr, error_code, error_message = joystick.getUserPointer(0)
```

### `lovr.joystick.setUserPointer(idx, ptr)`

Sets the current value of the user-defined pointer of the Joystick at index `idx`, The current value is retained until the Joystick is disconnected, This function may be called from the Joystick callback even for a disconnected Joystick.

Returns `true` if setting the user-defined pointer was successful or `false` if not, Along with error's code and message if occurred.

```lua
-- Sets the user-defined pointer for the first Joystick.
lovr.joystick.setUserPointer(0, nil) -- Or basically pointer to some data instead of nil.
```
