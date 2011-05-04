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
Module: xmlh_LuaXML
"XML Helper" or "XML Handler". Handles an XML storage
format specific to a particular library with a DOM-like interface.
In this case, that's the "LuaXML" library (as present in the
"Lua for Windows" distribution).
]]--
local xmlh = {
    ELEMENT_NODE       = 1,
    TEXT_NODE          = 2,
    CDATA_SECTION_NODE = 3,
    COMMENT_NODE       = 4,
    parse = function(text)
        return xml.eval(text)
    end,
    documentElement = function(xml) 
        return { xml=xml, type=xmlh.ELEMENT_NODE }
    end,
    nodeType = function(node)
        return node.type
    end,
    nodeName = function(node)
        if node.type == xmlh.ELEMENT_NODE then
            return node.xml[0]
        elseif node.type == xmlh.ATTRIBUTE_NODE then
            return node.key
        end
    end,
    nodeValue = function(node)
        if node.type == xmlh.ATTRIBUTE_NODE then
            return node.value
        end
    end,
    attributesLength = function(node)
        if node.attr == nil then
            node.attr = {}
            for k,v in pairs(node.xml) do
                if type(k) ~= 'number' then
                    table.insert(node.attr, {key=k, value=v, type=xmlh.ATTRIBUTE_NODE})
                end
            end
        end
        return #node.attr
    end,
    attributesItem = function(node, i)
        return node.attr[i]
    end,
    hasChildNodes = function(node)
        return #node.xml > 0
    end,
    childNodes = function(node)
        local i=0
        return function()
            i=i+1
            local newNode = { xml=node.xml[i] }
            local t = type(newNode.xml)
            if t=='table' then
                newNode.type = xmlh.ELEMENT_NODE
            elseif t=='nil' then
                newNode = nil
            else
                newNode.type = xmlh.TEXT_NODE
            end
            return newNode
        end
    end,
    data = function(node)
        return node.xml
    end
}

return xmlh
