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

package.path = package.path .. ';../src/?.lua'

require "wx"
local wea = require "wea"

require "wea.RichProgressDialog"

function main()
    local progressDialog = wea.RichProgressDialog(2)
    
    progressDialog.panes[1].label:SetLabel 'Parsing...'
    progressDialog.panes[2].label:SetLabel 'Rendering...'
    progressDialog.panes[2].percentLabel:SetLabel '0%'
    
    progressDialog.wx:Show(true)
    
    
    
    -- Call wx.wxGetApp():MainLoop() last to start the wxWidgets event loop,
    -- otherwise the wxLua program will exit immediately.
    -- Does nothing if running from wxLua, wxLuaFreeze, or wxLuaEdit since the
    -- MainLoop is already running or will be started by the C++ program.
    wx.wxGetApp():MainLoop()
end

main()

