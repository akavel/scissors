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
File: wxluafreeze_package_generator.lua

A utility script, which helps to create bytecode-compiled packages for use with
the 'wxluafreeze' tool. The script generates another Lua script with the
provided bytecode file inlined.
]]--

require 'lib/luaEscape'

local outputTemplate = [[
assert(loadstring(%s))()]]

local function convert(fname)
    local fh = assert(io.open(fname, 'rb'))
    local binarychunk = fh:read('*a')
    -- print(("-- Read: %d bytes"):format(#buf))
    local output = outputTemplate:format(binarychunk:luaEscape())
    fh:close()
    return output
end

local function main()
    if #arg < 1 then
        print[[
Usage: lua wxluafreeze_package_generator.lua <lua_bytecode_file_name>]]
        os.exit(1)
    end
    
    print(convert(arg[1]))
end

if arg == nil then
    return { run = convert }
end

main()
