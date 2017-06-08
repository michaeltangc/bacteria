# import cv2
# import numpy as np
from tkinter import *
from tkinter import filedialog
from tkinter import font
import tkinter.ttk as ttk
from PIL import Image, ImageTk

class ImageDisp:
	def __init__(self, master):
		self.master = master
		# Header: entry boxes & bottuns
		header = Frame(master)
		header.grid(row=0, column=0)
		self.origImg, self.annotImg, self.result = None, None, None
		self.origImgFile, self.annotImgFile, self.resultFile = None, None, None
		# exit button at the left
		self.exitBtn = Button(header, text='Exit', fg="red", height=1, width=7, command=master.quit)
		self.exitBtn.grid(row=0, column=0)
		# entry boxes for file names
		self.fname_show = StringVar()
		self.fname_entry = Entry(header, textvariable=self.fname_show)
		self.fname_entry.grid(row=0, column=1, pady=5)
		self.browse_entry = None
		self.browseBtn = Button(header, text='Browse', height=1, width=18, fg='black', command=self._browse)
		self.browseBtn.grid(row=0, column=2, pady=5)
		self.enterBtn = Button(header, text='Enter image file', height=1, width=18, fg='black', command=self._get_file)
		self.enterBtn.grid(row=0, column=3, pady=5)
		# buttons
		self.origSize, self.showAnnot = False, False
		self.zoomText, self.annotText = StringVar(), StringVar()
		self.zoomBtn = Button(header, textvariable=self.zoomText, fg="black", height=1, width=10, command=self._zoomToggle)
		self.annotBtn = Button(header, textvariable=self.annotText, fg="black", height=1, width=12, command=self._annotToggle)
		self.resultWin = None
		self.resultBtn = Button(header, text='Result', fg="black", height=1, width=8, command=self._popResult)
		# Body: canvas (image) & scrollbar
		body = Frame(master)
		body.grid(row=1, column=0)
		imgCanvas = Frame(body)
		statTxt = Frame(body)
		imgCanvas.grid(row=0, column=0)
		statTxt.grid(row=1, column=0)
		self.canvas = Canvas(body, width=800, relief=SUNKEN)
		self.canvasX, self.canvasY = 0, 0
		self.scrollX = Scrollbar(body, highlightcolor='slate gray', bg='light gray', orient=HORIZONTAL)
		self.scrollY = Scrollbar(body, highlightcolor='slate gray', bg='light gray')

	def _browse(self):
		self.browse_entry = filedialog.askopenfilename()
		self.fname_show.set(self.browse_entry)
		return

	def _get_file(self):
		try:
			if not self.fname_entry.get() and self.browse_entry == None:
				# self.origImgFile = 'img17.jpg'
				# self.annotImgFile = self.origImgFile.replace('.jpg', '_annot.jpg')
				print("ERROR: Invalid image file.")
				return
			else:
				self.origImgFile = self.fname_entry.get()
				self.annotImgFile = self.origImgFile.replace('.jpg', '_annot.jpg')
				self.resultFile = self.origImgFile.replace('.jpg', '.txt')
		except ValueError:
			self._warning('number')
			return
		# set buttons
		self.origSize, self.showAnnot = False, False
		self.zoomText.set("Zoom In")
		self.zoomBtn.grid(row=0, column=4, padx=10, pady=5)
		self.annotText.set("Show Label")
		self.annotBtn.grid(row=0, column=5, padx=10, pady=5)
		self.resultBtn.grid(row=0, column=6, padx=10, pady=5)
		# load image & display
		self.origImg = Image.open(self.origImgFile)
		self.annotImg = Image.open(self.annotImgFile)
		# result format: lacto cnt & score + gardner cnt & score + others cnt & score
		# 				 + nugent_score + result (8 items)
		self.result = open(self.resultFile).readline().split(' ')
		if self.resultWin:
			self.resultWin.destroy()
		self._display()

	def _zoomToggle(self):
		self.origSize = not self.origSize
		if self.origSize:
			self.zoomText.set("Zoom Out")
		else:
			self.zoomText.set("Zoom In")
		self._display()

	def _annotToggle(self):
		self.showAnnot = not self.showAnnot
		self.canvasX, self.canvasY = self.canvas.xview()[0], self.canvas.yview()[0]
		if self.showAnnot:
			self.annotText.set("Hide Label")
		else:
			self.annotText.set("Show Label")
		self._display()

	def _popResult(self):
		self.resultWin = Toplevel()
		self.resultWin.title('Result')
		# Counts
		part_cnt = Frame(self.resultWin)
		part_cnt.grid(row=0, column=0, sticky=W+E)
		# labels
		header_type = Label(part_cnt, text="Type", bg="pale turquoise", fg="black", height=1, width=15, font='Helvetica 12')
		header_cnt = Label(part_cnt, text="Count", bg="pale turquoise", fg="black", height=1, width=15, font='Helvetica 12')
		header_score = Label(part_cnt, text="Score", bg="pale turquoise", fg="black", height=1, width=15, font='Helvetica 12')
		lacto = Label(part_cnt, text="Lactobacillus", bg="green", fg="white", height=2, width=15, font='Helvetica 12')
		lactoCnt = Label(part_cnt, text=self.result[0], bg="white", fg="black", height=2, width=15, font='Helvetica 12')
		lactoScore = Label(part_cnt, text=self.result[1], bg="white", fg="black", height=2, width=15, font='Helvetica 12')
		gardner = Label(part_cnt, text="Gardnerella", bg="red", fg="white", height=2,  font='Helvetica 12')
		gardnerCnt = Label(part_cnt, text=self.result[2], bg="white", fg="black", height=2,  font='Helvetica 12')
		gardnerScore = Label(part_cnt, text=self.result[3], bg="white", fg="black", height=2,  font='Helvetica 12')
		others = Label(part_cnt, text="Others", bg="blue", fg="white", height=2, font='Helvetica 12')
		othersCnt = Label(part_cnt, text=self.result[4], bg="white", fg="black", height=2,  font='Helvetica 12')
		othersScore = Label(part_cnt, text=self.result[5], bg="white", fg="black", height=2,  font='Helvetica 12')
		# layout
		header_type.grid(row=0, column=0, sticky=W+E)
		header_cnt.grid(row=0, column=1, sticky=W+E)
		header_score.grid(row=0, column=2, sticky=W+E)
		lacto.grid(row=1, column=0, sticky=W+E)
		lactoCnt.grid(row=1, column=1, sticky=W+E)
		lactoScore.grid(row=1, column=2, sticky=W+E)
		gardner.grid(row=2, column=0, sticky=W+E)
		gardnerCnt.grid(row=2, column=1, sticky=W+E)
		gardnerScore.grid(row=2, column=2, sticky=W+E)
		others.grid(row=3, column=0, sticky=W+E)
		othersCnt.grid(row=3, column=1, sticky=W+E)
		othersScore.grid(row=3, column=2, sticky=W+E)

		# Results
		part_result = Frame(self.resultWin)
		part_result.grid(row=1, column=0, pady=(20,0), sticky=W+E)
		# labels
		header_score = Label(part_result, text="Score", bg="pale turquoise", fg="black", height=1, width=20, font='Helvetica 12')
		score = Label(part_result, text=self.result[6], bg="white", fg="black", height=2, width=21, font='Helvetica 12 bold')
		header_result = Label(part_result, text="Result", bg="pale turquoise", fg="black", height=1, width=21, font='Helvetica 12')
		result = Label(part_result, text=self.result[7], bg="white", fg="black", height=2, width=21, font='Helvetica 12 bold')
		# layouts
		header_score.grid(row=0, column=0, sticky=W+E)
		score.grid(row=1, column=0, sticky=W+E)
		header_result.grid(row=0, column=1, sticky=W+E)
		result.grid(row=1, column=1, sticky=W+E)

	def _display(self):
		frame = Frame(master)
		frame.grid(row=0, column=0)
		# display config
		self.dispImg = self.annotImg if self.showAnnot else self.origImg
		if self.origSize:
			self.width, self.height = self.dispImg.width, self.dispImg.height
			self.tkImg = ImageTk.PhotoImage(self.dispImg)
		else:
			self.width, self.height = 800, int(800 * self.dispImg.height / self.dispImg.width)
			self.tkImg = ImageTk.PhotoImage(self.dispImg.resize((self.width, self.height))) # Need a Ref to the TkInter obj: http://effbot.org/pyfaq/why-do-my-tkinter-images-not-appear.htm
			# self.scrollX, self.scrollY = None, None
		# canvas
		if self.canvas == None:
			self.canvas = Canvas(frame, width=800, height=int(800*self.height/self.width))
		self.canvas.config(height=int(800*self.height/self.width))
		# layout
		if self.origSize:
			self.scrollX.config(command=self.canvas.xview)
			self.scrollY.config(command=self.canvas.yview)
			self.canvas.config(xscrollcommand=self.scrollX.set, yscrollcommand=self.scrollY.set,
				scrollregion=(0, 0, self.width, self.height))
			self.scrollY.grid(row=0, column=1, sticky=N+S)
			self.scrollX.grid(row=1, column=0, columnspan=2, sticky=W+E)
			self.canvas.grid(row=0, column=0)
		else:
			self.canvasX, self.canvasY = 0, 0
			self.scrollY.grid_forget()
			self.scrollX.grid_forget()
			self.canvas.grid(row=0, column=0)
		# self.tag_font = font.Font(family='Helvetica', size=12)
		# draw bg img
		self.canvas.xview_moveto(self.canvasX)
		self.canvas.yview_moveto(self.canvasY)
		self.canvas.create_image(0, 0, anchor='nw', image=self.tkImg)


if __name__ == "__main__":
	master = Tk()
	master.title('BV Image')

	# create proposal box displayer
	imgDisp = ImageDisp(master)
	master.mainloop()