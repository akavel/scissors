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

--[[[
File: canvas.lua
]]--

local wx = require "wx"
local wea = require "wea"
local oo = require "loop.simple"  -- Object Oriented facilities for Lua
local ids = require "lib/ids"

local ipairs = ipairs
local pairs = pairs
local min = math.min
local max = math.max
local string = string

module(...)

--[[[
Class: canvas.CanvasViewport
]]--
CanvasViewport = oo.class{}

--[[[
Constructor: CanvasViewport(parentWxWindow)
]]--
function CanvasViewport:__init(parent)
    local o = {
        wx = wx.wxScrolledWindow(parent, 
            wx.wxID_ANY, 
            wx.wxDefaultPosition, 
            wx.wxDefaultSize, --wx.wxSize(300,200)),
            wx.wxHSCROLL + wx.wxVSCROLL + 
            wx.wxBORDER_SUNKEN
            --wx.wxBORDER_SIMPLE
            --wx.wxBORDER_STATIC
            --wx.wxBORDER_DOUBLE
            )
    }
    o.painterResizedCallback = function()
        o:OnPainterResized()
    end

    o.wx:Connect(wx.wxEVT_PAINT, function(evt) o:OnPaint(evt) end)
    
    -- The unit increment by which the scrollbars move.
    o.wx:SetScrollRate(5,5)
    
    return oo.rawnew(self, o)
end

--[[[
Method: setPainter(self, painter)
Sets the object used to render the contents of the window
visible through the viewport.

The 'painter' argument must implement the following interface:
* 'getPictureBounds(self)' - a method returning an array of four numbers:
  {x0, y0, x1, y1}, specifying the currently most extreme coordinates of the image area.
* 'paintOn(self, dc, region)' - draws the painting; 'dc' is a wxDC object; 'region' is a
  'wxRegion' object and specifies the coordinates of the sub-area to be drawn.
* 'resized' - an Event object, which should be raised when the contents of the painting
  changed.
]]--
function CanvasViewport:setPainter(painter)
    if self.painter then
        self.painter.resized:remove(self.painterResizedCallback)
    end
    self.painter = painter
    if self.painter then
        self.painter.resized:add(self.painterResizedCallback)
    end
    self.painterResizedCallback()
end

function CanvasViewport:_getPictureBounds()
    return self.painter and self.painter:getPictureBounds() or {0,0,0,0}
end

--[[[
Method: OnPainterResized(self)
]]--
function CanvasViewport:OnPainterResized()
    local bbox = self:_getPictureBounds()
    self.wx:SetVirtualSize(
        bbox[3]-bbox[1], 
        bbox[4]-bbox[2] )
    self:Repaint()
end

--[[[
Method: Repaint(self)
]]--
function CanvasViewport:Repaint()
    self.wx:Refresh()
end

--[[[
Method: OnPaint(self, evt)
]]--
function CanvasViewport:OnPaint(evt)
    -- ALWAYS create wxPaintDC in wxEVT_PAINT handler, even if unused
    local dc = wx.wxPaintDC(self.wx)
    
    if self.painter then
    
        -- Retrieve the area which we must redraw.
        local region = self.wx:GetUpdateRegion():GetBox()
        
        -- Calculate transformations to map the virtual canvas to window area
        local x0,y0 = self.wx:GetViewStart()
        local xu,yu = self.wx:GetScrollPixelsPerUnit()
        
        local bbox = self:_getPictureBounds()
        x0 = x0*xu + bbox[1]
        y0 = y0*yu + bbox[2]
        
        dc:SetDeviceOrigin(-x0, -y0)
        
        region:Offset(x0, y0)
        
        self.painter:paintOn(dc, region)
        
        -- Cleanup.
        dc:SetPen(wx.wxNullPen)
        dc:SetBrush(wx.wxNullBrush)
        
    end
    
    -- ALWAYS delete() any wxDCs created when done
    dc:delete()
end

--[[[
Method: scrollToTopLeft(self)
]]--
function CanvasViewport:scrollToTopLeft()
    self.wx:Scroll(0, 0)
end

--[[[
Method: scrollToCenter(self)
]]--
function CanvasViewport:scrollToCenter()
    -- Center the viewport on the underlying painter
    local scrolledWindow = self.wx
    local virtW, virtH = scrolledWindow:GetVirtualSizeWH()
    local unitX, unitY = scrolledWindow:GetScrollPixelsPerUnit()
    local clientW, clientH = scrolledWindow:GetClientSizeWH()
    local newX = (virtW - clientW) / 2 / unitX
    local newY = (virtH - clientH) / 2 / unitY
    scrolledWindow:Scroll(newX, newY)
end
