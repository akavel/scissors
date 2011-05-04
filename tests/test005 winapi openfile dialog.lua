

require 'alien'
local oo = require 'loop.simple'

local comdlg = alien.load('comdlg32.dll')
local dlg = comdlg.GetOpenFileNameA
dlg:types{ ret='int', abi='stdcall', 'pointer' }
print(dlg)

function bits2bytes(n)
    return n/8
end

local h = {
    HANDLE = 4,
    ptr = 4,
}
local typeSizes = {
    DWORD = bits2bytes(32),
    HWND = h.HANDLE,
    HINSTANCE = h.HANDLE,
    LPCTSTR = h.ptr,
    LPTSTR = h.ptr,
    WORD = bits2bytes(16),
    LPARAM = 4,
    LPOFNHOOKPROC = h.ptr,
}

local OPENFILENAME = {
{'DWORD','lStructSize'},
{'HWND','hwndOwner'},
{'HINSTANCE','hInstance'},
{'LPCTSTR','lpstrFilter'},
{'LPTSTR','lpstrCustomFilter'},
{'DWORD','nMaxCustFilter'},
{'DWORD','nFilterIndex'},
{'LPTSTR','lpstrFile'},
{'DWORD','nMaxFile'},
{'LPTSTR','lpstrFileTitle'},
{'DWORD','nMaxFileTitle'},
{'LPCTSTR','lpstrInitialDir'},
{'LPCTSTR','lpstrTitle'},
{'DWORD','Flags'},
{'WORD','nFileOffset'},
{'WORD','nFileExtension'},
{'LPCTSTR','lpstrDefExt'},
{'LPARAM','lCustData'},
{'LPOFNHOOKPROC','lpfnHook'},
{'LPCTSTR','lpTemplateName'},
}
--[=[
function structBuild(values, scheme, typeSizes)
    local buf = alien.buffer()
    local offset = 1
    for _,entry in ipairs(scheme) do
        local size = typeSizes[entry[1]]
        local name = entry[2]
        for i=1,size do
            local divisor = math.pow(2, (i-1)*8)
            local byte = (values[name] or 0) / divisor % 0x100
            buf[offset] = byte
            offset = offset + 1
        end
    end
    return buf, offset
end
--]=]

function calcStructOffsets(scheme, typeSizes)
    local offset = 1
    local t = {}
    for _,entry in ipairs(scheme) do
        local size = typeSizes[entry[1]]
        local name = entry[2]
        t[name] = offset
        offset = offset + size
        -- for i=1,size do
            -- local divisor = math.pow(2, (i-1)*8)
            -- local byte = (values[name] or 0) / divisor % 0x100
            -- buf[offset] = byte
            -- offset = offset + 1
        -- end
    end
    return t, offset-1
end

local ofnOffsets, ofnSize = calcStructOffsets(OPENFILENAME, typeSizes)

local bufSize = 1024

local buf = alien.buffer(bufSize)
for i=1,bufSize do
    buf[i] = 0
end

local buf1 = alien.buffer(bufSize)
buf1[1] = 0

--[[
local values = {
    hwndOwner = 0,
    hInstance = 0,
    lpstrFilter = 0,
    lpstrCustomFilter = 0,
    nMaxCustFilter = 0,
    nFilterIndex = 0,
    lpstrFile = buf1,
    nMaxFile = 256,
    lpstrFileTitle = 0,
    nMaxFileTitle = 0,
    lpstrInitialDir = 0,
    lpstrTitle = 0,
    Flags = 0,
    nFileOffset = 0,
    nFileExtension = 0,
    lpstrDefExt = 0,
    lCustData = 0,
    lpfnHook = 0,
    lpTemplateName = 0,
}
]]
print(ofnSize)
buf:set(ofnOffsets.lStructSize, ofnSize, 'long')
buf:set(ofnOffsets.lpstrFile, buf1, 'pointer')
buf:set(ofnOffsets.nMaxFile, 256, 'short')

dlg(buf)
dlg(buf)

-- local buf,size = structBuild(values, OPENFILENAME, typeSizes)
-- print(size)
-- for i=1,size do
    -- io.write(('%d\t'):format(buf[i]))
-- end

-- local buf = alien.buffer()
-- buf:set(1, 32500, 'int')
-- buf:set(5, 30, 'int')
-- --buf:set(2, 3.0, 'float')
-- --print(string.byte(buf:tostring(3)))
-- --print(buf[1], buf[2], buf[3])
-- for i=1,8 do
    -- io.write(('%d\t'):format(buf[i]))
-- end
