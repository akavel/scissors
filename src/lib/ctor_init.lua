
--[[[
Function: ctor_init(self, ...)
Example:
> local oo = require "loop.simple"
> MyPoint = oo.class{ __init=ctor_init }
> function MyPoint:__ctor(x, y)
>     self.x, self.y = x, y
> end
> somePoint = MyPoint(10, 20)
]]--
function ctor_init(self,...)
    local o = oo.rawnew(self,{})
    o:__ctor(...)
    return o
end
