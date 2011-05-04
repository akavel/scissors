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
File: painter_title.lua
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
Class: painter_title.TitlePainter
Implements the interface required by the <canvas.CanvasViewport.setPainter(self, painter)>
function.
]]--
TitlePainter = oo.class{}

--[[[
Constructor: __init(self, mainBitmap, logoBitmap)
]]--
function TitlePainter:__init(mainBitmap, logoBitmap)
    local o = {
        mainBitmap = mainBitmap,
        logoBitmap = logoBitmap,
        margin = 100,
        resized = event.Event(),
    }
    
    return oo.rawnew(self, o)
end

--[[[
Method: paintOn(self, dc, region)
]]--
function TitlePainter:paintOn(dc, region)
    -- Center the image in the viewport
    local sizeBitmap = self:GetMainBitmapSize()
    local sizeTotal = self.size
    local x = (sizeTotal.w - sizeBitmap.w) / 2
    local y = (sizeTotal.h - sizeBitmap.h) / 2
    
    -- Draw the main image in the center
    dc:DrawBitmap(self.mainBitmap, x, y, true)
    
    -- Draw the logo (if available) in the bottom-right corner
    if self.logoBitmap then
        local sizeLogo = { 
            w = self.logoBitmap:GetWidth(), 
            h = self.logoBitmap:GetHeight()
        }
        local xLogo = sizeTotal.w - 1.4*self.margin - sizeLogo.w
        local yLogo = sizeTotal.h - 1.4*self.margin - sizeLogo.h
        dc:DrawBitmap(self.logoBitmap, xLogo, yLogo, true)
    end
end

--[[[
Method: getPictureBounds(self)
]]--
function TitlePainter:getPictureBounds()
    return {
        0, 0,
        self.size.w, self.size.h
    }
    -- local sizeMain = self:GetMainBitmapSize()
    -- return {
        -- 0 - self.margin,
        -- 0 - self.margin,
        -- sizeMain.w + self.margin,
        -- sizeMain.h + self.margin
    -- }
end

--[[[
Method: GetMainBitmapSize(self)
]]--
function TitlePainter:GetMainBitmapSize()
    return {
        w = self.mainBitmap:GetWidth(),
        h = self.mainBitmap:GetHeight()
    }
end

--[[[
Method: ResizeToEnableScrolling(self, viewportWidth, viewportHeight)
Note:
 This method must be called at least once before the <getPictureBounds(self)> method is called.
]]--
function TitlePainter:ResizeToEnableScrolling(viewportWidth, viewportHeight)
    local sizeBitmap = self:GetMainBitmapSize()
    local sizeViewport = { w = viewportWidth, h = viewportHeight }
    
    local doubleMargin = self.margin * 2
    self.size = {
        w = max(sizeBitmap.w, sizeViewport.w + doubleMargin),
        h = max(sizeBitmap.h, sizeViewport.h + doubleMargin)
    }
    self.viewportSize = sizeViewport
    
    self.resized:raise()
end


