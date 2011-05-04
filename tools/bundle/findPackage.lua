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
File: findPackage.lua
]]--

require "lib/spliterator"

--[[[
Function: findPackage(name, [, silent])

Looks through the 'package.path' trying to find a matching
file named 'name'.

Parameters:
 name - a string with the name of the package to find (rules
  are the same as for the 'require' function, but only Lua
  modules are searched -- i.e. the 'package.path').
 silent - (optional) if set to true, no messages are printed
  by the function during the search.

Example:
> path = assert( findPackage( "loop.simple", "/" ) )
> print('Package "loop.simple" found at: " .. path)

See Also: 
 the 'require()' function in Lua.
 
Author: 
 Mateusz Czaplinski
]]--
function findPackage(name, silent)
    local echo = io.write
    if silent then
        echo = function(...) end
    end

    echo(('Loading package: %s\n'):format(name))
    for pattern in spliterator(package.path, ';', true) do
        -- print(pattern)
        local oldName = nil
        local newName = name
        while oldName ~= newName do
            local filename = pattern:gsub('?', newName)
            echo((' Trying: %s\n'):format(filename))
            local f = io.open(filename)
            if f then
                f:close()
                echo(' Found!\n')
                return filename
            end

            -- Try to replace dots '.' in package name with
            -- directory separator character
            oldName = newName
            newName = newName:gsub('%.', '/', 1)
        end
    end
    return nil, ("Could not find package: %s"):format(name)
end

