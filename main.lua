-- Require the module for dealing with the Joystick/Gamepad
lovr.joystick = require("lovr-joystick")

local name, error_code, error_message

function lovr.load()
  -- Try to retrieve the name of the first Joystick/Gamepad
  name, error_code, error_message = lovr.joystick.getName(0)
  
  -- If failed, Set the name to the error message.
  if (error_code ~= lovr.joystick.errors.NONE) then
    name = error_message
  end
end

function lovr.draw()
  -- Draw the name of the first Joystick/Gamepad, Or the error message if failed to retrieve the name.
  lovr.graphics.print(name, 0, 0, -5, 0.5)
end
