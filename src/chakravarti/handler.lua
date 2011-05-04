-- 
--  handler.lua
--
--  Overview:
--  =========
--
--      Standard XML event handler(s) for XML parser module
--      (xml.lua)
--  
--  Features:
--  =========
--  
--      printHandler        - Generate XML event trace
--      domHandler          - Generate DOM-like node tree
--      simpleTreeHandler   - Generate 'simple' node tree
--  
--  API:
--  ====
--
--      Must be called as handler function from xmlParser
--      and implement XML event callbacks (see xmlParser.lua 
--      for callback API definition)
--
--      printHandler:
--      -------------
--
--      printHandler prints event trace for debugging
--
--      domHandler:
--      -----------
--
--      domHandler generates a DOM-like node tree  structure with 
--      a single ROOT node parent - each node is a table comprising 
--      fields below.
--  
--      node = { _name = <Element Name>,
--               _type = ROOT|ELEMENT|TEXT|COMMENT|PI|DECL|DTD,
--               _attr = { Node attributes - see callback API },
--               _parent = <Parent Node>
--               _children = { List of child nodes - ROOT/NODE only }
--             }
--
--      The dom structure is capable of representing any valid XML
--      document
--
--      2009-04-05 - extended to call a progress callback from
--       time to time. The callback is called with a single parameter
--       which is the position of the last processed character in
--       the input.
--
--      simpleTreeHandler
--      -----------------
--
--      simpleTreeHandler is a simplified handler which attempts 
--      to generate a more 'natural' table based structure which
--      supports many common XML formats. 
--      
--      The XML tree structure is mapped directly into a recursive
--      table structure with node names as keys and child elements
--      as either a table of values or directly as a string value
--      for text. Where there is only a single child element this
--      is inserted as a named key - if there are multiple
--      elements these are inserted as a vector (in some cases it
--      may be preferable to always insert elements as a vector
--      which can be specified on a per element basis in the
--      options).  Attributes are inserted as a child element with
--      a key of '_attr'. 
--      
--      Only Tag/Text & CDATA elements are processed - all others
--      are ignored.
--      
--      This format has some limitations - primarily
--  
--      * Mixed-Content behaves unpredictably - the relationship 
--        between text elements and embedded tags is lost and 
--        multiple levels of mixed content does not work
--      * If a leaf element has both a text element and attributes
--        then the text must be accessed through a vector (to
--        provide a container for the attribute)
--
--      In general however this format is relatively useful. 
--
--      It is much easier to understand by running some test
--      data through 'textxml.lua -simpletree' than to read this)
--
--  Options
--  =======
--
--      simpleTreeHandler.options.noReduce = { <tag> = bool,.. }
--
--          - Nodes not to reduce children vector even if only 
--            one child
--
--      domHandler.options.(comment|pi|dtd|decl)Node = bool 
--          
--          - Include/exclude given node types
--  
--  Usage
--  =====
--
--      Pased as delegate in xmlParser constructor and called 
--      as callback by xmlParser:parse(xml) method.
--
--      See textxml.lua for examples
--
--  Author:
--  =======
--
--      Paul Chakravarti (paulc@passtheaardvark.com)
--
--  License:
--  ========
--
--      This code is freely distributable under the terms of the Lua license
--      (http://www.lua.org/copyright.html)
--
--  History
--  =======
--
--  $Id: handler.lua,v 1.1.1.1 2001/11/28 06:11:33 paulc Exp $
--
--  $Log: handler.lua,v $
--  Revision 1.1.1.1  2001/11/28 06:11:33  paulc
--  Initial Import
--
--

local write = io.write
local format = string.format
local tinsert = table.insert

function showTable(t)
    -- Convenience function for printHandler
    -- (Does not support recursive tables)
    local sep = ''
    local res = ''
    if type(t) ~= 'table' then
        return t
    end
    for k,v in pairs(t) do
        if type(v) == 'table' then 
            v = showTable(v)
        end
        res = res .. sep .. format("%s=%s",k,v)    
        sep = ','
    end
    res = '{'..res..'}'
    return res
end
        
--
-- printHandler - generate simple event trace
--

printHandler = function()
    local obj = {}
    obj.starttag = function(self,t,a,s,e) 
        write("Start    : "..t.."\n") 
        if a then 
            for k,v in pairs(a) do 
                write(format(" + %s='%s'\n",k,v))
            end 
        end
    end
    obj.endtag = function(self,t,s,e) 
        write("End      : "..t.."\n") 
    end
    obj.text = function(self,t,s,e)
        write("Text     : "..t.."\n") 
    end
    obj.cdata = function(self,t,s,e)
        write("CDATA    : "..t.."\n") 
    end
    obj.comment = function(self,t,s,e)
        write("Comment  : "..t.."\n") 
    end
    obj.dtd = function(self,t,a,s,e)     
        write("DTD      : "..t.."\n") 
        if a then 
            for k,v in pairs(a) do 
                write(format(" + %s='%s'\n",k,v))
            end 
        end
    end
    obj.pi = function(self,t,a,s,e) 
        write("PI       : "..t.."\n")
        if a then 
            for k,v in pairs(a) do 
                write(format(" + %s='%s'\n",k,v))
            end 
        end
    end
    obj.decl = function(self,t,a,s,e) 
        write("XML Decl : "..t.."\n")
        if a then 
            for k,v in pairs(a) do 
                write(format(" + %s='%s'\n",k,v))
            end 
        end
    end
    return obj
end

--
-- simpleTreeHandler
--

function simpleTreeHandler()

    local obj = {}
    obj.root = {} 
    obj.stack = {obj.root;n=1}
    obj.options = {noreduce = {}}

    obj.reduce = function(self,node,key,parent)
        -- Recursively remove redundant vectors for nodes
        -- with single child elements
        for k,v in pairs(node) do
            if type(v) == 'table' then
                self:reduce(v,k,node)
            end
        end
        if getn(node) == 1 and not self.options.noreduce[key] and 
            node._attr == nil then
            parent[key] = node[1]
        else
            node.n = nil
        end
    end
        
    obj.starttag = function(self,t,a)
        local node = {_attr=a}
        local current = self.stack[getn(self.stack)]
        if current[t] then
            tinsert(current[t],node)
        else
            current[t] = {node;n=1}
        end
        tinsert(self.stack,node)
    end

    obj.endtag = function(self,t,s)
        local current = self.stack[getn(self.stack)]
        local prev = self.stack[getn(self.stack)-1]
        if not prev[t] then
            error("XML Error - Unmatched Tag ["..s..":"..t.."]\n")
        end
        if prev == self.root then
            -- Once parsing complete recursively reduce tree
            self:reduce(prev,nil,nil)
        end
        tremove(self.stack)
    end
    
    obj.text = function(self,t)
        local current = self.stack[getn(self.stack)]
        tinsert(current,t)
    end

    obj.cdata = obj.text

    return obj
end

--
-- domHandler
--

function domHandler() 
    local inc = function(x) return 1 + (x or 0) end
    local obj = {}
    obj.options = {
        commentNode=1,piNode=1,dtdNode=1,declNode=1,
        progressCallback=nil }
    obj.cc = {}
    obj.nodesCount = 0
    obj.root = { _children = {n=0}, _type = "ROOT" }
    obj.current = obj.root
    obj.progress = function(self,e)
            if self.progressCallback then
                self.progressCallback(e)
            end
    end
    obj.starttag = function(self,t,a,s,e)
            local node = { _type = 'ELEMENT', 
                           _name = t, 
                           _attr = a, 
                           _parent = self.current, 
                           _children = {n=0} }
            tinsert(self.current._children,node)
            self.current = node
            self:progress(e)
            local attributesCount = 0
            for _ in pairs(a or {}) do
                attributesCount = attributesCount + 1
            end
            self.nodesCount = self.nodesCount + attributesCount + 1
            self.cc.attributes = (self.cc.attributes or 0) + attributesCount
            self.cc.elements = inc(self.cc.elements)
    end
    obj.endtag = function(self,t,s,e)
            if t ~= self.current._name then
                error("XML Error - Unmatched Tag ["..s..":"..t.."]\n")
            end
            self.current = self.current._parent
            self:progress(e)
    end
    obj.text = function(self,t,s,e)
            local node = { _type = "TEXT", 
                           _parent = self.current, 
                           _text = t }
            tinsert(self.current._children,node)
            self:progress(e)
            self.nodesCount = self.nodesCount + 1
            self.cc.text = inc(self.cc.text)
    end
    obj.comment = function(self,t,s,e)
            if self.options.commentNode then
                local node = { _type = "COMMENT", 
                               _parent = self.current, 
                               _text = t }
                tinsert(self.current._children,node)
                self.nodesCount = self.nodesCount + 1
                self.cc.comments = inc(self.cc.comments)
            end
            self:progress(e)
    end
    obj.pi = function(self,t,a,s,e)
            if self.options.piNode then
                local node = { _type = "PI", 
                               _name = t,
                               _attr = a, 
                               _parent = self.current } 
                tinsert(self.current._children,node)
                self.nodesCount = self.nodesCount + 1
                self.cc.pi = inc(self.cc.pi)
            end
            self:progress(e)
    end
    obj.decl = function(self,t,a,s,e)
            if self.options.declNode then
                local node = { _type = "DECL", 
                               _name = t,
                               _attr = a, 
                               _parent = self.current }
                tinsert(self.current._children,node)
                self.nodesCount = self.nodesCount + 1
                self.cc.decl = inc(self.cc.decl)
            end
            self:progress(e)
    end
    obj.dtd = function(self,t,a,s,e)
            if self.options.dtdNode then
                local node = { _type = "DTD", 
                               _name = t,
                               _attr = a, 
                               _parent = self.current }
                tinsert(self.current._children,node)
                self.nodesCount = self.nodesCount + 1
                self.cc.dtd = inc(self.cc.dtd)
            end
            self:progress(e)
    end
    obj.cdata = obj.text
    return obj
end

