-- Written by Rabia Alhaffar in 25/September/2020
-- Joystick and Gamepad input module for LÖVR :)

-- Load FFI and check support for lovr-joystick
local osname = (lovr.getOS or lovr.system.getOS)()
local not_android_or_web = ((osname ~= "Android") and (osname ~= "Web"))

-- Only run if we have LuaJIT and also GLFW
local ffi = assert((type(jit) == "table") and not_android_or_web and
  require("ffi"), "lovr-joystick cannot run on this platform!")

local C = (not_android_or_web and ffi.load("glfw3") or ffi.C)
local cstr = ffi.string

ffi.cdef([[
typedef struct GLFWgamepadstate {
    unsigned char buttons[15];
    float axes[6];
} GLFWgamepadstate;

typedef void (*GLFWjoystickfun)(int jid, int event);

void glfwPollEvents(void);
int glfwGetError(const char **description);

int glfwJoystickIsGamepad(int jid);
const char* glfwGetGamepadName(int jid);
int glfwGetGamepadState(int jid, GLFWgamepadstate *state);
int glfwUpdateGamepadMappings(const char *string);

int glfwJoystickPresent(int jid);
const char* glfwGetJoystickName(int jid);
const char* glfwGetJoystickGUID(int jid);
const float* glfwGetJoystickAxes(int jid, int* count);
const unsigned char* glfwGetJoystickHats(int jid, int* count);
const unsigned char* glfwGetJoystickButtons(int jid, int* count);
void* glfwGetJoystickUserPointer(int jid);
void glfwSetJoystickUserPointer(int jid, void* pointer); 
GLFWjoystickfun glfwSetJoystickCallback(GLFWjoystickfun callback);
]])

---
---@class joy
---
---Joystick and Gamepad input module for LÖVR that leverages GLFW through LuaJIT's FFI.
---
---To use:
---
---```lua
---lovr.joystick = require("lovr-joystick")
---```
---
local joystick = {
  --- Errors that might occur when calling one of the Joystick functions.
  errors = {
    --- No error has occurred.
    NONE = 0,
    
    --- The function was called that must not be called unless GLFW is initialized.
    GLFW_UNINITIALIZED = 0x00010001,
    
    --- The index for the Joystick/Gamepad or for the button is invalid.
    INVALID_INDEX = 0x00010003,
    
    --- One of the arguments passed to the function was an invalid value.
    INVALID_VALUE = 0x00010004,
    
    --- platform-specific error occurred.
    PLATFORM_SPECIFIC = 0x00010008
  },
  
  --- List of the Joystick events that can be used with `lovr.joystick.setCallback`'s callback function.
  events = {
    --- Joystick is connected.
    CONNECTED = 0x00040001,
    
    --- Joystick is disconnected.
    DISCONNECTED = 0x00040002
  },
  
  --- Indexes of the Joystick/Gamepad buttons.
  buttons = {
    A = 0,
    B = 1,
    X = 2,
    Y = 3,
    LB = 4,
    RB = 5,
    BACK = 6,
    START = 7,
    GUIDE = 8,
    LT = 9,
    RT = 10,
    UP = 11,
    RIGHT = 12,
    DOWN = 13,
    LEFT = 14
  },
  
  --- Indexes of the Joystick/Gamepad axes.
  axes = {
    LEFT_X = 0,
    LEFT_Y = 1,
    RIGHT_X = 2,
    RIGHT_Y = 3,
    LT = 4,
    RT = 5
  },
  
  --- List of the states for the Joystick hats.
  hat_states = {
    CENTERED = 0,
    UP = 1,
    RIGHT = 2,
    DOWN = 4,
    LEFT = 8,
    RIGHT_UP = 3,
    RIGHT_DOWN = 6,
    LEFT_UP = 9,
    LEFT_DOWN = 12
  }
}

-- Aliases to comform with Sony PlayStation
joystick.buttons.CROSS = joystick.buttons.A
joystick.buttons.CIRCLE = joystick.buttons.B
joystick.buttons.SQUARE = joystick.buttons.X
joystick.buttons.TRIANGLE = joystick.buttons.Y

joystick.buttons.LAST = joystick.buttons.LEFT
joystick.axes.LAST = joystick.axes.RT

---
---@version JIT
---
---Retrieves the GLFW error message and error code and used after calling GLFW function to check if success, This function is internal and not exposed for public usage.
---
---@return integer error_code The error code for the error message, Zero means no errors.
---@return string|nil error_message The error message, `nil` means no errors.
---
local function get_glfw_error()
  local error_message = nil
  local error_code = C.glfwGetError(error_message)
  
  return error_code, cstr(error_message)
end

---
---@version JIT
---
---Checks if the Joystick at index `idx` is available, Returns if it's available (or not) along with error's code and message if occurred.
---
---@param idx integer The index of the Joystick to check if it's available. (from 0 to 15)
---@return boolean res `true` if the Joystick is available or `false` if not available.
---@return integer error_code The error code for the error message, Zero means no errors.
---@return string|nil error_message The error message. `nil` means no errors.
---
---Example:
---
---```lua
---local joystick_present, error_code, error_message = lovr.joystick.isAvailable(0)
---
---if joystick_present then
---  -- The first Joystick is available
---end
---```
---
function joystick.isAvailable(idx)
  local res = (C.glfwJoystickPresent(idx) == 1)
  
  return res, get_glfw_error()
end

---
---@version JIT
---
---Checks if the Joystick at index `idx` has gamepad mappings, Returns if it has gamepad mappings or not along with error's code and message if occurred.
---
---(NOTE: Also this function can be used to check if the Joystick is Gamepad.)
---
---@param idx integer The index of the Joystick to check if has gamepad mappings. (from 0 to 15)
---@return boolean res `true` if the Joystick has gamepad mappings or `false` if not.
---@return integer error_code The error code for the error message, Zero means no errors.
---@return string|nil error_message The error message, `nil` means no errors.
---
---Example:
---
---```lua
---local gamepad, error_code, error_message = lovr.joystick.hasGamepadMappings(0)
---
---if gamepad then
---  -- The first Joystick has gamepad mappings.
---end
---```
---
function joystick.hasGamepadMappings(idx)
  local res = (C.glfwJoystickIsGamepad(idx) == 1)
  
  return res, get_glfw_error()
end

---
---@version JIT
---
---Retrieves the name of the Joystick at index `idx` as string, Along with error's code and message if occurred.
---
---(NOTE: If the Joystick has gamepad mappings, Then the gamepad name is returned instead.)
---
---@param idx integer The index of the Joystick to retrieve his name. (from 0 to 15)
---@return string|nil name The name of the Joystick, `nil` if failed to retrieve the Joystick's name.
---@return integer error_code The error code for the error message, Zero means no errors.
---@return string|nil error_message The error message, `nil` means no errors.
---
---Example:
---
---```lua
---local name, error_code, error_message = lovr.joystick.getName(0)
---
----- Prints the name of the first Joystick, Or prints the error message if error has occurred.
---print((name ~= nil) and name or error_message)
---```
---
function joystick.getName(idx)
  local is_gamepad, error_code, error_message = joystick.hasGamepadMappings(idx)
  
  if (error_code ~= 0) then
    return nil, error_code, error_message
  end
  
  local name = (is_gamepad and C.glfwGetGamepadName(idx) or C.glfwGetJoystickName(idx))
  error_code, error_message = get_glfw_error()
  
  return cstr(name), error_code, error_message
end

---
---@version JIT
---
---Retrieves the SDL-compatible GUID of the Joystick at index `idx` as string, Along with error's code and message if occurred.
---
---@param idx integer The index of the Joystick to retrieve his GUID. (from 0 to 15)
---@return string|nil guid The SDL-compatible GUID of the Joystick, `nil` if failed to retrieve the Joystick's GUID.
---@return integer error_code The error code for the error message, Zero means no errors.
---@return string|nil error_message The error message, `nil` means no errors.
---
---Example:
---
---```lua
---local guid, error_code, error_message = lovr.joystick.getGUID(0)
---
----- Prints the SDL-compatible GUID of the first Joystick, Or prints the error message if error has occurred.
---print((guid ~= nil) and guid or error_message)
---```
---
function joystick.getGUID(idx)
  local guid = C.glfwGetJoystickGUID(idx)
  
  return cstr(guid), get_glfw_error()
end

---
---@version JIT
---
---Retrieves state of the buttons and their count for Joystick at index `idx`, Along with error's code and message if occurred.
---
---(NOTE: If the Joystick has gamepad mappings, Then the state of the gamepad buttons is returned instead.)
---
---@param idx integer The index of the Joystick to retrieve the state of his buttons. (from 0 to 15)
---@return userdata|nil buttons The state of the buttons for the Joystick, `nil` if failed to retrieve the state of the buttons.
---@return integer buttons_count The number of buttons the Joystick has, Zero if failed to retrieve the state of the buttons.
---@return integer error_code The error code for the error message, Zero means no errors.
---@return string|nil error_message The error message, `nil` means no errors.
---
---Example:
---
---```lua
----- Get the state and count of buttons for the first Joystick.
---local buttons, buttons_count, error_code, error_message = lovr.joystick.getButtons(0)
---
---if ((buttons ~= nil) and (buttons[lovr.joystick.buttons.X] == 1)) then
---  -- Do something if X button is down.
---end
---```
---
function joystick.getButtons(idx)
  local buttons, buttons_count = nil, 0
  local is_gamepad, error_code, error_message = joystick.hasGamepadMappings(idx)
  
  if is_gamepad then
    local state = ffi.new("GLFWgamepadstate")
    local success = C.glfwGetGamepadState(idx, state)
    
    error_code, error_message = get_glfw_error()
    
    if (success == 1) then
      buttons, buttons_count = state.buttons, 14
    end
    
    return buttons, buttons_count, error_code, error_message
  end
  
  if (error_code == joystick.errors.NONE) then
    buttons = C.glfwGetJoystickButtons(idx, buttons_count)
    error_code, error_message = get_glfw_error()
  end
  
  return buttons, buttons_count, error_code, error_message
end

---
---@version JIT
---
---Checks if button `btn` in the Joystick at index `idx` is down or not, Returns if it's down along with error's code and message if occurred.
---
---@param idx integer The index of the Joystick to check if button `btn` is down. (from 0 to 15)
---@param btn integer|string The button to check if it's down, Can be the key or the value from one of `lovr.joystick.buttons`
---@return boolean down `true` if the button `btn` is down or `false` if not.
---@return integer error_code The error code for the error message, Zero means no errors.
---@return string|nil error_message The error message, `nil` means no errors.
---
---Example:
---
---```lua
---if lovr.joystick.isButtonDown(0, "X") then
---  -- Button X/Square pressed in the first Joystick.
---end
---
---if lovr.joystick.isButtonDown(0, lovr.joystick.buttons.A) then
---  -- Button A/Cross pressed in the first Joystick.
---end
---```
---
function joystick.isButtonDown(idx, btn)
  local button = (joystick.buttons[btn] or btn)
  local state, buttons_count, error_code, error_message = joystick.getButtons(idx)
  
  return ((state ~= nil) and (state[button] == 1) or false), error_code, error_message
end

---
---@version JIT
---
---Retrieves the values of the axes and the total number of axis for the Joystick at index `idx`, Along with error's code and message if occurred.
---
---(NOTE: If the Joystick has gamepad mappings, Then the state of the gamepad axes is returned instead.)
---
---@param idx integer The index of the Joystick to retrieve the state of his axes. (from 0 to 15)
---@return userdata|nil axes The state of the axes for the Joystick, `nil` if failed to retrieve the state of the axes.
---@return integer axis_count The number of axes the Joystick has, Zero if failed to retrieve the state of the axes.
---@return integer error_code The error code for the error message, Zero means no errors.
---@return string|nil error_message The error message, `nil` means no errors.
---
---Example:
---
---```lua
----- Get axes for the first Joystick.
---local axes, axis_count, error_code, error_message = lovr.joystick.getAxes(0)
---
---if (axes ~= nil) then
---  -- Print the value of left X axis for the first Joystick.
---  print(axes[lovr.joystick.axes.LEFT_X])
---end
---```
---
function joystick.getAxes(idx)
  local axes, axis_count = nil, 0
  local is_gamepad, error_code, error_message = joystick.hasGamepadMappings(idx)
  
  if is_gamepad then
    local state = ffi.new("GLFWgamepadstate")
    local success = C.glfwGetGamepadState(idx, state)
    
    error_code, error_message = get_glfw_error()
    
    if (success == 1) then
      axes, axis_count = state.axes, 6
    end
    
    return axes, axis_count, error_code, error_message
  end
  
  if (error_code == joystick.errors.NONE) then
    axes = C.glfwGetJoystickAxes(idx, axis_count)
    error_code, error_message = get_glfw_error()
  end
  
  return axes, axis_count, error_code, error_message
end

---
---@version JIT
---
---Retrieves the value of the specified axis from the Joystick at index `idx`, Along with error's code and message if occurred.
---
---@param idx integer The index of the Joystick to retrieve the value of the specified axis. (from 0 to 15)
---@param axis integer|string The axis from the Joystick to retrieve his value, Can be the key or the value from one of `lovr.joystick.axes`
---@return number axis_value value of the specified axis from the Joystick, If failed to retrieve the axes then zero is returned instead.
---@return integer error_code The error code for the error message, Zero means no errors.
---@return string|nil error_message The error message, `nil` means no errors.
---
---Example:
---
---```lua
----- Prints the value of the left X axis from the first Joystick.
---print(lovr.joystick.getAxisValue(0, "LEFT_X"))
---
----- Prints the value of the right X axis from the first Joystick.
---print(lovr.joystick.getAxisValue(0, lovr.joystick.axes.RIGHT_X))
---```
---
function joystick.getAxisValue(idx, axis)
  local x = (joystick.axes[axis] or axis)
  local axes, axis_count, error_code, error_message = joystick.getAxes(idx)
  
  return ((axes ~= nil) and axes[x] or 0), error_code, error_message
end

---
---@version JIT
---
---Retrieves the hats and total hats count for the Joystick at index `idx`, Returns them along with error's code and message if occurred.
---
---@param idx integer The index of the Joystick to retrieve the state of his hats. (from 0 to 15)
---@return userdata|nil hats The state of the hats for the Joystick, `nil` if failed to retrieve the state of the hats.
---@return integer hats_count The number of hats the Joystick has, Zero if failed to retrieve the state of the hats.
---@return integer error_code The error code for the error message, Zero means no errors.
---@return string|nil error_message The error message, `nil` means no errors.
---
---Example:
---
---```lua
----- Shortand xD
---local UP = lovr.joystick.hat_states.UP
---
----- Retrieve the state of the hats for the first Joystick.
---local hats, hats_count, error_code, error_message = lovr.joystick.getHats(0)
---
---if ((hats ~= nil) and (bit.band(hats[0], UP) == UP)) then
---  -- The state of the first hat from the first Joystick could be Up, Up-Left, or Up-Right.
---end
---```
---
function joystick.getHats(idx)
  local hats_count = 0
  local hats = C.glfwGetJoystickHats(idx, hats_count)
  
  return hats, hats_count, get_glfw_error()
end

---
---@version JIT
---
---Parses the specified ASCII encoded string and updates the internal list with any gamepad mappings it finds.
---
---If there is already a gamepad mapping for a given GUID in the internal list, it will be replaced by the one passed to this function. If the library is terminated and re-initialized the internal list will revert to the built-in default.
---
---Returns if updating process was successful or not, Along with error's code and message if occurred.
---
---@param mappings string The string containing the gamepad mappings, May contain either a single gamepad mapping or many mappings separated by newlines, The parser supports the full format of the `gamecontrollerdb.txt` source file including empty lines and comments.
---@return boolean success `true` if updating the gamepad mappings have been done successfully or `false` if failed.
---@return integer error_code The error code for the error message, Zero means no errors.
---@return string|nil error_message The error message, `nil` means no errors.
---
---Example:
---
---```lua
----- Try to open "gamecontrollerdb.txt" for reading.
---local f = io.open("./gamecontrollerdb.txt")
---
----- If failed then error, Else keep going...
---if not f then
---  error("failed to read gamecontrollerdb.txt to update gamepad mappings!", 2)
---else
---  -- Read all contents of "gamecontrollerdb.txt" update gamepad mappings with it.
---  local mappings = f:read("*a")
---  local success, error_code, error_message = lovr.joystick.updateGamepadMappings(mappings)
---  
---  -- If failed to update gamepad mappings then error, Else close the file handle.
---  if not success then
---    error(error_message, 2)
---  end
---  
---  f:close()
---end
---```
---
function joystick.updateGamepadMappings(mappings)
  local res = C.glfwUpdateGamepadMappings(mappings)
  
  return (res == 1), get_glfw_error()
end

---
---@version JIT
---
---Sets the Joystick configuration callback or removes the currently set callback, Called when a Joystick is connected to or disconnected from the system.
---
---for Joystick connection and disconnection events to be delivered on all platforms, you need to call one of the event processing functions.
---
---Joystick disconnection may also be detected and the callback called by Joystick functions, The function will then return whatever it returns if the Joystick is not present.
---
---Returns the previous callback set if exist or `nil`, Along with error's code and message if occurred.
---
---NOTE: The callback function `callback_func` takes the following form:
---
---```lua
---local function joystick_callback(joystick_index, joystick_event)
---  -- joystick_index: The index of the Joystick (from 0 to 15)
---  -- joystick_event: One of events from lovr.joystick.events (CONNECTED or DISCONNECTED)
---end
---```
---
---@param callback_func function The new callback, Pass `nil` to remove the currently set callback. 
---@return function|nil prev_callback The previously set callback, or `nil` if no callback was set or GLFW had not been initialized.
---@return integer error_code The error code for the error message, Zero means no errors.
---@return string|nil error_message The error message, `nil` means no errors.
---
---Example:
---
---```lua
---local function joystick_callback(joystick_index, joystick_event)
---  if (joystick_event == lovr.joystick.events.DISCONNECTED) then
---    print("Joystick " .. (joystick_index + 1) .. " is disconnected!")
---  end
---end
---
---local prev_callback, error_code, error_message = lovr.joystick.setCallback(joystick_callback)
---
---if (error_code ~= 0) then
---  error(error_message, 2)
---end
---```
---
function joystick.setCallback(callback_func)
  local prev_callback = C.glfwSetJoystickCallback(callback_func)
  
  return prev_callback, get_glfw_error()
end

---
---@version JIT
---
---Returns the current value of the user-defined pointer of the Joystick at index `idx`, Along with error's code and message if occurred.
---
---This function may be called from the Joystick callback even for a disconnected Joystick.
---
---@param idx integer The index of the Joystick to retrieve his user-defined pointer. (from 0 to 15)
---@return userdata|nil ptr The current value of the user-defined pointer of the Joystick, The initial value for the user-defined pointer is `nil`
---@return integer error_code The error code for the error message, Zero means no errors.
---@return string|nil error_message The error message, `nil` means no errors.
---
---Example:
---
---```lua
----- Retrieve the user-defined pointer for the first Joystick.
---local ptr, error_code, error_message = joystick.getUserPointer(0)
---```
---
function joystick.getUserPointer(idx)
  local ptr = C.glfwGetJoystickUserPointer(idx)
  
  return ptr, get_glfw_error()
end

---
---@version JIT
---
---Sets the current value of the user-defined pointer of the Joystick at index `idx`, The current value is retained until the Joystick is disconnected, This function may be called from the Joystick callback even for a disconnected Joystick.
---
---Returns if setting the user-defined pointer was successful or not, Along with error's code and message if occurred.
---
---@param idx integer The index of the Joystick to set his user-defined pointer. (from 0 to 15)
---@param ptr userdata|nil The user-defined pointer to set to the Joystick, The initial value for the user-defined pointer is `nil`
---@return boolean success `true` if setting the user-defined pointer was successful or `false` if not.
---@return integer error_code The error code for the error message, Zero means no errors.
---@return string|nil error_message The error message, `nil` means no errors.
---
---Example:
---
---```lua
----- Sets the user-defined pointer for the first Joystick.
---lovr.joystick.setUserPointer(0, nil) -- Or basically pointer to some data instead of nil.
---```
---
function joystick.setUserPointer(idx, ptr)
  C.glfwSetJoystickUserPointer(idx, ptr)
  local error_code, error_message = get_glfw_error()
  
  return (error_code == joystick.errors.NONE), error_code, error_message
end

return joystick
