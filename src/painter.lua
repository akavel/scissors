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
File: painter.lua
]]--

local wx = require "wx"
local wea = require "wea"
local oo = require "loop.simple"  -- Object Oriented facilities for Lua
local canvas = require "canvas"
local ids = require "lib/ids"
local event = require "lib/event"

local ipairs = ipairs
local pairs = pairs
local min = math.min
local max = math.max
local string = string

module(...)

------------------------------
------------------------------

--[[[
Class: painter.CanvasPainter
]]--
CanvasPainter = oo.class{}

function CanvasPainter:__init()
    local o = {
        genId = ids.Generator(),
        shapes = {},
        drawingListStart = {},
        bbox = {0,0,0,0},  -- most extreme shape edges
        currentColors = {},
        margin = 5,
        resized = event.Event()
    }
    o.drawingListEnd = o.drawingListStart
    
    return oo.rawnew(self, o)
end

--[[[
Method: Clean(self)
]]--
function CanvasPainter:Clean()
    self.shapes = {}
    self.drawingListStart = {}
    self.bbox = {0,0,0,0}
    self.drawingListEnd = self.drawingListStart
    
--    self.wx:Scroll(0, 0)
    self.resized:raise()
end

--[[[
Method: paintOn(self, dc, region)
]]--
function CanvasPainter:paintOn(dc, region)
    -- We received a new DC, so we must reset the old colors cache.
    self.currentColors = {}
    
    -- Draw the shapes from the list.
    self.dc = dc
    local listNode = self.drawingListStart.next
    while listNode ~= nil do
        if region:Intersects(listNode.shape.bbox) then
            listNode.shape:drawOn(self)
        end
        listNode = listNode.next
    end
    self.dc = nil
end

--[[[
Method: getPictureBounds(self)
]]--
function CanvasPainter:getPictureBounds()
    return {
        self.bbox[1] - self.margin,
        self.bbox[2] - self.margin,
        self.bbox[3] + self.margin,
        self.bbox[4] + self.margin
    }
end

--[[[
Method: ExtendCanvasBbox(self, bboxAdded)
(Internal.)
]]--
function CanvasPainter:ExtendCanvasBbox(bboxAdded)
    self.bbox[1] = min(self.bbox[1], bboxAdded:GetLeft())
    self.bbox[2] = min(self.bbox[2], bboxAdded:GetTop())
    self.bbox[3] = max(self.bbox[3], bboxAdded:GetRight())
    self.bbox[4] = max(self.bbox[4], bboxAdded:GetBottom())
    
    self.resized:raise()
end

--[[[
Method: Add(self, shape)
]]--
function CanvasPainter:Add(shape)
    local s = shape
    
    -- Add the shape to the internal IDs list
    local id = self.genId()
    self.shapes[id] = s
    
    -- Add shape to the internal drawing list
    local newTail = {shape=s, next=nil}
    self.drawingListEnd.next = newTail
    self.drawingListEnd = newTail
    
    -- Build a wxRect based on the provided bbox for faster intersection calculations
    s.bbox = wx.wxRect(
        s.bbox[1], 
        s.bbox[2], 
        s.bbox[3]-s.bbox[1]+1,
        s.bbox[4]-s.bbox[2]+1)
    
    -- Update the boundaries of the virtual canvas containing all the shapes
    self:ExtendCanvasBbox(s.bbox)
    
    return id
end

--[[[
Method: SetColor(self, spec)

(Internal; for use by <shapes.Shape>-derived classes.)
Sets the foreground color used for drawing shapes
on the canvas.

Parameters:
 spec - a CSS/HTML-like specification of the colour.
  Example: "#ff0000" is red.
]]--
function CanvasPainter:SetColor(spec)
    if self.currentColors.fg ~= spec then
        -- Prepare new Pen object
        local color = wx.wxColour(spec)
        local pen = wx.wxPen(color, 1, wx.wxSOLID)
        color:delete()
        
        -- Apply the new Pen object
        self.dc:SetPen(pen)
        pen:delete()
        
        -- Remember the new settings
        self.currentColors.fg=spec
    end
end

--[[[
Method: SetBackgroundColor(self, spec)

See:
 <SetColor(self, spec)>
]]--
function CanvasPainter:SetBackgroundColor(spec)
    if self.currentColors.bg ~= spec then
        -- Prepare new Brush object
        local color = wx.wxColour(spec)
        local brush = wx.wxBrush(color, wx.wxSOLID)
        color:delete()
        
        -- Apply the new Brush object
        self.dc:SetBrush(brush)
        brush:delete()
        
        -- Remember the new settings
        self.currentColors.bg=spec
    end
end

function CanvasPainter:SetTextColor(spec)
    if self.currentColors.text ~= spec then
        -- Prepare new Colour object
        local color = wx.wxColour(spec)
        
        -- Apply the new Colour object
        self.dc:SetTextForeground(color)
        color:delete()
        
        -- Remember the new settings
        self.currentColors.text=spec
    end
end

--[[[
Method: GetBbox(self, shape)

Returns:
 bl,bt,br,bb - left, top, right and bottom coordinates of the bounding box
]]--
function CanvasPainter:GetBbox(shape)
    local rect = self.shapes[shape].bbox
    return rect:GetLeft(), rect:GetTop(), rect:GetRight(), rect:GetBottom()
end

--[[[
Method: MoveText(self, shape, dx, dy)
]]--
function CanvasPainter:MoveText(shape, dx, dy)
    local s = self.shapes[shape]
    s:move(dx, dy)
    s.bbox:Offset(dx, dy)    
    self:ExtendCanvasBbox(s.bbox)
end

--[[[
Method: Lower(self, shape)
Moves a shape behind all others in the drawing order.

Parameters:
 shape - the ID of the shape to be moved towards the background
]]--
function CanvasPainter:Lower(shape)
    local shape = self.shapes[shape]
    local listNode = self.drawingListStart
    local movedNode = nil
    while listNode.next ~= nil do
        if listNode.next.shape == shape then
            movedNode = listNode.next
            listNode.next = movedNode.next
            break
        end
        listNode = listNode.next
    end
    if movedNode ~= nil then
        -- if self.drawingListEnd == movedNode and self.drawingListStart.next ~= nil then
            -- self.drawingListEnd = listNode
        -- end
        movedNode.next = self.drawingListStart.next
        self.drawingListStart.next = movedNode

        -- If the removed element was the last one on the list, then
        -- the previous element becomes the new end of the list.
        if self.drawingListEnd == movedNode then
            self.drawingListEnd = listNode
        end
    end
end
