
require 't-path'

require "chakravarti/xml"
require "chakravarti/handler"
require "serialize"

xml = [[
<root>
    <empty-xml-test/>
    <ch2 attrib-test='val'>testing <ch3/> inline xml</ch2>
    <!-- comment test -->
    testing
    multiline
    text
</root>
]]

print(xml)

-- parser = xmlParser(printHandler())
-- parser:parse(xml)

-- print "----"
doc = domHandler()
parser = xmlParser(doc)
parser:parse(xml)
print(serialize(doc.root))
