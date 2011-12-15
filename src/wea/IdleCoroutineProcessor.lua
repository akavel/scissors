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

--[[[
File: IdleCoroutineProcessor.lua
]]--

local wx = require "wx"
local oo = require "loop.simple"  -- Object Oriented facilities for Lua

local coroutine = coroutine

module "wea"

--[[[
Class: wea.IdleCoroutineProcessor
Processes a coroutine during idle time of a window.
]]--
IdleCoroutineProcessor = oo.class{ 
--    __init=ctor_init,
    --[[[
    Field: workerThread
    This field can be assigned a coroutine which will
    be executed in idle time.
    ]]--
    workerThread = nil,
    workerThreadErrorHandler = nil
}

-- function IdleCoroutineProcessor:__ctor()
-- end

--[[[
Method: __init(self)
]]--
function IdleCoroutineProcessor:__init()
    return oo.rawnew(self, {})
end

--[[[
Method: ConnectTo(self, window)
]]--
function IdleCoroutineProcessor:ConnectTo(window)
    local function disable()
        self.workerThread = nil  -- clear the worker
        window:Disconnect(wx.wxEVT_IDLE)
    end

    -- Create a function processing the 'workerThread' coroutine in idle time
    window:Connect(wx.wxEVT_IDLE, function(event)
        if type(self.workerThread) ~= 'thread' then  -- implicitly checking if not nil
            disable()
            return
        end

        local success, err = coroutine.resume(self.workerThread)
        if coroutine.status(self.workerThread) == 'dead' then
            disable()
            
            -- If the thread ended because of an error, send it to the handler, if available.
            local errorHandler = self.workerThreadErrorHandler
            self.workerThreadErrorHandler = nil  -- clear the error handler
            if not success and errorHandler ~= nil then
                errorHandler(err)
            end
            return
        end

        event:RequestMore()
    end)
end
