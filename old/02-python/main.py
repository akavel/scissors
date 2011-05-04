##
## Scissors XML Viewer License (MIT License)
## -----------------------------------------
## Copyright (c) 2009-2011  Mateusz Czapliñski
##
## Permission is hereby granted, free of charge, to any person obtaining a copy
## of this software and associated documentation files (the "Software"), to deal
## in the Software without restriction, including without limitation the rights
## to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
## copies of the Software, and to permit persons to whom the Software is
## furnished to do so, subject to the following conditions:
##
## The above copyright notice and this permission notice shall be included in
## all copies or substantial portions of the Software.
##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
## AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
## OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
## THE SOFTWARE.
##

# For Tkinter reference, see:
# http://infohost.nmt.edu/tcc/help/pubs/tkinter/
from Tkinter import *
import tkFont
import tkFileDialog
import tkMessageBox

import xml.dom.minidom as xml

import sys
import os.path


######
## Loading XML file.
def load_xml(fn = None):
    print "Loading XML..."

    if fn == None and len(sys.argv) > 1:
        fn = sys.argv[1]
    if fn == None:
        fn = "common.bkl"
        
    doc = xml.parse(fn)

    return doc

######
## Preparing the canvas for plotting.

#
# Canvas + scrollbars example by:
# Eric Brunel <eric (underscore) brunel (at) despammed (dot) com>
# comp.lang.python 2004-10-04
# "Re: Canvas with scrollbars - how to get correct canvas coordinate when the
# scroll bars have moved?"
# - read for example at:
# http://coding.derkeiler.com/Archive/Python/comp.lang.python/2004-10/4023.html

def prepare_tk():
    root = Tk()
    root.title("Scissors")
    root.geometry("%dx%d+%d+%d" % (800,600, 100, 50))
    root.grid_rowconfigure(0, weight=1)
    root.grid_columnconfigure(0, weight=1)
    return root

class CanvasViewportController:
    canvas = None
    hs = None
    vs = None

    def setCanvas(self, c):
        self.canvas = c

    def setScrollBars(self, hs, vs):
        self.hs = hs
        self.vs = vs

    def connect(self):
        self.hs.configure(command=self.canvas.xview)
        self.vs.configure(command=self.canvas.yview)
        self.canvas.configure( \
            xscrollcommand=self.hs.set, yscrollcommand=self.vs.set)

class CanvasDraggingController(CanvasViewportController):
    __mouseDown = False
    __mouseX = 0
    __mouseY = 0
    xm = 10.0    # mouse multipliers
    ym = 10.0
    xkm = 10.0  # keyboard multipliers
    ykm = 10.0
    root = None

    def setMultiplier(self, m):
        self.setMultipliers(m, m)

    def setMultipliers(self, xm, ym):
        self.xm = float(xm)
        self.ym = float(ym)

    def setRoot(self, root):
        self.root = root
    
    def connect(self):
        self.canvas.bind('<ButtonPress-1>', self.__mPress)
        self.canvas.bind('<ButtonRelease-1>', self.__mRelease)
        self.canvas.bind('<Motion>', self.__mMove)
        self.root.bind('<KeyPress-Right>', self.__arrow)
        self.root.bind('<KeyPress-Down>', self.__arrow)
        self.root.bind('<KeyPress-Left>', self.__arrow)
        self.root.bind('<KeyPress-Up>', self.__arrow)

    __arrowKeys = {"Up": (0,-1), "Right": (1,0), "Down": (0,1), "Left": (-1,0)}
    def __arrow(self, evt):
        dx,dy = self.__arrowKeys[evt.keysym]
        dx,dy = float(dx)*self.xkm, float(dy)*self.ykm
        self.__moveCanvas(dx,dy)

    def __mPress(self, evt):
        self.__mouseDown = True

    def __mRelease(self, evt):
        self.__mouseDown = False

    def __mMove(self, evt):
        if self.__mouseDown:
            dx = float(evt.x - self.__mouseX)
            dy = float(evt.y - self.__mouseY)
            self.__moveCanvas(dx,dy)
        
        self.__mouseX = evt.x
        self.__mouseY = evt.y


    def __moveCanvas(self, dx, dy):
        sx, _ = self.hs.get()
        sy, _ = self.vs.get()
        bx0, by0, bx1, by1 = self.canvas.bbox(ALL)
        self.canvas.xview_moveto( sx + self.xm*dx/float(bx1-bx0) )
        self.canvas.yview_moveto( sy + self.ym*dy/float(by1-by0) )
        

def prepare_canvas(root):

    canvas = Canvas(root)
    canvas.grid(row=0, column=0, sticky='nswe')

    hs = Scrollbar(root, orient=HORIZONTAL)
    hs.grid(row=1, column=0, sticky='we')

    vs = Scrollbar(root, orient=VERTICAL)
    vs.grid(row=0, column=1, sticky='ns')

    scrolling = CanvasViewportController()
    scrolling.setCanvas(canvas)
    scrolling.setScrollBars(hs,vs)
    scrolling.connect()

    dragging = CanvasDraggingController()
    dragging.setCanvas(canvas)
    dragging.setScrollBars(hs,vs)
    dragging.setRoot(root)
    dragging.connect()
    dragging.setMultiplier(10)
    
    return canvas

def prepare_menu(root, canvas):

    def f_open():
        filename = tkFileDialog.askopenfilename(filetypes= \
            [("XML files", "*.xml"), ("All files", "*")])
        if filename != None:
            doc = load_xml(filename)
            render_xml(doc, canvas)
            root.title(os.path.basename(filename) + ' - Scissors')

    def f_exit():
        if tkMessageBox.askquestion( \
            title="Scissors", message="Are you sure you want to quit?", \
            default=tkMessageBox.NO) == 'yes':
            root.destroy()
    
    menubar = Menu(root)

    m_file = Menu(menubar, tearoff=0)
    m_file.add_command(label="Open...", command=f_open)
    m_file.add_command(label="Exit...", command=f_exit)
    menubar.add_cascade(label="File", menu=m_file)

    root.config(menu=menubar)

class NodeIdTracker:
    __depth = 'A'
    __memory = dict()

    def __init__(self):
        self.__depth = 'A'
        self.__memory = dict()
    
    def descend(self):
        deeper = NodeIdTracker()
        deeper.__memory = self.__memory  # reference to the same data
        deeper.__depth = self.__nextDepth(self.__depth)
        return deeper
        
    def __nextDepth(self, depth):
        return chr(ord(depth)+1)

    def getLastId(self):
        return self.__memory.get(self.__depth,0)

    def getNewId(self):
        newId = self.getLastId() + 1
        self.__memory[self.__depth] = newId
        return "(%s-%d)" % (self.__depth, newId)

def trim_text_block(lines):
    for row1 in xrange(len(lines)):
        if len(lines[row1]) > 0 and not lines[row1].isspace():
            break  # found a non-empty line
    for row2 in xrange(len(lines)-1, row1-1, -1):
        if len(lines[row2]) > 0 and not lines[row2].isspace():
            break  # found a non-empty line

    # find longest common prefix of spaces
    maxi = None
    for row in xrange(row1, row2+1):
        line = lines[row]
        if len(line) == 0 or line.isspace():
            continue
        for i in range(len(line)):
            if line[i] != ' ':
                if maxi==None or i<maxi:
                    maxi = i
                break
    return [ l[maxi:] for l in lines[row1:row2+1] ]
        
        

######
## Walking the XML tree and rendering the nodes.
def render_xml(doc, canvas):
    print "Rendering nodes..."

    canvas.delete(ALL)
    x, y = 0, 0
    fontHeightPixels = 15
    render_node = render_node1
    render_node(doc.documentElement, canvas, x, y, fontHeightPixels, \
                NodeIdTracker())

    canvas.create_oval(-1,-1,1,1) ## small circle in the origin

    # allow user to scroll the canvas to see all objects, but no further
    # (http://www.pythonware.com/library/tkinter/introduction/x2017-concepts.htm)
    canvas.config(scrollregion=canvas.bbox(ALL))

def render_node1(node, canvas, x, y, fontHPx, nodeIdTracker):
    """Recursively renders XML document.
The elements are shown as a flat tree."""

    global font1,font2,font3,font4
    if not globals().has_key('font1'):
        font1 = tkFont.Font( family="Arial", size= -fontHPx )
        font2 = tkFont.Font( family="Arial", size= -fontHPx, weight=tkFont.BOLD )
        font3 = tkFont.Font( family="Lucida Console", size= -fontHPx )
        font4 = tkFont.Font( family="Arial", size= -int(fontHPx*0.7) )


    # Parameters
    d = 5 # horz. line margin (at the ends)
    l = 20 # horz. line segment length
    f = fontHPx / 2 # vert. pos. of horz. lines relative to font bbox top
    attPad = 10 # horizontal padding of attributes

    # Accessing a font with a specified sixe *in pixels* (marked by minus)
    colorLine           = "#777777"
    colorAttrValue      = "#000088"
    colorTextNode       = "#006600"  #"#008800"
    colorTextNodeBg     = "#ffffff"
    colorTextNodeBrd    = "#000000"
    colorCommentNode    = "#333333"
    colorCommentNodeBg  = "#bbbbbb"
    colorCommentNodeBrd = "#bbbbbb"
    colorNodeId         = "#bbbb77"

    if node.nodeType == node.ELEMENT_NODE:
        msg = node.nodeName
        # display the node ID
        txt = canvas.create_text( x, y, text=nodeIdTracker.getNewId(), \
                            anchor=NW, font=font4, fill=colorNodeId)
        bl,bt,br,bb = canvas.bbox(txt)
        canvas.move(txt, -(br-bl), -(bb-bt)+d)
        # display the label
        txt = canvas.create_text( x, y, text=msg, anchor=NW, font=font2)
        bl,bt,br,bb = canvas.bbox(txt)

        # display all attributes
        maxWidth = 0
        if node.attributes.length > 0:
            # "tree root line"
            x0 = bl+attPad
            y0 = bb+d
            canvas.create_line(x0, y0, x0, y0+f, fill=colorLine)

            y1 = y0
            dy1 = 0
            dy = 0
            for i in range(0,node.attributes.length):
                att = node.attributes.item(i)
                dy,width = render_node1(att, canvas, x0+l+d, y1, fontHPx, \
                                        nodeIdTracker)
                if maxWidth < width:
                    maxWidth = width
                if dy > 0:
                    canvas.create_line(x0, y1+f, x0+l, y1+f, fill=colorLine)
                    dy1 = dy
                    y1 += dy1
                    
            # "vertical connecting line"
            canvas.create_line(x0, y0+f, x0, y1-dy1+f, fill=colorLine)

            bb = max(bb, y1)
            
        # display all child elements
        if node.hasChildNodes():
            # leaving space for the "tree root line"
            x0 = max(br+d, bl+attPad+l+d+maxWidth)
            y0 = bt
            
            y1 = y0
            dy1 = 0
            dy = 0
            for child in node.childNodes:
                dy = render_node1(child, canvas, x0+l+l+d, y1, fontHPx,\
                                  nodeIdTracker.descend())
                if dy > 0:
                    canvas.create_line(x0+l, y1+f, x0+l+l, y1+f, fill=colorLine)
                    dy1 = dy
                    y1 += dy1 + 2*d

            if y1 > y0:
                y1 -= 2*d

            if y1 <= y0:
                return 0

            # drawing the "tree root line"
            canvas.create_line(br+d, y0+f, x0+l, y0+f, fill=colorLine)


            # "vertical connecting line"
            canvas.create_line(x0+l, y0+f, x0+l, y1-dy1+f, fill=colorLine)

            bb = max(bb, y1)
        return bb-bt  # bbox height
    elif node.nodeType == node.ATTRIBUTE_NODE:
        msg1 = node.nodeName + ' = '
        msg2 = node.nodeValue
        # display the label
        txt1 = canvas.create_text( x,  y, text=msg1, anchor=NW, font=font1)
        bl, bt, br, bb = canvas.bbox(txt1)
        txt2 = canvas.create_text( br, y, text=msg2, anchor=NW, font=font2, \
                                   fill=colorAttrValue )
        _,  bt2,br, bb2= canvas.bbox(txt2)
        bb = max(bb,bb2)
        bt = min(bt,bt2)
        return bb-bt, br-bl  # bbox height & width
    elif node.nodeType == node.TEXT_NODE or \
         node.nodeType == node.CDATA_SECTION_NODE or \
         node.nodeType == node.COMMENT_NODE:
        
        msg = node.data
        if msg.isspace() or len(msg) == 0:
            return 0

        if node.nodeType == node.COMMENT_NODE:
            colorFg  = colorCommentNode
            colorBg  = colorCommentNodeBg
            colorBrd = colorCommentNodeBrd
        else:
            colorFg  = colorTextNode
            colorBg  = colorTextNodeBg
            colorBrd = colorTextNodeBrd

        # split and display lines of the text
        lines = trim_text_block( msg.splitlines() )
        bl,bt,br,bb = x,y,x,y
        firstTxt = 0  # ID of the first drawn fragment of the text block
        for line in lines:
            line = line.rstrip()
            txt = canvas.create_text( x, y, text=line, anchor=NW, font=font3, \
                fill=colorFg )
            if firstTxt==0:
                firstTxt = txt
            bl0,bt0,br0,bb0 = canvas.bbox(txt)
            br,bb = max(br,br0), max(bb,bb0)
            y = max(y+fontHPx, bb)

        # draw a box behind the text area
        if firstTxt!=0:
            rect = canvas.create_rectangle(bl-d,bt-d,br+d,bb+d, \
                    fill=colorBg, outline=colorBrd)
            canvas.tag_lower(rect, firstTxt)
        
        return bb-bt  # bbox height 
        
        
    else:
#        print "Oops, node type not handled..."
        return 0

    # create_text(...) - see:
    # http://infohost.nmt.edu/tcc/help/pubs/tkinter/create_text.html
    # http://effbot.org/tkinterbook/canvas.htm#Tkinter.Canvas.create_text-method

######
## Displaying the image. 
def show_all(root, canvas):

    root.mainloop() 

if __name__ == '__main__':
    doc = load_xml()
    tk = prepare_tk()
    canvas = prepare_canvas(tk)
    prepare_menu(tk, canvas)
    render_xml(doc, canvas)
    show_all(tk, canvas)
    
