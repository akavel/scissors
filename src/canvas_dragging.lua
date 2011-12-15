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
File: canvas_dragging.lua
]]--

local wx = require "wx"
local oo = require "loop.simple"  -- Object Oriented facilities for Lua

local SlidingThreshold = 0
local SlidingMultiplier = 0.3

--[[[
Class: CanvasDraggingController
Adds a "scroll by dragging the mouse" feature to a wxScrolledWindow.
When user clicks the left mouse button in the window's client area, and
then moves the mouse while still holding the button, the window's contents
are scrolled with the movement of the mouse.
]]--
CanvasDraggingController = oo.class{
    cursor = wx.wxCursor(wx.wxCURSOR_SIZING)
}

--[[[
Constructor: CanvasDraggingController(wxScrolledWindow)
]]--
function CanvasDraggingController:__init(wxScrolledWindow)
    local o = { 
        canvas = wxScrolledWindow,
        xm = 1, ym = 1 }
    return oo.rawnew(self, o)
end

--[[[
Method: CanvasDraggingController:setMultipliers(xm, ym)
]]--
function CanvasDraggingController:setMultipliers(xm, ym)
    self.xm = xm
    self.ym = ym
end

local function getMilliseconds()
    return wx.wxGetLocalTimeMillis():ToString() + 0
end

local function scroll(canvas, dx, dy)
    local sx, sy = canvas:GetViewStart()
    canvas:Scroll(sx + dx, sy + dy)
    local newsx, newsy = canvas:GetViewStart()
    return (newsx ~= sx or newsy ~= sy)
end

local function startScroller(canvas, dx, dy)
    local dx, dy = (dx or 0), (dy or 0)
    if dx == 0 and dy == 0 then
        return
    end
    
    local idleProcessor = wea.IdleCoroutineProcessor()
    idleProcessor:ConnectTo(canvas)

    local stop = false
    local function stopper()
        stop = true
    end

    local lastTime = getMilliseconds()
    idleProcessor.workerThread = coroutine.create(function()
        while not stop do
            local currentTime = getMilliseconds()
            if currentTime - lastTime > 10 then
                lastTime = currentTime

                if not scroll(canvas, dx, dy) then
                    return
                end
            end
            coroutine.yield()
        end
    end)
    -- Prepare a handler for errors while loading the file.
    idleProcessor.workerThreadErrorHandler = function(err)
    end
    
    return stopper
end

--[[[
Method: CanvasDraggingController:connect()
]]--
function CanvasDraggingController:connect()
    self.canvas:Connect(wx.wxEVT_LEFT_DOWN, function(e) self:_onLeftDown(e) e:Skip() end)
    self.canvas:Connect(wx.wxEVT_LEFT_UP,   function(e) self:_onLeftUp(e) end)
    self.canvas:Connect(wx.wxEVT_MOTION,    function(e) self:_onMove(e) end)
    -- self.canvas:Connect(wx.wxEVT_ENTER_WINDOW,    function(e) self:OnMove(e) end)
    -- self.canvas:Connect(wx.wxEVT_LEAVE_WINDOW,    function(e) self:OnMove(e) end)
    self.canvas:SetCursor(self.cursor)
end

function CanvasDraggingController:_onLeftDown(event)
    self.xOld, self.yOld = event:GetPositionXY()
    self.dxSlide, self.dySlide = 0, 0

    if self.scrollStopper then
        self.scrollStopper()
    end
end

function CanvasDraggingController:_onLeftUp(event)
    self.xOld, self.yOld = nil, nil

    local m = SlidingMultiplier
    self.scrollStopper = startScroller(self.canvas, self.dxSlide*self.xm*m, self.dySlide*self.ym*m)
end

function CanvasDraggingController:_onMove(event)
    if event:Dragging() then
        local x, y = event:GetPositionXY()
        local dx = x - (self.xOld or x) -- fall back to 0 if not initialized
        local dy = y - (self.yOld or y) 
        scroll(self.canvas, dx*self.xm, dy*self.xm)
        self.xOld = x
        self.yOld = y
        if dx*dx + dy*dy >= SlidingThreshold then
            self.dxSlide = dx
            self.dySlide = dy
        end
    end
end
