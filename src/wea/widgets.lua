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
local print = print
local require = require

module "wea"

local utils = require "wea.utils"


local function wrappedWindowGenerator(windowGenerator, optionalModifier)
    return function(...)
        local args = utils.normalizeArgsList(...)
        return function(parent)
            local o =
            {
                wx = windowGenerator(parent, args)
            }
            local window = o.wx
            utils.applyBasicParameters(window, args)
            if optionalModifier then
                optionalModifier(window, args)
            end
            if args.code then
                args.code(o, args)
            end
            return utils.copySizerFlags(o, args)
        end
    end
end




--[[[
Function: wea.Frame

Examples:
 > f1 = wea.Frame{ title='My App' }
 > f2 = wea.Frame{ 'My App', size={640, 480} }
]]--
Frame = oo.class()
Window = Frame

function Frame:__init(args)
    local o =
    { 
        wx = wx.wxFrame(
            wx.NULL,
            wx.wxID_ANY,
            args.title or args[1],
            wx.wxDefaultPosition,
            args.size and Size(args.size) or wx.wxDefaultSize,
            wx.wxDEFAULT_FRAME_STYLE
        )
    }
    o.wx:Show(false)
    utils.applyBasicParameters(o.wx, args)
    utils.applyLayoutIfSupplied(o.wx, args)
    return oo.rawnew(self, o)
end

function Frame:Show(visible)
    -- default argument: true
    self.wx:Show( (visible == nil) and true or visible )
end


--[[[
Function: wea.Dialog

Examples:
 > d1 = wea.Dialog{ title='Some Dialog' }
 > d2 = wea.Dialog{ 'Some Dialog', size={640, 480}, parent=someWindow, style=wx.wxDEFAULT_DIALOG_STYLE }
]]--
Dialog = oo.class()

function Dialog:__init(args)
    args.style = utils.parseStyles(args.style or {'default-dialog-style'})
    local o =
    {
        wx = wx.wxDialog(
            args.parent or wx.NULL,
            wx.wxID_ANY,
            args.title or args[1],
            wx.wxDefaultPosition,
            args.size and Size(args.size) or wx.wxDefaultSize,
            args.style or wx.wxDEFAULT_DIALOG_STYLE
        )
    }
    -- o.wx:Show(false)
    utils.applyBasicParameters(o.wx, args)
    utils.applyLayoutIfSupplied(o.wx, args)
    return oo.rawnew(self, o)
end

function Dialog:Show(visible)
    -- default argument: true
    self.wx:Show( (visible == nil) and true or visible )
end

----------------------

StaticBitmap = wrappedWindowGenerator(function(parent, args)
    return wx.wxStaticBitmap(
        parent, 
        wx.wxID_ANY, 
        args.image or args.src or args[1])
end)
Bitmap = StaticBitmap

----------------------

StaticText = wrappedWindowGenerator(function(parent, args)
    return wx.wxStaticText(
        parent, 
        wx.wxID_ANY, 
        args.label or args[1])
end, function(window, args)
    if args.wrap then
        window:Wrap(args.wrap)
    end
end)
Label = StaticText

----------------------

Panel = wrappedWindowGenerator(function(parent, args)
    local style = args.style or {'tab-traversal'} -- default for wxPanel
    return wx.wxPanel(
        parent, 
        wx.wxID_ANY,
        wx.wxDefaultPosition,
        args.size or wx.wxDefaultSize,
        utils.parseStyles(style))
end, function(window, args)
    utils.applyLayoutIfSupplied(window, args)
end)
Pane = Panel

----------------------

ScrolledWindow = wrappedWindowGenerator(function(parent, args)
    local style = args.style or {'hscroll', 'vscroll'} -- default for wxScrolledWindow
    return wx.wxScrolledWindow(
        parent,
        wx.wxID_ANY,
        wx.wxDefaultPosition,
        args.size or wx.wxDefaultSize,
        utils.parseStyles(style))
end, function(window, args)
    utils.applyLayoutIfSupplied(window, args)
end)

----------------------

TextCtrl = wrappedWindowGenerator(function(parent, args)
    local style = args.style or {'rich'}
    local window = wx.wxTextCtrl(
        parent, 
        wx.wxID_ANY,
        "",
        wx.wxDefaultPosition,
        wx.wxDefaultSize,
        utils.parseStyles(style, 'TE') + utils.parseStyles(style))
    for _, entry in ipairs(args.text or args) do
        if type(entry) == 'string' then
            window:AppendText(entry)
        else
            entry.wx:SetFlags(utils.getWxConst('TEXT_ATTR', 'font-weight'))
            local res = window:SetDefaultStyle(entry.wx)
            -- print(res)
        end
    end
    return window
end)
TextBox = TextCtrl

----------------------

Button = wrappedWindowGenerator(function(parent, args)
    return wx.wxButton(
        parent,
        args.id or wx.wxID_ANY,
        args.label or args.text or args[1] or ''
    )
end)

----------------------
