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

function main(arg, returnSilent)
    -- checking program arguments
    if #arg < 1 then
        io.write[[
Usage: lua make_embedded_image.lua IMG_FILE_PATH > EMBEDDED_IMG.lua
]]
        os.exit(1)
    end

    -- program arguments
    local fnameIn = arg[1]

    -- module dependencies
    package.path = package.path .. ';../src/?.lua'
    require 'lib/luaEscape'

    -- load the file contents
    local fh = assert(io.open(fnameIn, 'rb'))
    local data = fh:read '*a'
    fh:close()

    -- format the data in a Lua-readable form
    local template = [[
return %s
]]
    local embeddedData = template:format(data:luaEscape())

    -- if called as a library, allow retrieving result data
    if returnSilent then
        return embeddedData
    end

    -- write the embedded image to output
    io.write(embeddedData)
end

if arg == nil then
    return { main = main }
end

main(arg)
