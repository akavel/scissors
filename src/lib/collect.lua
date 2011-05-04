--[[[
Function: collect(iterator)

Returns a table filled with the results of all subsequent
calls to the _iterator_ function.

Note:
 If the _iterator_ function returns a list, only the
 first value from the list is stored on each call.

Author:
 Mateusz Czaplinski
]]--
function collect(iterator)
    local t = {}
    for v in iterator do
        table.insert(t, v)
    end
    return t
end
