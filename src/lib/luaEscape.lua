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
Function: string.luaEscape(s)
Converts a string to an escaped form, which can be pasted
into Lua code.

Note:
 A shorter version is possible:
 > function string.luaEscape(s)
 >   return string.format('%q',s)
 > end
 but seems not to be working well with 'wxluafreeze', which
 unfortunately seems to perform some internationalization-like
 transformations on the code it loads.

Author:
 Mateusz Czaplinski
]]--

local function isSafe(c)
    return (c:match"[%w!@#$%^&*()_+={};:|,./<>?%[%]'`~-]")
end

local function isDigit(c)
    return (c:match'%d')
end

function string.luaEscape(s)
    if not s then return 'nil' end
    local t = {}
    -- for i = 1,#s do
    local lastChar = s:sub(1, 1)
    -- while true do
    for i = 2,#s+1 do
        local char = s:sub(i, i)
        local replacement
        if isSafe(lastChar) then
            -- Safe char can be written raw and succeeded by anything
            replacement = lastChar
        else
            local code = string.byte(lastChar)
            if isDigit(char) then
                -- If the next char is digit, then an escaped unsafe char must be encoded with full 3 digits
                replacement = ('\\%03d'):format(code)
            else
                -- Otherwise we can use only as much digits as we need
                replacement = ('\\%d'):format(code)
            end
        end
        table.insert(t, replacement)
        lastChar = char
    end
    return '"' .. table.concat(t, '') .. '"'
end

