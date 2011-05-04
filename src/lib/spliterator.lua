--[[[
Function: spliterator(s, pattern [, plain])

Returns a function, which can be used to iterate
over all substrings in _s_ separated by the _pattern_.
Optional _plain_ flag can be used to turn off the
regexp-like Lua pattern matching facilities.

Author:
 Mateusz Czaplinski
]]--
function spliterator(s,pattern,plain)
    local next = 0
    return function()
        if not next then
            return nil
        end
        local left = next + 1
        local right
        right, next = string.find(s, pattern, left, plain)
        if not right then
            right = #s+1
        end
        return string.sub(s, left, right-1)
    end
end
