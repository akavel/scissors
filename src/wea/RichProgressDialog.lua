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

require "wx"
local wea = require "wea"

local border = 4

local function progressPane(dialog)
    local progressDialog = {}
    progressDialog.label = wx.wxStaticText(
        dialog, wx.wxID_ANY,
        'Progress...')
    progressDialog.percentLabel = wx.wxStaticText(
        dialog, wx.wxID_ANY,
        '100%')
    progressDialog.progressBar = wx.wxGauge(
        dialog, wx.wxID_ANY,
        100)
    
    -- Prepare the panel.
    local percentSizer = wx.wxBoxSizer(wx.wxHORIZONTAL)
    percentSizer:Add(progressDialog.percentLabel, 
        0, --[[wx.wxFIXED_MINSIZE +]] wx.wxALIGN_RIGHT + wx.wxALIGN_CENTER_VERTICAL + wx.wxALL, border)
    percentSizer:Add(progressDialog.progressBar, 1, wx.wxEXPAND + wx.wxALL, border)
    local mainSizer = wx.wxBoxSizer(wx.wxVERTICAL)
    mainSizer:Add(progressDialog.label, 0, wx.wxEXPAND + wx.wxALL, border)
    mainSizer:Add(percentSizer, 1, wx.wxEXPAND)
    
    progressDialog.wx = mainSizer
    
    return progressDialog
end

function wea.RichProgressDialog(barsCount, allowMinimize)
    -- Prepare the window and the main layout sizer.
    local style = {'caption', 'resize-border', 'system-menu', 'close-box'}
    if allowMinimize then
        style[#style+1] = 'minimize-box'
    end
    local dialog = wea.Dialog{ 'Custom progress dialog test',
        style = style}
    local mainSizer = wx.wxBoxSizer(wx.wxVERTICAL)
    
    -- Build the progress-bar panes.
    local panes = {}
    for i=1,barsCount do
        local pane = progressPane(dialog.wx)
        table.insert(panes, pane)
        mainSizer:Add(pane.wx, 0, wx.wxEXPAND)
    end
    
    -- Build the "cancel" button pane.
    local paneCancel = wx.wxStdDialogButtonSizer()
    local buttonCancel = wx.wxButton(dialog.wx, wx.wxID_CANCEL,
        '&Cancel')
    paneCancel:AddButton(buttonCancel)
    paneCancel:Realize()
    mainSizer:AddStretchSpacer(1)
    mainSizer:Add(paneCancel, 0, wx.wxEXPAND + wx.wxALL, border)
    
    -- Final adjustments of the layout.
    for i=1,barsCount do
        -- Make each 'percent label' non-shrinkable.
        mainSizer:SetItemMinSize(panes[i].percentLabel, panes[i].percentLabel:GetSizeWH())
    end
    mainSizer:SetMinSize(300, 0)
    
    -- Application of the layout on the window.
    dialog.wx:SetSizer(mainSizer)
    mainSizer:SetSizeHints(dialog.wx)
    
    -- Build the interface for the final user.
    local dialogWrapper = {
        panes = panes,
        wx = dialog.wx,
        cancelButton = buttonCancel,
        cancelAction = function(self) end,
        minimizeAction = function(self) end
    }
    
    -- Link the 'cancel' & 'close window' buttons to a user specified action.
    local closeFunction = function()
        dialog.wx:Destroy()
        dialogWrapper:cancelAction()
    end
    dialog.wx:Connect(wx.wxID_CANCEL, wx.wxEVT_COMMAND_BUTTON_CLICKED, closeFunction)
    dialog.wx:Connect(wx.wxEVT_CLOSE_WINDOW, closeFunction)
    
    return dialogWrapper
end

