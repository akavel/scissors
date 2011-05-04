# File: hello1.py

from Tkinter import *

root = Tk()
root.grid_rowconfigure(0, weight=1)
root.grid_columnconfigure(0, weight=1)
cnv = Canvas(root, scrollregion=(0, 0, 1000, 1000))
cnv.grid(row=0, column=0, sticky='nswe')
hs = Scrollbar(root, orient=HORIZONTAL, command=cnv.xview)
hs.grid(row=1, column=0, sticky='we')
vs = Scrollbar(root, orient=VERTICAL, command=cnv.yview)
vs.grid(row=0, column=1, sticky='ns')
cnv.configure(xscrollcommand=hs.set, yscrollcommand=vs.set)

def click(evt):
   x, y = cnv.canvasx(evt.x), cnv.canvasy(evt.y)
   cnv.create_oval(x - 5, y - 5, x + 5, y + 5)

cnv.bind('<1>', click)

root.mainloop() 
