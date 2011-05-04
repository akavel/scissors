@if not exist resources\nul mkdir resources
lua.exe ..\tools\make_embedded_image.lua ..\img\navigation5.png > resources\embedded_title_image.lua
lua.exe ..\tools\make_embedded_image.lua ..\img\mateusz.czaplinski.png > resources\embedded_author_logo.lua
lua.exe ..\tools\make_embedded_image.lua ..\img\arrow_refresh_small.png > resources\embedded_refresh_icon.lua
