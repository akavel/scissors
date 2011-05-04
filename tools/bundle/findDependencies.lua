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
File: findDependencies.lua
]]--

require "bundle.findPackage"

function readfile(name)
    local fh = assert(io.open(name))
    return fh:read '*a', fh:close()
end

--[[[
Function: findDependencies(script, preloaded)

A utility function, which scans a specified Lua script for its dependencies
(by recursively finding the modules loaded with the 'require' function).

Note: the function uses a very simple algorithm for finding the 'require'
function calls, so don't expect it to work with anything but simple strings
as passed to 'require'. Note also that commented out 'require' calls are not ommitted.
]]--
function findDependencies(script, preloaded)
    local echo = function(s)
        io.write(s)
    end
    local dependencies = {}
    local preloaded = preloaded or {}
    for _, v in script:gmatch [[require[%(%s]*(['"])(.-)%1]] do
        echo(("Package: %s"):format(v))
        if preloaded[v] then
            echo "\t - already loaded.\n"
        else
            echo "\t - not loaded...\n"
            preloaded[v] = true
            
            local submoduleFilename = assert(findPackage(v))
            local submodule = readfile(submoduleFilename)

            echo(("Checking dependencies for: %s\n"):format(submoduleFilename))
            local submodules = findDependencies(submodule, preloaded)
            
            for _, vv in ipairs(submodules) do
                table.insert(dependencies, vv)
            end
            
            table.insert(dependencies, v)
        end
    end
    return dependencies
end

