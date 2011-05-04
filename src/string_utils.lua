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

local max = math.max
local min = math.min
local xmlh = xmlh
local string = string
local ipairs = ipairs

require "lib/spliterator"
require "lib/collect"

local spliterator = spliterator
local collect = collect


function isspace(s)
    return string.find(s, '^%s+$') ~= nil
end

function rtrim(s)
    return string.gsub(s, '%s+$', '')
end

function splitlines(s)
    return collect(spliterator(s, '\n', true))
end

function trim_text_block(lines)
    -- Strip empty lines above and below
    local row1, row2 = 1, #lines
    for i = 1, #lines do
        if #lines[i] > 0 and not isspace(lines[i]) then
            row1 = i
            break  -- found a non-empty line
        end
    end
    for i = #lines, row1, -1 do
        if #lines[i] > 0 and not isspace(lines[i]) then
            row2 = i
            break  -- found a non-empty line
        end
    end
    
    -- find longest common prefix of spaces
    local maxj = nil
    for i = row1, row2 do
        local line = lines[i]
        local firstNonSpace = line:find('[^ ]')
        if firstNonSpace then
            maxj = min(firstNonSpace, maxj or firstNonSpace)
        end
    end
    maxj = maxj or 1
    
    -- strip the whitespace prefix from lines
    local result = {}
    for i = row1, row2 do
        table.insert(result, lines[i]:sub(maxj))
    end
    
    return result
end

