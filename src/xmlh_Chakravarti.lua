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
File: xmlh_Chakravarti.lua
]]--

require "chakravarti/xml"
require "chakravarti/handler"
require "progress"

--[[[
Package: xmlh_Chakravarti
"XML Helper" or "XML Handler". Handles an XML storage
format specific to a particular library with a DOM-like interface.
In this case, that's the "LuaXML" library by Paul Chakravarti.
]]--
local xmlh = {
    ELEMENT_NODE       = 'ELEMENT',
    TEXT_NODE          = 'TEXT',
    CDATA_SECTION_NODE = 'CDATA', -- NOT HANDLED CURRENTLY
    COMMENT_NODE       = 'COMMENT',
    ATTRIBUTE_NODE     = 'ATTRIBUTE',
    ROOT_NODE          = 'ROOT',
}

--[[[
Function: parse(text)
]]--
function xmlh.parse(text)
        local dom = domHandler()
        dom.progressCallback = xmlh.progressCallback
        
        -- Parsing
        local parser = xmlParser(dom)
        parser.options.stripWS = false
        parser:parse(text)
                
        return dom
end
    
--[[[
Function: getTotalNodesCount(xml)
]]--
function xmlh.getTotalNodesCount(xml)
        return xml.nodesCount
end

--[[[
Function: documentElement(xml)
]]--
function xmlh.documentElement(xml) 
        return xml.root
end

--[[[
Function: nodeType(node)
]]--
function xmlh.nodeType(node)
        return node._type
end

--[[[
Function: nodeName(node)
]]--
function xmlh.nodeName(node)
        if node._type == xmlh.ELEMENT_NODE then
            return node._name
        elseif node._type == xmlh.ATTRIBUTE_NODE then
            return node.key
        elseif node._type == xmlh.ROOT_NODE then
            return '</>'
        end
end

--[[[
Function: nodeValue(node)
]]--
function xmlh.nodeValue(node)
        if node._type == xmlh.ATTRIBUTE_NODE then
            return node.value
        end
end

--[[[
Function: attributesLength(node)
]]--
function xmlh.attributesLength(node)
        if node.attr == nil then
            node.attr = {}
            for k,v in pairs(node._attr or {}) do
                table.insert(node.attr, {key=k, value=v, _type=xmlh.ATTRIBUTE_NODE})
            end
        end
        return #node.attr
end

--[[[
Function: attributesItem(node, i)
]]--
function xmlh.attributesItem(node, i)
        return node.attr[i]
end

--[[[
Function: hasChildNodes(node)
]]--
function xmlh.hasChildNodes(node)
        return #node._children > 0
end

--[[[
Function: childNodes(node)
]]--
function xmlh.childNodes(node)
        local i=0
        return function()
            i=i+1
            return node._children[i]
            -- local newNode = { xml=node.xml[i] }
            -- local t = type(newNode.xml)
            -- if t=='table' then
                -- newNode.type = xmlh.ELEMENT_NODE
            -- elseif t=='nil' then
                -- newNode = nil
            -- else
                -- newNode.type = xmlh.TEXT_NODE
            -- end
            -- return newNode
        end
end

--[[[
Function: data(node)
]]--
function xmlh.data(node)
        return node._text
end

return xmlh
