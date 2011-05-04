--[[
Copyright 2009  Mateusz Czaplinski

    This file is part of Scissors.

    Scissors is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Scissors is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Scissors.  If not, see <http://www.gnu.org/licenses/>.

]]--

print(package.path)
package.path = package.path .. ';../src/?.lua'

require "wx"
local wea = require "wea"

function ctor_init(self,...)
    local o = oo.rawnew(self,{})
    o:__ctor(...)
    return o
end

-- wea.LayoutBuilder = oo.class{}

-- function wea.LayoutBuilder.__init(arg)
-- end

wea.internal = {}
wea.internal.LayoutPart = oo.class{ --[[__init = ctor_init]]-- }

function wea.internal.LayoutPart:__ctor(arg)
    self.arg = arg
end

function wea.internal.LayoutPart:CollectSubparts(targetSizer)
    for _,part in ipairs(self.arg) do
        local a = part.arg, s = wea.s
        local flag
        if a.valign == s.center then flag = flag + wx.wxALIGN_CENTER_VERTICAL end
        if a.valign == s.top    then flag = flag + wx.wxALIGN_TOP end
        if a.valign == s.bottom then flag = flag + wx.wxALIGN_BOTTOM end
        if a.halign == s.center then flag = flag + wx.wxALIGN_CENTER_HORIZONTAL end
        if a.halign == s.left   then flag = flag + wx.wxALIGN_LEFT end
        if a.halign == s.right  then flag = flag + wx.wxALIGN_RIGHT end
        local proportion = ((a.stretch == true) and 1) or a.stretch or 0
        
        targetSizer:Add(part.wx, proportion, flag)
    end
end

function main()
    -- Prepare the window.
    local frame = wea.Frame{ 'Switched-panel test' }
    frame:Show(true)
    
    -- Prepare the panel.
    wea.LayoutBuilder{
        wea.Vbox{
            wea.Label{
                'Hello, world',
                valign = wea.s.center,
                halign = wea.s.center,
                stretch = true
            },
            wea.Hbox{
                wea.Spacer{ stretch = true },
                wea.Button "&OK",
                wea.Button "&Cancel"
            }
        }
    }
    :apply_to(frame)
    
    
    
    -- Call wx.wxGetApp():MainLoop() last to start the wxWidgets event loop,
    -- otherwise the wxLua program will exit immediately.
    -- Does nothing if running from wxLua, wxLuaFreeze, or wxLuaEdit since the
    -- MainLoop is already running or will be started by the C++ program.
    wx.wxGetApp():MainLoop()
end

main()
