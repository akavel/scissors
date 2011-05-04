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
File: progress.lua
Methods related to displaying progress in Scissors.
]]--

local wea = require 'wea'
require 'wea.RichProgressDialog'
local math = math
local table = table
local _G = _G

module(...)

local dialog

--[[[
Function: groupDigits(value)
Formats a number into a string, grouping them by 3.
]]--
local function groupDigits(value)
    local t = {}
    local tins = table.insert
    local s = ('%d'):format(value)
    local i = #s % 3
    if i > 0 then
        tins(t, s:sub(1, i))
    end
    i = i+1
    while i+2 <= #s do
        tins(t, s:sub(i, i+2))
        i = i+3
    end
    return table.concat(t, ' ')
end

--[[[
Function: formatPercent(value, max)
Calculates the 'value/max' fraction in percents, and returns a properly formatted string.
]]--
local function formatPercent(value, max)
    return ('%d%%'):format(math.floor(value*100/max+0.5))
end

--[[[
Function: ProgressUpdater(dialog, i, labelFormat, max)
A helper function.
Builds an object, which allows access to a single pane of a
RichProgressDialog as if it was a separate, independent progress dialog.
]]--
local function ProgressUpdater(dialog, i, labelFormat)
    local slowDown = 0
    local pane = dialog.panes[i]
    local o = {
        SetRange = function(self, max)
            self.max = max
            pane.progressBar:SetRange(max)
        end,
    
        Update = function(self, value)
            if slowDown <= 0 then
                slowDown = 50
                pane.progressBar:SetValue(value)
                pane.percentLabel:SetLabel(formatPercent(value, self.max))
                pane.label:SetLabel(labelFormat:format(groupDigits(value), groupDigits(self.max)))
            else
                slowDown = slowDown-1
            end
            return not dialog.cancelled
        end,
        
        Close = function(self)
            -- Move the progress bar to the "completed" position.
            -- (We shouldn't forget that we're cheating here a bit.)
            slowDown = 0
            self:Update(self.max)
        end,
    }
    -- After completing the last pane, the window should be dismissed.
    if i == #dialog.panes then
        o.Close = function(self)
            dialog.wx:Destroy()
        end
    end
    return o
end

function ParsingProgressDialog(dialog)
    return ProgressUpdater(dialog, 1, 'Parsing... %s / %s B')
end

--[[[
Function: RenderingProgressDialog(max)
A custom constructor for a dialog used by Scissors
to display XML rendering progress information.
]]--
function RenderingProgressDialog(dialog)
    return ProgressUpdater(dialog, 2, 'Rendering... %s / %s nodes')
end

--[[[
Function: ScissorsProgressDialog()
A custom constructor for a dialog used by Scissors
to display XML parsing progress information.
]]--
function ScissorsProgressDialog(resources)
    local dialog = wea.RichProgressDialog(2, true)
    
    dialog.panes[1].label:SetLabel 'Parsing...'
    dialog.panes[1].percentLabel:SetLabel '0%'
    dialog.panes[1].progressBar:SetRange( 100 )
    dialog.panes[1].progressBar:SetValue( 0 )
    
    dialog.panes[2].label:SetLabel 'Rendering...'
    dialog.panes[2].percentLabel:SetLabel '0%'
    dialog.panes[2].progressBar:SetRange( 100 )
    dialog.panes[2].progressBar:SetValue( 0 )
    
    dialog.wx:SetTitle(('%s - Loading file'):format(resources.defaultTitle))
    
    dialog.cancelled = false
    
    dialog.cancelAction = function(self)
        self.cancelled = true
        self.cancelButton:Disable()
    end
    
    return dialog
end
