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

--local DEBUG=true

D = function() end

if DEBUG then
    local wx = require "wx"
    local wea = require "wea"
    local frame = wea.Frame{ title="Debug output" }
    local editBox = wx.wxTextCtrl(
        frame, wx.wxID_ANY, "",
        wx.wxDefaultPosition, wx.wxSize(400,300),
        wx.wxTE_MULTILINE + wx.wxTE_READONLY + wx.wxHSCROLL)
    local sizer = wx.wxBoxSizer(wx.wxVERTICAL)
    sizer:Add(editBox, 1, wx.wxEXPAND + wx.wxALL)
    frame:SetSizer(sizer)
    sizer:SetSizeHints(frame)
    frame:Show(true)
    
    D = function(...)
        editBox:AppendText(string.format(...))
    end
end

