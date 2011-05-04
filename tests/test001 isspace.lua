
function isspace(s)
    return string.find(s, '^%s+$') ~= nil
end



yes = {' ', '   ', ' \t\n'}
no  = {'', '  a', 'a  ', '   a   ', 'aaa', 'a'}

for _,s in ipairs(yes) do
    print(string.format('+[%s] ', s))
    assert( isspace(s) )
end

for _,s in ipairs(no) do
    print(string.format('-[%s] ', s))
    assert( not isspace(s) )
end
