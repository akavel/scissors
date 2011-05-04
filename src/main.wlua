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
File: main.wlua
Entry code & components setup of the Scissors XML Viewer application.

Application overall architecture:
 (see ../design-notes/overall-architecture.png)
 XML parser - see: <xmlh_Chakravarti.parse(text)>
 XML tree - see: <xmlh_Chakravarti>
 XML renderer - see: <render_xml(doc, canvas, progressDialog)>, <renderer:render(node,xmlh,res,x,y,fontHPx,nodeIdTracker)>
 IShape - see: <shapes.Shape>
 CanvasViewport - see: <canvas.CanvasViewport>
 ICanvasPainter - see: <canvas.CanvasViewport.setPainter(self, painter)>
 CanvasPainter - see: <painter.CanvasPainter>
 TitlePainter - see: <painter_title.TitlePainter>


See also:
 <main()>
]]--

-- Paths to the libraries used in the development environment.
if arg[0] == 'main.wlua' then
    package.cpath = package.cpath..";./?.dll;./?.so;../lib/?.so;../lib/vc_dll/?.dll;../lib/bcc_dll/?.dll;../lib/mingw_dll/?.dll;"
    package.path = package.path..
    ";e:\\dnload\\lua\\lua\\?.lua"
end

-- Required modules
require "resources"
require "core_functions"

--[[-- Main --]]--
--[[[
Function: main()
The entry point of the Scissors XML Viewer application.
]]--
function main()
    prepare_resources(resources)
    local window = prepare_window()    
    local canvasViewport = prepare_canvas(window)
    local menu = prepare_menu(window, canvasViewport, resources)
    prepare_toolbar(window, menu, resources)
    show_title_image(canvasViewport, resources.imageObjects)
    window:Show(true)

    -- Call wx.wxGetApp():MainLoop() last to start the wxWidgets event loop,
    -- otherwise the wxLua program will exit immediately.
    -- Does nothing if running from wxLua, wxLuaFreeze, or wxLuaEdit since the
    -- MainLoop is already running or will be started by the C++ program.
    wea.run()
end

main()





--[=[
wea.Frame{ layout=
    wea.Hbox
    {
        {wea
        {wea.Button{"Ok"}, align=wea.s.right + wea.s.vcenter,
    }
}
--]=]

