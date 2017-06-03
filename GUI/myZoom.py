import cv2
import numpy as np
from tkinter import *
from tkinter import font
from PIL import Image, ImageTk

# master = Tk()
# # w = Scale(master, from_=0, to=42)
# # w.pack()
# w = Scale(master, from_=30, to=200, orient=HORIZONTAL)
# w.pack()

# mainloop()

class ImageDisp:
	def __init__(self, master):
		self.master = master
		frame = Frame(master)
		frame.pack()
		self.origImg, self.annotImg = None, None
		self.origImgFile, self.annotImgFile = None, None
		# entry boxes for file names
		self.origImg_entry = Entry(frame)
		self.origImg_entry.pack(side=LEFT)
		self.enter_files = Button(frame, text='Enter image file', fg='blue', command=self._get_file)
		self.enter_files.pack(side=LEFT)
		# buttons
		self.exit = Button(frame, text='Exit', fg="red", command=frame.quit)
		self.exit.pack(side=LEFT)

	def _get_file(self):
		try:
			if not self.origImg_entry.get():
				self.origImgFile = 'img17.jpg'
				self.annotImgFile = self.origImgFile.replace('.jpg', '_annot.jpg')
				# print("ERROR: Invalid image file.")
				# return
			else:
				self.origImgFile = self.origImg_entry.get()
				self.annotImgFile = self.origImgFile.replace('.jpg', '_annot.jpg')
		except ValueError:
			self._warning('number')
			return
		self.display()

	def display(self):
		origFrame = Frame(self.master)
		origFrame.pack()
		annotFrame = Frame(self.master)
		annotFrame.pack()

		# load image
		self.origImg = Image.open(self.origImgFile) # PhotoImage(Image.open(self.origImgFile))
		self.annotImg = Image.open(self.annotImgFile)
		# display config
		self.scale = 640/self.origImg.width
		self.tag_font = font.Font(family='Helvetica', size=12)
		# canvas
		self.width, self.height = 640, int(self.origImg.height * self.scale)
		self.canvas = Canvas(width=self.width, height=self.height)
		self.canvas.pack(side="top", fill="both", expand=True)
		# draw bg img
		img = self.origImg.resize((self.width, self.height))
		self.tkImg = ImageTk.PhotoImage(img) # Need a Ref to the TkInter obj: http://effbot.org/pyfaq/why-do-my-tkinter-images-not-appear.htm
		self.canvas.create_image(0, 0, anchor='nw', image=self.tkImg)


if __name__ == "__main__":
	master = Tk()
	master.title('BV Image')

	# create proposal box displayer
	imgDisp = ImageDisp(master)
	master.mainloop()