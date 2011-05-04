--[[[
Module: wea

This module is "wea", which stands for "wxEasier" -- Lua wxWidgets made Easier.
]]--

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
local pairs = pairs
local string = string
local print = print
local tostring = tostring
local require = require

module "wea"

local ids = require "wea.ids"
local utils = require "wea.utils"
require "wea.primitives"
require "wea.widgets"
require "wea.layout"
require "wea.menu"

------------------------------
------------------------------

--[[[
Function: wea.run()
Runs the GUI main loop.

Note:
 Call wea.run() last to start the wxWidgets event loop,
 otherwise the wxLua program will exit immediately.
 Does nothing if running from wxLua, wxLuaFreeze, or wxLuaEdit since the
 MainLoop is already running or will be started by the C++ program.
]]--
function run()
    wx.wxGetApp():MainLoop()
end

------------------------------
------------------------------

--[[[
Function: wea.SystemSettings.GetFont(fontId)

Example:
 > local font = wea.SystemSettings.GetFont(wea.sys.DefaultGuiFont)
]]--
SystemSettings = {}
SystemSettings.GetFont = function(fontId)
    return Font{ wx = wx.wxSystemSettings.GetFont(fontId) }
end

----------------------

sys = {
    DefaultGuiFont = wx.wxSYS_DEFAULT_GUI_FONT
}

----------------------

function TextAttr(...)
    local args = utils.normalizeArgsList(...)
    return {
        wx = wx.wxTextAttr(
            args.color and args.color.wx or wx.wxNullColour,
            args.background and args.background.wx or wx.wxNullColour,
            args.font and args.font.wx or wx.wxNullFont,
            args.align or wx.wxTEXT_ALIGNMENT_DEFAULT)
    }
end

----------------------

