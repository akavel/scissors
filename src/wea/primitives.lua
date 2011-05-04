--[[
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

local wx = require "wx"
local oo = require "loop.simple"  -- Object Oriented facilities for Lua

local type = type
local require = require

module "wea"

local utils = require "wea.utils"

------------------------------
------------------------------

--[[[
Function: wea.Size{ width, height }

Example:
> s = wea.Size{ width, height }
]]--
function Size(arg)
    return wx.wxSize(arg[1],arg[2])
end

----------------------

--[[[
Function: wea.Color(...)

Examples:
> red = wea.Color '#ff0000'
> green = wea.Color( 0, 255, 0 )
> blue = wea.Color( 0x0000ff )
> gray = wea.Color{ r=128, g=128, b=128 }
]]--
function Color(...)
    local args = utils.normalizeArgsList(...)
    local r, g, b
    if #args == 1 then
        local arg = args[1]
        if type(arg) == 'string' then
            return { wx = wx.wxColour(arg) }
        end
        r = arg / 0x010000
        g = arg / 0x000100 % 0x100
        b = arg % 0x100
    else
        r = args.r or args[1]
        g = args.g or args[2]
        b = args.b or args[3]
    end
    return { wx = wx.wxColour(r, g, b) }
end

----------------------

--[[[
Class: wea.Font(...)

Example:
 > local font1 = wea.Font{ weight="bold", size=12, family='swiss', face='Arial' }
]]--
Font = oo.class()

function Font:__init(args)
    local o = oo.rawnew(self, {})
    if args.wx ~= nil then
        o.wx = args.wx
    else
        -- Construct a new wxFont object
        o.wx = wx.wxFont.New(
            args.size,
            utils.getWxConst('FONTFAMILY', args.family or 'swiss'),
            utils.getWxConst('FONTSTYLE', args.style or 'normal'),
            utils.getWxConst('FONTWEIGHT', args.weight or 'normal'),
            false, -- font not underlined
            args.face or 'Arial')
    end
    return o
end

function Font:GetPointSize()
    return self.wx:GetPointSize()
end

----------------------
