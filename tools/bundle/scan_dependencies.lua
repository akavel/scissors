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
File: scan_dependencies.lua

A utility script, which scans a specified Lua script for its dependencies
(by recursively finding the modules loaded with the 'require' function).

Note: the script uses a very simple algorithm for finding the 'require'
function calls, so don't expect it to work with anything but simple strings
passed to 'require'. Note also that commented out 'require' calls are not ommitted.
]]--

require "bundle.findDependencies"
require "bundle.loadOptions"

local function scan_dependencies(options)
    local script = readfile(assert(options.scannedFile, "The SCANNED_FILE parameter was not provided."))
    
    local preloaded = options.preloaded
    if type(preloaded) == 'table' and #preloaded > 0 then
        for _, name in ipairs(preloaded) do
            preloaded[name] = true
        end
    end
    
    io.output(io.stderr)
    local dependencies = findDependencies(script, preloaded)
    io.output(io.stdout)

    return dependencies
end

local function main(arg)
    local options = {
        preloaded = {},
        template = '%s',
    }

    if #arg < 1 or arg[1] == '--help' then
        print[[
Usage: lua scan_dependencies.lua [--stdin] [SCANNED_FILE] [< OPTIONS_FILE] > DEPENDENCIES_FILE

If the first option is "--stdin", the options are loaded from OPTIONS_FILE,
and SCANNED_FILE option is ignored.

Available options:
 scannedFile = 'filename.lua'
  -- 'filename.lua' will be treated as SCANNED_FILE
 preloaded = { 'module1', 'module2' }
  -- modules 'module1' and 'module2' will be treated as already loaded and 
     won't be included in the dependencies list. Default: {}
 outputTemplate = 'deps = { %s\\n}'
  -- a template for the dependencies output. The %s is substituted with
     the dependency list. Default: '%s']]
        os.exit(1)
    end

    if arg[1] == '--stdin' then
        loadOptions(io.stdin, options)
    else
        options.scannedFile = arg[1]
    end

    local dependencies = scan_dependencies(options)

    local out = {}
    for _,v in ipairs(dependencies) do
        table.insert(out, ("'%s',\n"):format(v))
    end
    io.write(options.outputTemplate:format(table.concat(out, '')))
end

if arg == nil then
    return { run = scan_dependencies }
end

main(arg)
