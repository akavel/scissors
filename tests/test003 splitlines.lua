
require 't-path'

require 'spliterator'
require 'collect'


function splitlines(s)
    return collect(spliterator(s, '\n', true))
end

function test(s)
    print(string.format('splitlines("%s")=', s))
    local out = {}
    for k,v in ipairs(splitlines(s)) do
        table.insert(out, string.format('[%d]="%s"', k, v))
    end
    print(table.concat(out, ' '))
    print()
end

test('aa\nbb')
test('\n')
test('aa\n')
test('')
test('aa\nbb\ncc')
test('\naa')
test('aa')
test('\n\n')

