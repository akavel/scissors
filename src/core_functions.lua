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
File: core_functions.wlua
Top-level code of the Scissors XML Viewer application.
]]--

-- GUI modules
require "wx"
require "wea"
require "wea.IdleCoroutineProcessor"
require "canvas"
require "canvas_dragging"
require "painter"
require "painter_title"
require "progress"
require "window_about"

-- XML modules
local xmlh = require "xmlh_Chakravarti"
require "NodeIdTracker"

-- other modules
local renderer = require "renderer"
local oo = require "loop.simple"  -- Object Oriented facilities for Lua

-- other required imports from the global namespace
local arg = _G.arg

function load_xml(fname, progressDialog)
--[[
    local fname = fname or (arg and arg[1]) or '../sample-data/common.tmp'
]]
    if fname then
        local fh = io.open(fname)
        if fh then
            local text = fh:read('*a')
            -- print('text='..string.sub(text, 100))
            
            -- Preparing a progress information dialog
            progressDialog:SetRange(#text)
            xmlh.progressCallback = function(position)
                local continue = progressDialog:Update( position )
                if not continue then
                    error('Cancelled by user.', 0)
                end
                coroutine.yield()
            end
            
            -- Parsing.
            local doc = xmlh.parse(text)
            
            -- Cleanup and result return
            progressDialog:Close()        
            return doc
        end
    end
--[[
    return nil -- could not successfully parse the file
]]
-- [=[
    local doc = xmlh.parse([[
<root>
    <ch1/>
    <ch2 attr='val' attrib2='v2'>
        text <ch3/>
        line1]]..'                       '..[[

        line2
    </ch2>
    <!-- a comment -->
</root>]])
    return doc
-- ]=]
end

function prepare_window()

    -- Create the window.
    frame = wea.Frame{ resources.defaultTitle, size={800,600} }
    
    local ico16 = wx.wxIcon()
    ico16:CopyFromBitmap(wx.wxBitmap(resources.icon16))
    frame.wx:SetIcon(ico16)
    
    return frame
end

function prepare_resources(resources)
    local imageObjects = {
        logo = wx.wxBitmap(resources.icon16),
        navigationHint = load_embedded_image(resources.titleImage),
        authorLogo = load_embedded_image(resources.authorLogoImage),
        
        refreshIcon = load_embedded_image(resources.refreshIcon),
    }
    resources.imageObjects = imageObjects

    -- -- Registering the images for use in the 'wxHtmlWindow'
    -- wx.wxMemoryFSHandler.AddFile('logo', imageObjects.logo, wx.wxBITMAP_TYPE_XPM)
    -- wx.wxMemoryFSHandler.AddFile('authorLogo', imageObjects.authorLogo, wx.wxBITMAP_TYPE_PNG)
    -- wx.wxFileSystem.AddHandler(wx.wxMemoryFSHandler())
end

local function do_load_file(filePath, canvasViewport, resources)
    local succeeded
    -- Prepare a progress dialog.
    local progressDialog = progress.ScissorsProgressDialog(resources)
    local idleProcessor = wea.IdleCoroutineProcessor()
    idleProcessor:ConnectTo(progressDialog.wx)
    -- Create a thread which will load, parse and render the file.
    idleProcessor.workerThread = coroutine.create(function()
        --canvasViewport:setPainter(nil)
        -- frame:SetTitle(('%s - %s'):format(dialog:GetFilename(), defaultTitle))
        local doc = load_xml(filePath, progress.ParsingProgressDialog(progressDialog))
        local canvasPainter = painter.CanvasPainter()
        render_xml(doc, canvasPainter, progress.RenderingProgressDialog(progressDialog))
        local fileName = wx.wxFileName(filePath):GetFullName()
        frame.wx:SetTitle(('%s - %s'):format(fileName, resources.defaultTitle))
        canvasViewport:setPainter(canvasPainter)
        canvasViewport:scrollToTopLeft()
        succeeded = true
    end)
    -- Prepare a handler for errors while loading the file.
    idleProcessor.workerThreadErrorHandler = function(err)
        print(('File could not be loaded. Reason:\n%s'):format(err))
        progressDialog.wx:Destroy()
        --frame:SetTitle(defaultTitle)
        --show_title_image(canvasViewport)
    end
    progressDialog.wx:ShowModal()
    return succeeded
end

function prepare_menu(frame, canvasViewport, resources)
    local currentFilePath
    -- Create the menu.
    local menu = wea.MenuBarBuilder{
        {"&File",
            {"&New window\tCtrl-N", handler=function(event)
                -- Collecting the command line required to run a twin process
                local i=0
                while arg[i-1] do
                    i = i - 1
                end
                local t = {}
                for i=i,0 do
                    table.insert(t, arg[i])
                end
                local cmd = table.concat(t, ' ')
                local process = wx.wxProcess()
                -- It seems we must set up a dummy handler to avoid errors on exit
                process:Connect(wx.wxEVT_END_PROCESS, function(event) end)
                wx.wxExecute(cmd, wx.wxEXEC_ASYNC, process)
                process:Detach() -- should we use it or not?
            end},
            {"&Open...\tCtrl-O", '_OPEN', handler=function(event)
                local dialog = wx.wxFileDialog(frame.wx)
                dialog:SetWildcard("All files|*|XML files (*.xml)|*.xml")
                if 
                    dialog:ShowModal() == wx.wxID_OK
                    and do_load_file(dialog:GetPath(), canvasViewport, resources)
                then
                    currentFilePath = dialog:GetPath()
                end
            end},
            {"&Refresh\tCtrl-R", handler=function(event)
                do_load_file(currentFilePath, canvasViewport, resources)
            end},
            {"E&xit\tCtrl-Q", '_EXIT', handler=function(event)
                frame.wx:Close()
            end},
        },
        {"&Help",
            {"&About...", handler=function(event)
                window_about.ShowModalAt(frame.wx, resources)
            end },
        }
    }
    menu:apply_to(frame.wx)

    return menu
end

function prepare_toolbar(frame, menu, resources)
    local toolBar = frame.wx:CreateToolBar(wx.wxNO_BORDER + wx.wxTB_FLAT + wx.wxTB_DOCKABLE)
    -- [From: editor.lua] note: Usually the bmp size isn't necessary, but the HELP icon is not the right size in MSW
    local toolBmpSize = toolBar:GetToolBitmapSize()
    toolBar:AddTool(
        menu.menubar.File.New_window.id,
        "New window", 
        wx.wxArtProvider.GetBitmap(wx.wxART_NORMAL_FILE, wx.wxART_MENU, toolBmpSize), 
        "Create new empty window")
    toolBar:AddTool(
        --wx.wxID_OPEN,
        menu.menubar.File.Open.id,
        "Open", 
        wx.wxArtProvider.GetBitmap(wx.wxART_FILE_OPEN, wx.wxART_MENU, toolBmpSize), 
        "Open an existing document")
    toolBar:AddTool(
        menu.menubar.File.Refresh.id,
        "Refresh",
        resources.imageObjects.refreshIcon,
        "Reload the current document from disk")
    toolBar:Realize()
end

function prepare_canvas(frame)
    
    -- Add a Canvas component.
    local canvasViewport = canvas.CanvasViewport(frame.wx)
    local sizer = wx.wxBoxSizer(wx.wxVERTICAL)
    sizer:Add(
        canvasViewport.wx,
        1,
        wx.wxEXPAND + wx.wxALL)

    -- Add the Canvas to the main window
    frame.wx:SetSizer(sizer)
    sizer:SetSizeHints(frame.wx)
    frame.wx:SetSize(800, 600)
    
    -- Enable navigation by mouse dragging
    local dragging = CanvasDraggingController(canvasViewport.wx)
    dragging:connect()
    dragging:setMultipliers(2, 2)

    return canvasViewport
end

--[[[
Function: render_xml(doc, canvas, progressDialog)
Builds a graphical representation of an XML tree
in a wEa <painter.CanvasPainter> component.
]]--
function render_xml(doc, canvas, progressDialog)
    canvas:Clean()
    local x, y = 0, 0
    local fontHeightPoints = 15
    
    local resources = {
        canvas = canvas,
        
        font1 = wx.wxFont.New(10, wx.wxFONTFAMILY_SWISS, wx.wxFONTSTYLE_NORMAL,
            wx.wxFONTWEIGHT_NORMAL, false, "Arial"),
        font2 = wx.wxFont.New(10, wx.wxFONTFAMILY_SWISS, wx.wxFONTSTYLE_NORMAL,
            wx.wxFONTWEIGHT_BOLD, false, "Arial"),
        font3 = wx.wxFont.New(10, wx.wxFONTFAMILY_SWISS, wx.wxFONTSTYLE_NORMAL,
            wx.wxFONTWEIGHT_NORMAL, false, "Lucida Console"),
        font4 = wx.wxFont.New(10*0.7, wx.wxFONTFAMILY_SWISS, wx.wxFONTSTYLE_NORMAL,
            wx.wxFONTWEIGHT_NORMAL, false, "Arial"),
            
        colorLine           = "#777777",
        colorAttrKey        = "#000000",
        colorAttrValue      = "#000088",
        colorElementNode    = "#000000",
        colorTextNode       = "#006600",  -- "#008800"
        colorTextNodeBg     = "#ffffff",
        colorTextNodeBrd    = "#000000",
        colorCommentNode    = "#333333",
        colorCommentNodeBg  = "#bbbbbb",
        colorCommentNodeBrd = "#bbbbbb",
        colorNodeId         = "#bbbb77",
            
    }
    
    -- Preparing a callback function to display rendering progress
    progressDialog:SetRange(
        xmlh.getTotalNodesCount(doc) + 1  -- +1 is for the 'root' node
    )
    renderer.progressCallback = function(position)
        local continue = progressDialog:Update( position )
        if not continue then
            error('Cancelled by user.', 0)
        end
        coroutine.yield()
    end
        
    -- Preparing a coroutine rendering the XML nodes to the Canvas
    renderer:render(xmlh.documentElement(doc), xmlh, resources, x, y, fontHeightPoints,
            NodeIdTracker())
                
    -- Cleanup etc.
    progressDialog:Close()
end

function load_embedded_image(data)
    local inputStream = wx.wxMemoryInputStream(data, #data)
    local image = wx.wxImage()
    image:LoadFile(inputStream)
    local bitmap = wx.wxBitmap(image)
    return bitmap
end

function show_title_image(canvasViewport, imageObjects)
    local painter = painter_title.TitlePainter(imageObjects.navigationHint, imageObjects.authorLogo)
    painter:ResizeToEnableScrolling(canvasViewport.wx:GetClientSizeWH())
    canvasViewport:setPainter(painter)
    canvasViewport:scrollToCenter()
end
