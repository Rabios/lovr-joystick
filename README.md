# lovr-joystick

Joystick and Gamepad input module for [LÖVR](https://lovr.org) that leverages [GLFW](https://glfw.org) through [LuaJIT's FFI](https://luajit.org/ext_ffi.html).

### Usage

```lua
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
```

Check out the [API](https://github.com/Rabios/lovr-joystick/blob/master/API.md) for more informations on using the library.

### Support and Troubleshooting

1. If LÖVR throws error due to missing procedure(s) then replace the shared library of GLFW (Which comes along LÖVR files) with the latest one from [GLFW Downloads](https://www.glfw.org/download.html)

2. As of the latest commit, The annotations for [Lua Language Server](https://github.com/sumneko/lua-language-server) is provided so it will help in case you are using [Visual Studio Code](https://code.visualstudio.com)

3. If you want to use `lovr-joystick` outside of LÖVR within another Lua game engine/framework that leverages GLFW then it's possible, Keep in mind that you are calling the functions after initializing GLFW and without dereferencing via `lovr.`

### License

MIT, Check [`LICENSE.txt`](https://github.com/Rabios/lovr-joystick/blob/master/LICENSE.txt) for license.
