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

-- Options
local options = {
    OUTPUT_NAME = '_bundle'
}

-- Hide 'arg' from loaded modules
arg = nil

-- Load utility scripts/modules
package.path = package.path .. ';../tools/?.lua'
local make_embedded_image = require 'make_embedded_image'
local scan_dependencies = require 'bundle.scan_dependencies'
local bundle = require 'bundle.bundle'
local wxluafreeze_package_generator = require 'wxluafreeze_package_generator'

function writefile(fname, contents)
    local f = assert(io.open(fname, 'w'))
    f:write(contents)
    f:close()
end

function main()
    -- Prepare embedded images
    local write_embedded_image = function(dst, src)
        local data = make_embedded_image.main({('../img/%s'):format(src)}, true)
        writefile(('resources/embedded_%s.lua'):format(dst), data)
    end
    write_embedded_image('title_image', 'navigation5.png')
    write_embedded_image('author_logo', 'mateusz.czaplinski.png')
    write_embedded_image('refresh_icon', 'arrow_refresh_small.png')

    -- Create bundle.out and bundle.out.lua
    local dependencies = scan_dependencies.run {
        scannedFile = 'main.wlua',
        preloaded = {'wx', 'table'}
    }
    bundle.run {
        mainScript = 'main.wlua',
        modules = dependencies,
        outputName = options.OUTPUT_NAME
    }

    --[[
    wxluafreeze.exe currently doesn't handle precompiled
    (to bytecode) Lua files. Below we precompile the files
    and then convert them to an escaped string inlined
    in a small bootstrap lua script. Unfortunately, such a
    form is slightly bigger (!) than the original lua
    script (including comments!). However, that leaves me
    in doubt as to whether wxluafreeze can handle all
    Lua-allowed strings properly, so I prefer to pass them
    through the encryptor anyway.
    ]]

    -- Try to compile externally, as this generates 
    -- a smaller file (otherwise debug inf. is included 
    -- in the bytecode output)
    os.execute(('luac -s -o %s.out %s.out.lua'):format(
        options.OUTPUT_NAME, options.OUTPUT_NAME
    ))

    -- Inline the bytecode as Lua string, for wxLuaFreeze
    local for_wxluafreeze = wxluafreeze_package_generator.run(
        ('%s.out'):format(options.OUTPUT_NAME)
    )
    local name_for_wxluafreeze = ('%s.wxluafreeze.lua'):format(options.OUTPUT_NAME)
    writefile(name_for_wxluafreeze, for_wxluafreeze)
    
    -- Call wxLuaFreeze to build an .exe file
    arg = {
        '../tools/wxluafreeze-2.8.7-scissors-ico.exe',
        name_for_wxluafreeze,
        '../scissors.exe' -- output file path
    }
    assert(loadfile '../tools/wxluafreeze.lua')()
end

main()
