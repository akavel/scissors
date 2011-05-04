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
File: renderer.lua
]]--

local max = math.max
local min = math.min
local string = string
local ipairs = ipairs

require "string_utils"
local shapes = require "shapes"

--module(...)

--[[[
Object: renderer

A singleton object which contains methods for rendering a graphical
representation of a parsed XML document tree.
]]--
renderer = {}

--[[[
Function: renderer:render(node, xmlh, res, x, y, fontHPx, nodeIdTracker)
Renders an XML document on a graphical canvas.
The elements are shown as a flat tree.

Parameters:
 node - the XML tree node to start rendering from.
 xmlh - a reference to a helper module for manipulating the XML tree.
 res - a table specifying various resources and graphics parameters (see below).
 x, y - coordinates of a point on the canvas where the drawing should start.
 fontHPx - this should be the height of the font used for drawing text, in pixels.
 nodeIdTracker - an object used to calculate unique IDs of the XML nodes (see below).
 
The 'nodeIdTracker' argument must implement the following interface:
* 'getNewId(self)' - should return a string containing a unique ID for next XML element
  on the same depth level in the document (sibling).
* 'descend(self)' - should return a new object (implementing the same interface) which
  will generate IDs for elements 1 level deeper in the XML tree (children).
  
The 'res' parameter should have the following fields:
* 'colorLine', 'colorAttrKey', 'colorAttrValue', 'colorElementNode', 'colorTextNode', 'colorTextNodeBg', 'colorTextNodeBrd', 'colorCommentNode', 'colorCommentNodeBg', 'colorCommentNodeBrd', 'colorNodeId' - should be CSS-like strings specifying colours to be used for rendering of various features (e.g. "#000088" for dark blue).
* 'canvas' - should be a <painter.CanvasPainter> object used for rendering the XML tree.
* 'font1' - a wxFont used for attribute names.
* 'font2' - a wxFont used for elements and attribute values.
* 'font3' - a wxFont used for text nodes & likes.
* 'font4' - a wxFont used for node IDs.
]]--
function renderer:render(node, xmlh, res, x, y, fontHPx, nodeIdTracker)
    self.resources = res
    self.fontHPx = fontHPx
    self.currentElementIndex = 0 -- shows how many elements were processed
    self.cc = {}

    -- Parameters
    self.param = {
        d = 5, -- horz. line margin (at the ends)
        l = 20, -- horz. line segment length
        f = fontHPx / 2, -- vert. pos. of horz. lines relative to font bbox top
        attPad = 10, -- horizontal padding of attributes,
        xmlh = xmlh,
    }

    -- self.nodeIdTracker = nodeIdTracker
    self:_renderNode(node, x, y, nodeIdTracker)
end

--[[[
Function: renderer:_elementNode(x, y, node, nodeIdTracker)
(internal)
]]--
function renderer:_elementNode(x, y, node, nodeIdTracker)
    local res = self.resources

    -- Parameters
    local d = self.param.d
    local l = self.param.l
    local f = self.param.f
    local attPad = self.param.attPad
    local xmlh = self.param.xmlh

    local txt
    local bl,bt,br,bb
    
    -- display the node ID
    txt = res.canvas:Add(shapes.Text{ x, y, text=nodeIdTracker:getNewId(), 
        font=res.font4, color=res.colorNodeId })
    bl,bt,br,bb = res.canvas:GetBbox(txt)
    res.canvas:MoveText(txt, -(br-bl), -(bb-bt)+d)
    
    -- display the label
    local msg = xmlh.nodeName(node)
    txt = res.canvas:Add(shapes.Text{ x, y, text=msg, font=res.font2, color=res.colorElementNode })
    bl,bt,br,bb = res.canvas:GetBbox(txt)

    -- display all attributes
    local maxWidth = 0
    if xmlh.attributesLength(node) > 0 then
    
        -- "tree root line"
        local x0 = bl+attPad
        local y0 = bb+d
        res.canvas:Add(shapes.Line{x0, y0, x0, y0+f, color=res.colorLine})

        local y1 = y0
        local dy1 = 0
        -- local dy = 0
        for i=1, xmlh.attributesLength(node) do
            local att = xmlh.attributesItem(node, i)
            local dy,width = self:_renderNode(att, x0+l+d, y1, nodeIdTracker)
            if maxWidth < width then
                maxWidth = width
            end
            if dy > 0 then
                res.canvas:Add(shapes.Line{x0, y1+f, x0+l, y1+f, color=res.colorLine})
                dy1 = dy
                y1 = y1 + dy1
            end
        end
                
        -- "vertical connecting line"
        res.canvas:Add(shapes.Line{x0, y0+f, x0, y1-dy1+f, color=res.colorLine})

        bb = max(bb, y1)
    end
        
    -- display all child elements
    if xmlh.hasChildNodes(node) then
    
        -- "tree root line"
        local x0 = max(br+d, bl+attPad+l+d+maxWidth)
        local y0 = bt
        res.canvas:Add(shapes.Line{br+d, y0+f, x0+l, y0+f, color=res.colorLine})
        
        local y1 = y0
        local dy1 = 0
        -- local dy = 0
        for child in xmlh.childNodes(node) do
            local dy = self:_renderNode(child, x0+l+l+d, y1, nodeIdTracker:descend())
            if dy > 0 then
                res.canvas:Add(shapes.Line{x0+l, y1+f, x0+l+l, y1+f, color=res.colorLine})
                dy1 = dy
                y1 = y1 + dy1 + 2*d
            end
        end

        if y1 > y0 then
            y1 = y1 - 2*d
        end

        -- "vertical connecting line"
        res.canvas:Add(shapes.Line{x0+l, y0+f, x0+l, y1-dy1+f, color=res.colorLine})

        bb = max(bb, y1)
    end
    return bb-bt  -- bbox height
end

--[[[
Function: renderer:_attributeNode(x, y, node, nodeIdTracker)
(internal)
]]--
function renderer:_attributeNode(x, y, node, nodeIdTracker)
    local res = self.resources
    local bl,bt,br,bb
    local bt2, bb2
    local msg1, msg2, txt1, txt2
    local xmlh = self.param.xmlh
    
    -- Prepare the labels contents
    msg1 = xmlh.nodeName(node) .. ' = '
    msg2 = xmlh.nodeValue(node)
    
    -- Display the labels
    txt1 = res.canvas:Add(shapes.Text{ x,  y, text=msg1, font=res.font1, color=res.colorAttrKey })
    bl,  bt,  br,  bb  = res.canvas:GetBbox(txt1)
    txt2 = res.canvas:Add(shapes.Text{ br, y, text=msg2, font=res.font2, color=res.colorAttrValue })
    _,   bt2, br,  bb2 = res.canvas:GetBbox(txt2)
    
    -- Calculate the overall bounding box
    bb = max(bb,bb2)
    bt = min(bt,bt2)
    return bb-bt, br-bl  -- bbox height & width
    
end

--[[[
Function: renderer:_textNode(x, y, node, nodeIdTracker)
(internal)
]]--
function renderer:_textNode(x, y, node, nodeIdTracker)
    local res = self.resources
    local fontHPx = self.fontHPx
    local xmlh = self.param.xmlh

    -- Parameters
    local d = self.param.d
    local l = self.param.l
    local f = self.param.f
    local attPad = self.param.attPad

    -- Retrieving the text contents
    local msg = xmlh.data(node)
    
    -- Skipping empty text nodes
    if isspace(msg) or #msg == 0 then
        return 0
    end

    -- Selecting color scheme for normal text or comment nodes
    local colorFg, colorBg, colorBrd
    if xmlh.nodeType(node) == xmlh.COMMENT_NODE then
        colorFg  = res.colorCommentNode
        colorBg  = res.colorCommentNodeBg
        colorBrd = res.colorCommentNodeBrd
    else
        colorFg  = res.colorTextNode
        colorBg  = res.colorTextNodeBg
        colorBrd = res.colorTextNodeBrd
    end

    -- -- split and display lines of the text
    local lines = trim_text_block( splitlines(msg) )
    -- local lines = splitlines(msg)
    local bl,bt,br,bb = x,y,x,y
    local firstTxt = nil  -- ID of the first drawn fragment of the text block
    for _, line in ipairs(lines) do
        line = rtrim(line)
        local txt = res.canvas:Add(shapes.Text{ x, y, text=line, font=res.font3, 
            color=colorFg })
        if firstTxt == nil then
            firstTxt = txt
        end
        local bl0,bt0,br0,bb0 = res.canvas:GetBbox(txt)
        br,bb = max(br,br0), max(bb,bb0)
        y = max(y+fontHPx, bb)
    end

    -- draw a box behind the text area
    if firstTxt ~= nil then
        local rect = res.canvas:Add(shapes.Rectangle{ bl-d,bt-d,br+d,bb+d, 
                background=colorBg, color=colorBrd })
        res.canvas:Lower(rect)
    end
    
    return bb-bt  -- bbox height 
end

--[[[
Function: renderer:_renderNode(node, x, y, nodeIdTracker)
(internal) Recursively renders an XML subtree.
]]--
function renderer:_renderNode(node, x, y, nodeIdTracker)
    local xmlh = self.param.xmlh

    -- Update the progress information
    self.currentElementIndex = self.currentElementIndex + 1
    if type(self.progressCallback) == 'function' then
        self.progressCallback(self.currentElementIndex)
    end
    
    local inc = function(x) return 1 + (x or 0) end

    if xmlh.nodeType(node) == xmlh.ELEMENT_NODE or
       xmlh.nodeType(node) == xmlh.ROOT_NODE then
        
        self.cc.elements = inc(self.cc.elements)
        return self:_elementNode(x, y, node, nodeIdTracker)
        
    elseif xmlh.nodeType(node) == xmlh.ATTRIBUTE_NODE then
    
        self.cc.attributes = inc(self.cc.attributes)
        return self:_attributeNode(x, y, node, nodeIdTracker)
        
    elseif xmlh.nodeType(node) == xmlh.TEXT_NODE or 
           xmlh.nodeType(node) == xmlh.CDATA_SECTION_NODE or 
           xmlh.nodeType(node) == xmlh.COMMENT_NODE then
        
        self.cc.textOrComment = inc(self.cc.textOrComment)
        return self:_textNode(x, y, node, nodeIdTracker)
        
    else
        -- print "Oops, node type not handled..."
        self.cc.unknown = inc(self.cc.unknown)
        return 0
    end
    
end

return renderer
