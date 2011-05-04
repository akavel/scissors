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
local ipairs = ipairs
local tostring = tostring
local require = require

module "wea"

local utils = require "wea.utils"

------------------------------
------------------------------

Spacer = oo.class()
function Spacer:__init(...)
    local args = utils.normalizeArgsList(...)
    return oo.rawnew(self, args)
end

function Spacer:_applyTo(sizer)
    sizer:Add(
        self.w or self[1],
        self.h or self[2],
        self.prop or self[3] or 0)
end

function StretchSpacer(prop)
    return Spacer(0, 0, prop or 1)
end

----------------------

local function Box(orientation, args)
    return function(parent)
        local o =
        {
            wx = wx.wxBoxSizer(orientation)
        }
        for i, widget in ipairs(args) do
            if type(widget) == 'function' then
                -- Realize the widget
                widget = widget(parent)
                -- Add the widget to the sizer
                local tabBorder = utils.normalizeSubOptions(widget.border)
                local numBorder = type(widget.border)=='number' and widget.border
                o.wx:Add(
                    widget.wx,
                    widget.proportion or 0,
                    (
                        utils.useFlag(wx.wxEXPAND, widget.expand) +
                        utils.parseStyles(widget.align or {}, 'ALIGN') +
                        utils.parseStyles(numBorder and 'all' or tabBorder) +
                        0
                    ),
                    (tabBorder and (tabBorder.w or tabBorder.width or tabBorder[1]))
                        or numBorder
                        or 0
                )
            elseif widget._applyTo then
                widget:_applyTo(o.wx)
            else
                error(('Unknown widget format for widget %d (%s).')
                    :format(i, tostring(widget)))
            end
        end
        return utils.copySizerFlags(o, args)
    end
end

function Vbox(args)
    return Box(wx.wxVERTICAL, args)
end

function Hbox(args)
    return Box(wx.wxHORIZONTAL, args)
end

----------------------

