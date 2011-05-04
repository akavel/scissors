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

local utils = {}

local function toWxCaps(text)
    return tostring(text)
        :gsub('(%u)', '_%1') -- prepend upper-case letters with underscore
        :gsub('^_+', '') -- remove trailing underscores
        :gsub('[-_]+', '_') -- compress duplicate underscores & convert minus to underscore
        :upper()
end

function utils.getWxConst(prefix, freeformCore)
    return wx['wx' .. (prefix and (prefix .. '_') or '') .. toWxCaps(freeformCore)]
end

function utils.normalizeArgsList(...)
    local args = {...}
    if #args == 1 and type(args[1]) == 'table' then
        return args[1]
    else
        return args
    end
end

function utils.normalizeSubOptions(option)
    if type(option) == 'string' then
        local t = {}
        for name in option:gmatch('(%a+)') do
            t[name] = true
        end
        return t
    elseif type(option) == 'table' then
        local t = {}
        for name in pairs(option) do
            t[name] = option[name]
        end
        for _, name in ipairs(option) do
            t[name] = t[name] or true
        end
        return t
    end
    return nil
end

local copiedSizerFlags = { 'align', 'border', 'expand' }
function utils.copySizerFlags(dest, src)
    for _,v in ipairs(copiedSizerFlags) do
        dest[v] = src[v] or dest[v]
    end
    return dest
end

function utils.applyLayoutIfSupplied(window, args)
    local sizerGenerator = args.layout
    if sizerGenerator then
        -- Realize the sizerGenerator function, or throw an error
        -- if it's not a function.
        local sizer = sizerGenerator(window).wx
        window:SetSizer(sizer)
        sizer:SetSizeHints(window)
    end
end

function utils.applyBasicParameters(window, args)
    if args.background then
        window:SetBackgroundColour(args.background.wx)
    end
    if args.font then
        window:SetFont(args.font.wx)
    end
end

function utils.parseStyles(stylesTable, prefix)
    local style = 0
    for flag in pairs(utils.normalizeSubOptions(stylesTable) or {}) do
        style = style + (utils.getWxConst(prefix, flag) or 0)
    end
    return style
end

function utils.useFlag(flag, condition)
    return condition and flag or 0
end

return utils
