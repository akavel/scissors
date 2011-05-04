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
local string = string
local print = print
local require = require

module "wea"

local ids = require "wea.ids"

------------------------------
------------------------------

--[[[
Class: wea.MenuBarBuilder
]]--
MenuBarBuilder = oo.class{}

local function labelSimplify(label)
    local result = label
    
    -- Remove the keyboard shortcut specification provided after '\t'
    local pos = result:find('\t', 1, true)
    if pos then
        result = result:sub(1, pos-1)
    end
    
    -- Remove trailing '...'
    result = result:gsub('%.+$', '')
    
    -- Remove the '&'s
    result = result:gsub('&', '')
    
    -- Convert all remaining whitespace and unknown characters to underscores '_'
    result = result:gsub('[^%w_]', '_')

    --print(result)
    return result
end

--[[[
Constructor: wea.MenuBarBuilder(table)
 Builds a wxMenuBar, with wxMenu elements, based on a description
 specified in the 'table' argument.

Example 1:
(code)
wea.MenuBarBuilder{
    {"&File",
        {"&Open\tCtrl-O", '_OPEN'}, -- dummy entry without handler
        {"&Foobar", function(event) print('foo') end}, -- ID will be autogenerated
        {"E&xit\tAlt-X", handle_exit, '_EXIT'},
    }
}
:apply_to(wx_frame)
(end code)

Example 2:
 A more explicit version of the previous example:
(code)
wea.MenuBarBuilder{
    {label="&File",
        {label="&Open\tCtrl-O", id=wx.wxID_OPEN}, 
        {label="&Foobar", handler=function(event) print('foo') end},
        {label="E&xit\tAlt-X", handler=handle_exit, wxid='_EXIT'},
    }
}
:apply_to(wx_frame) 
(end code)

Important:
 - If you specify anywhere an 'id' field, it should be only one of
   the predefined wxLua IDs.
]]--
function MenuBarBuilder:__init(menubar)
    local o = {}
    o.menubar = menubar
    o.wx = wx.wxMenuBar()

    -- Iterate over menus to be added to the MenuBar
    for _,menu in ipairs(menubar) do
    
        -- Initialize the menu object.
        menu.wx = wx.wxMenu()
        
        menu.label = menu.label or menu[1]

        -- Add items to the current menu.
        for _,e in ipairs(menu) do
            if type(e) == 'table' then
                
                -- Fill named fields from unnamed ones
                e.label = e.label or e[1]
                for j=2,#e do
                    local v = e[j]
                    if type(v) == 'function' then
                        e.handler = e.handler or v
                    elseif (type(v) == 'string') and (string.sub(v,1,1) == '_') then
                        e.wxid = e.wxid or v
                    end
                end
                
                -- Check if we shouldn't retrieve or generate the ID for the current item.
                e.id = e.id or (e.wxid and wx['wxID'..e.wxid]) or ids.get(e.handler)
                
                -- Add the menu item.
                menu.wx:Append(
                    e.id,
                    e.label
                )
                
                -- Remember the menu entry under a programmer-friendly name
                -- Note: this should be the last action to protect us from users using "wx" or "label"
                -- as their menu entry labels.
                menu[labelSimplify(e.label)] = e
            end
        end

        -- Add the menu built to the menu bar.
        o.wx:Append(
            menu.wx, 
            menu.label
        )
        
        -- Remember the menu under a programmer-friendly name
        -- Note: this should be the last action to protect us from users using "wx" or "label"
        -- as their menu labels.
        o.menubar[labelSimplify(menu.label)] = menu
    end

    return oo.rawnew(self, o)
end

--[[[
Function: apply_to(self, wxFrame)
]]--
function MenuBarBuilder:apply_to(frame)
    frame:SetMenuBar(self.wx)

    -- Iterate over menus to connect action handlers.
    for _,menu in ipairs(self.menubar) do
        for _,e in ipairs(menu) do
            if type(e) == 'table' and e.handler then
                frame:Connect(
                    e.id,
                    wx.wxEVT_COMMAND_MENU_SELECTED,
                    e.handler)
            end
        end
    end

end

