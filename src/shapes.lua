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
File: shapes.lua
]]--

local wx = require "wx"
local oo = require "loop.simple"  -- Object Oriented facilities for Lua

local min = math.min
local max = math.max

module(...)

--[[[
Class: shapes.Shape
(internal) Base class for various primitives which can be
drawn on a <painter.CanvasPainter>.
]]--
Shape = oo.class{}

function Shape:drawOn(canvas)
end

--[[[
Class: shapes.Circle
Draws a circle on a <painter.CanvasPainter>.

Example:
 To draw a circle at x=10, y=20 and with
 a radius of 5, you can use:
 > local painter = require "painter"
 > c = canvas:Add(shapes.Circle{ 10, 20, 5 })
 or:
 > c = canvas:Add(shapes.Circle{ x=10, y=20, r=5, color="#000000", background="#ffffff" })
]]--
Circle = oo.class({}, Shape)

function Circle:__init(args)
    -- TODO: verify the bbox correctness!
    return oo.rawnew(self, {
        x=args[0] or args.x, 
        y=args[1] or args.y, 
        r=args[2] or args.r, 
        color=args.color or args.colour,
        background=args.background or args.bg or args.bgColor or args.backgroundColor,
        bbox={x-r, y-r, x+r, y+r}
    })
end

function Circle:drawOn(canvas)
    canvas:SetColor(self.color)
    canvas:SetBackgroundColor(self.background)
    canvas.dc:DrawCircle(self.x, self.y, self.r)
end



--[[[
Class: shapes.Text
Renders a line of text on a <painter.CanvasPainter>.

Example:
 > local painter = require "painter"
 > t = canvas:Add(shapes.Text{10, 20, "foo bar", font=someFont, color=someColor})
Example:
 > someFont = wx.wxFont.New(...)
 > t = canvas:Add(shapes.Text{x=10, y=20, text="foo bar", font=someFont, color=someColor})
]]--
Text = oo.class({}, Shape)

-- Internal objects required to let us somehow calculate
-- the bounding box when drawing text.
Text.tmpBmp = wx.wxBitmap(2,2)
Text.tmpDc = wx.wxMemoryDC(Text.tmpBmp)

function Text:__init(args)
    local x = args[1] or args.x
    local y = args[2] or args.y
    local text = args[3] or args.text
    local font = args.font
    local w, h = self.tmpDc:GetTextExtent(text, font)
    return oo.rawnew(self, {
        x=x,
        y=y,
        text=text,
        font=font,
        color=args.color or args.colour,
        bbox={x, y, x+w-1, y+h-1}
    })
end

function Text:drawOn(canvas)
    canvas.dc:SetFont(self.font)
    canvas:SetTextColor(self.color)
    canvas.dc:DrawText(self.text, self.x, self.y)
end

function Text:move(dx, dy)
    self.x = self.x + dx
    self.y = self.y + dy
end

--[[[
Class: shapes.Line
]]--
Line = oo.class({}, Shape)

function Line:__init(args)
    local s = {"line",
        x0=args[1], y0=args[2],
        x1=args[3], y1=args[4],
        color=args.color or args.colour,
    }
    s.bbox = {
        min(s.x0, s.x1), min(s.y0, s.y1),
        max(s.x0, s.x1), max(s.y0, s.y1)
    }
    return oo.rawnew(self, s)
end

function Line:drawOn(canvas)
    canvas:SetColor(self.color)
    canvas.dc:DrawLine(self.x0, self.y0, self.x1, self.y1)
end


--[[[
Class: shapes.Rectangle
]]--
Rectangle = oo.class({}, Shape)

function Rectangle:__init(args)
    return oo.rawnew(self, {
        color=args.color or args.colour,
        background=args.background or args.bg or args.bgColor or args.backgroundColor,
        bbox={
            args.x0 or args[1], 
            args.y0 or args[2], 
            args.x1 or args[3], 
            args.y1 or args[4]
        }
    })
end

function Rectangle:drawOn(canvas)
    canvas:SetColor(self.color)
    canvas:SetBackgroundColor(self.background)
    canvas.dc:DrawRectangle(
        self.bbox:GetX(), self.bbox:GetY(),
        self.bbox:GetWidth(), self.bbox:GetHeight()
    )
end
