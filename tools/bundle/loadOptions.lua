--[[

Scissors XML Viewer License (MIT License)
-----------------------------------------
Copyright (c) 2009-2011  Mateusz Czapliński

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

]]--

--[[[
File: loadOptions.lua
]]--

--[[[
Function: loadOptions(fileHandle[, defaults])
Reads a Lua script from the 'fileHandle' file, capturing global variables to
a table.

Parameters:
 defaults - (optional) a table with default values of the options. If provided,
  will be filled with the actual values after the function ends.
Returns: a table filled with the variables assigned to in the script.
Author: Mateusz Czaplinski
]]--
function loadOptions(fileHandle, defaults)
    local options = defaults or {}
    local script = fileHandle:read '*a'
    local chunk = assert(loadstring(script))
    setfenv(chunk, options)
    chunk()
    return options
end
