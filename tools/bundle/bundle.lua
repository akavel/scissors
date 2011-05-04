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
Script: bundle.lua

A utility script, which compiles all Lua modules required by Scissors
into bytecode and glues them together to one file runnable by Lua
interpreter.

Usage: 
> lua bundle.lua [--stdin] MAIN_SCRIPT [< OPTIONS_FILE]

Output:
 Writes two files: 'bundle.out.lua' and 'bundle.out'.

Options file:
 The OPTIONS_FILE is required and loaded only if the '--stdin' commandline
 option is provided. The OPTIONS_FILE should be a Lua script in which 
 the following settings are recognized:

 modules - a table of strings containing names of the modules, 
  which are to be included in the bundle. The modules should
  be ordered properly to fulfill their dependencies (independent
  modules first, more dependent ones later).
 
Example options file:
 (code)
 modules = { 'module1', 'module2' }
 (end code)
]]--

package.path = package.path .. ';./?'

require 'lib/luaEscape'
require 'bundle.findPackage'
require 'bundle.loadOptions'

--[[[
Function: multiReplace(s, replacements)

Treats every sequence of 2 or more ALLCAPS letters in 's' as a 
key in the 'replacements' table and replaces it's occurence 
with the associated value from the table.
]]--
local function multiReplace(s, replacements)
    return s:gsub('%u%u+', replacements)
end

local function applyLoader(files, loader)
    local code = {}
    local separator = '\n'
    for _, moduleName in ipairs(files) do
        local filename = assert(findPackage(moduleName))
        
        -- Load a file and get it's compiled bytecode.
        -- local moduleBytecode = string.dump(assert(loadfile(filename)))

        local f = io.open(filename)
        local moduleCode = f:read('*a')
        f:close()
        
        local stuffedLoader = multiReplace(loader, {
            CODE = moduleCode,
            NAME = moduleName:luaEscape()
        })
        
        table.insert(code, stuffedLoader .. separator)
        -- print(loaderCode)
        -- print(code)
        -- print(moduleName)
    end
    return table.concat(code, '')
end

local moduleLoader = [[
package.loaded[NAME] = package.loaded[NAME] or (function(...) CODE end)(NAME) or package.loaded[NAME] or true]]

local chunkLoader = [[(function(...) CODE end)()]]

local function writefile(opt)
    local f = assert(io.open(opt.fname, opt.mode))
    assert(f:write(opt.data))
    assert(f:close())
end

local function bundle(options)
    local code =
        'package.path=""\n' ..  -- to make it easier to check if all requirements got bundled
        applyLoader(options.modules, moduleLoader) ..
        applyLoader({options.mainScript}, chunkLoader)

    -- Write the result in Lua form
    writefile {
        fname = ('%s.out.lua'):format(options.outputName),
        mode = "w",
        data = code
    }

    -- Compile the result to bytecode
    local bytecode = string.dump(assert(loadstring(code, '<bundle.out.lua>')))

    -- Write the result in binary form
    writefile {
        fname = ('%s.out'):format(options.outputName),
        mode = "wb",
        data = bytecode
    }
end

local function main(arg)
    local options = {
        modules = {},
        outputName = 'bundle',
    }

    if #arg < 1 or arg[1] == '--help' or (#arg >= 2 and arg[1] ~= '--stdin') then
        print[[
Usage: lua bundle.lua [--stdin] MAIN_SCRIPT [< OPTIONS_FILE]

Writes two files: 'bundle.out.lua' and 'bundle.out'.

Available options:
 modules = { 'module1', 'module2' },
 outputName = 'bundle'  -- changes the name of the created files
]]
        os.exit(1)
    end

    if arg[1] == '--stdin' then
        options.mainScript = arg[2]
        loadOptions(io.stdin, options)
    else
        options.mainScript = arg[1]
    end

    bundle(options)
end

if arg == nil then
    return { run = bundle }
end

main(arg)
