
import xml.dom.minidom as xml

k = xml.parseString('<foo key="val"><bar /></foo>')

print(dir(k))
# look in the first lines for node types.
k=k.documentElement

for i in range(0,k.attributes.length):
    at = k.attributes.item(i)
    print at.name, '=', at.nodeValue
print k.childNodes
