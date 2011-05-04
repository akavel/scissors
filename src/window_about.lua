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
File: window_about.lua

The "About..." window for Scissors.
]]--

local wx = require "wx"
local wea = require "wea"

module(...)

function ShowModalAt(frame, resources)
    local defaultFontSize = wea.SystemSettings.GetFont(wea.sys.DefaultGuiFont):GetPointSize() + 2
    local font1 = wea.Font{ weight="bold", size=defaultFontSize+2 }
    local font2 = wea.Font{ size=defaultFontSize }
    local font3 = wea.Font{ size=defaultFontSize-2 }
    local font4 = wea.Font{ weight="bold", size=defaultFontSize }
    local border1 = 12
    local border2 = 15
    local border3 = 10
    local backgroundColor = wea.Color("#ffffdd")
    
    local frame = wea.Dialog
    {
        "wEa layout test app",
        layout = wea.Vbox
        {
         wea.Panel
         {
         background = backgroundColor,
         expand = true;
         layout = wea.Vbox
          {
        -- wea.ScrolledWindow
        -- {
            -- style = 'vscroll',
            -- size = wea.Size{400, 300},
            -- expand = true;
        -- layout = wea.Vbox
        -- {
            expand = true;
            wea.Spacer(0, 70),
            wea.Hbox
            {
                expand = true;
                wea.StretchSpacer(),
                wea.Vbox
                {
                    align = 'right';
                    wea.StretchSpacer(),
                    wea.Panel
                    {
                        background = wea.Color(0xddddff),
                        border = border1;
                        layout = wea.Vbox
                        {
                            wea.Panel
                            {
                                border = border2;
                                layout = wea.Hbox
                                {
                                    wea.Spacer(border3, 0),
                                    -- WARNING: wxWidgets docs suggest not to use StaticBitmap for images 
                                    -- larger than 64x64 px!
                                    wea.StaticBitmap
                                    {
                                        border = {8, 'right', 'top', 'bottom'};
                                        resources.imageObjects.logo
                                    },
                                    wea.Vbox
                                    {
                                        wea.StaticText{ "Scissors XML Viewer", font=font1 },
                                        wea.StaticText{ "version 1.0 - 2009.10.31", font=font2 },
                                    },
                                    wea.Spacer(border3, 0)
                                },
                            }
                        }
                    },
                    wea.Hbox
                    {
                        align = 'right',
                        wea.Vbox
                        {
                            wea.StaticText{ "Copyright (c) 2009 by", font=font3, align="right" },
                            wea.StaticText{ "Mateusz Czaplinski", font=font4, align="right" },
                            wea.StaticText{ "mateusz@czaplinski.pl", font=font3, align="right" },
                            wea.StretchSpacer()
                        },
                        wea.Spacer( 10, 0 ),
                        wea.StaticBitmap(resources.imageObjects.authorLogo),
                        wea.Spacer( border1, 0 )
                    }
                }
            },
            wea.TextCtrl{ 
                border=border1, expand=true, background = backgroundColor;
                style={'multiline', 'readonly', 'rich', 'border-none'};
wea.TextAttr{font=font2}, 'The author wants to give ', 
wea.TextAttr{font=font1}, 'Great Thanks', 
wea.TextAttr{font=font2}, ' to all the authors and contributors of: ',
wea.TextAttr{color=wea.Color"#3333aa", font=font2}, 
'Lua, Lua for Windows, wxWidgets, wxLua, Notepad++, Mercurial, TortoiseHg, NaturalDocs, yEd Graph Editor',
wea.TextAttr{color=wea.Color"#000000", font=font2},
[[ - these wonderful tools were all used extensively in making of XML Scissors.
This app also uses the ]],
wea.TextAttr{color=wea.Color"#3333aa", font=font2},'Silk Icons',
wea.TextAttr{color=wea.Color"#000000", font=font2},[[:
http://www.famfamfam.com/lab/icons/silk/

Also, Thanks to God.]]};
                code=function(o, args)
                    -- o.wx:SetSize(wea.Size{)
                end;
          }
         },
         wea.Button
         {
            align = {'center-horizontal'},
            border = 7,
            id = wx.wxID_OK,
            code = function(o, args)
                o.wx:SetDefault()
                o.wx:SetFocus()
                o.wx:Connect(wx.wxEVT_COMMAND_BUTTON_CLICKED, function()
                    o.wx:GetParent():Close()
                end)
            end;
            "OK" 
         },
        }
        -- }
        -- }
    }
--    frame.wx:SetSize(wea.Size{400, 300})
    frame.wx:SetSize(wea.Size{400, -1})
    frame.wx:Show()
    frame.wx:Connect(wx.wxEVT_CLOSE_WINDOW, function()
        frame.wx:Destroy()
    end)
end
