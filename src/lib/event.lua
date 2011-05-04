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

local oo = require "loop.simple"  -- Object Oriented facilities for Lua
local pairs = pairs

module(...)

--[[[
Class: Event
Mimics 'events' known from other languages.
]]--
Event = oo.class{}

function Event:__init()
    return oo.rawnew(self, {
        list = {}
    })
end

--[[[
Function: Event:add(func)
Adds the 'func' function to the list of handlers for the event.
]]--
function Event:add(func)
    self.list[func] = 1
end

--[[[
Function: Event:remove(func)
Removes the 'func' function from the list of handlers for the event.
]]--
function Event:remove(func)
    self.list[func] = nil
end

--[[[
Function: Event:raise(...)
Invokes all the registered handlers with the specified arguments.
Note that there's no guarantee on the order in which the handlers will be invoked.
]]--
function Event:raise(...)
    for handler in pairs(self.list) do
        handler(...)
    end
end

