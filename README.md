# lovr-joystick

Joystick and Gamepad input module for LÖVR!

### Usage

```lua
-- Require module (Copy lovr-joystick.lua)
lovr.joystick = require("lovr-joystick")
local draw = false

-- Draw!
function lovr.draw()
  lovr.graphics.clear()
  if draw then
    -- If gamepad with index 0 (First gamepad) is available then
    -- draw text contains joystick name!
    if lovr.joystick.isAvailable(0) then
      lovr.graphics.print(lovr.joystick.getName(0), 0, 0, -5, 1)
	end
  end
end

-- Update!
function lovr.update()
  -- If x button pressed by first gamepad (It has index 0)
  if lovr.joystick.isDown(0, "x") then
    draw = true
  else
    draw = false
  end
end
```

### API

- `joystick.isAvailable(id)` returns true if joystick/gamepad with id is available.
- `joystick.isDown(id, button)` returns true if button is hold down from joystick/gamepad with id.
- `joystick.getName(id)` returns string contains joystick/gamepad name.
- `joystick.getAxes(id)` returns array contains joystick/gamepad axes.

### NOTES

1. Buttons, Gamepad ID (index), Hats and Axes all start from 0 and NOT 1.
2. Unsupported stuff (functions) by GLFW version that LÖVR uses is commented, That's in case you updated the GLFW library by replace.

### License

Check [`LICENSE.txt`](https://github.com/Rabios/lovr-joystick/blob/master/LICENSE.txt) for license.
