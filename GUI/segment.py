from tkinter import *
from tkinter import filedialog
from tkinter import font
import tkinter.ttk as ttk
from PIL import Image, ImageTk

class ImageDisp:
	def __init__(self, master):
		self.master = master
		# Bing keyboard events
		self.master.bind("<Left>", self._left_key)
		self.master.bind("<Right>", self._right_key)
		self.master.bind("<Up>", self._up_key)
		self.master.bind("<Down>", self._down_key)
		self.master.bind("<Control-s>", self._save_key)
		self.save_flag = False
		# Image list
		self.imgListFile, self.imgList, self.imgCnt, self.curr_img = None, None, None, None
		self.txt_label = [('Lactobacilli', '1'), ('Gardnerella', '2'), ('Bacteroides', '3'), ('Others', '4'), ('Not sure', '5')]

		# Header: entry boxes & bottuns
		self.header = Frame(self.master, width=700)
		self.header.grid(row=0, column=0)
		self.origImg, self.annotImg, self.result = None, None, None
		self.origImgFile, self.annotImgFile, self.resultFile = None, None, None
		# Exit
		self.exitBtn = Button(self.header, text='Exit', fg="red", height=1, width=7, command=self._exit)
		self.exitBtn.grid(row=0, column=0, padx=(10,5))
		self.helpBtn = Button(self.header, text='Help', fg="blue", height=1, width=7, command=self._pop_help)
		self.helpBtn.grid(row=0, column=1, padx=(0,5))
		# Choose a folder
		self.fname_show = StringVar()
		self.fname_entry = Entry(self.header, textvariable=self.fname_show)
		self.fname_entry.grid(row=0, column=2, pady=5, padx=1)
		self.browse_entry = None
		self.browseBtn = Button(self.header, text='Browse', height=1, width=18, fg='black', command=self._browse)
		self.browseBtn.grid(row=0, column=3, pady=5, padx=1)
		self.enterBtn = Button(self.header, text='Enter image list', height=1, width=18, fg='black', command=self._get_imgList)
		self.enterBtn.grid(row=0, column=4, pady=5, padx=1)

		# Body: canvas (image) + label + control
		self.body = Frame(self.master, width=700, height=600)
		# image
		self.img_related = Frame(self.body, width=400, height=600)
		self.canvas = Canvas(self.img_related, width=400, height=400, relief=SUNKEN)
		self.img_label_txt = StringVar()
		self.img_label = Label(self.img_related, height=0, textvariable=self.img_label_txt, justify=CENTER, compound=BOTTOM)
		self.img_list_label_txt = StringVar()
		self.img_list_label = Label(self.img_related, height=0, textvariable=self.img_list_label_txt, justify=CENTER, compound=TOP)
		# radio button (the label)
		self.label_val = StringVar()
		self.radioBtns = Frame(self.body, width=300, height=400)
		# control buttons: prev/next + see context + save
		self.controlBtns = Frame(self.body, width=300, height=200)
		self.backBtn = Button(self.controlBtns, text='<< Back', height=1, width=10, fg='black', command=self._backImg)
		self.nextBtn = Button(self.controlBtns, text='Next >>', height=1, width=10, fg='black', command=self._nextImg)
		self.saveBtn = Button(self.controlBtns, text='Save', height=1, width=15, fg='black', command=self._save)
		self._get_imgList()

	# Keyboard controls
	# change images
	def _left_key(self, event): return self._backImg()
	def _right_key(self, event): return self._nextImg()
	# select labels
	def _up_key(self, event):
		self.label_val.set( str((int(self.label_val.get())-1)%5) )
		self._select_label()
		return
	def _down_key(self, event):
		self.label_val.set( str((int(self.label_val.get())+1)%5) )
		self._select_label()
		return
	# save changes
	def _save_key(self, event):
		return self._save()

	def _save_exit(self):
		self._save()
		self.master.quit()
		return

	def _exit(self):
		if self.save_flag:
			self.resultWin = Toplevel(width=100, height=70)
			self.resultWin.title('Warning')
			label = Label(self.resultWin, text='Your changes have not been saved. Still exiting?',
				width=50, height=2, font='Helvetica 11', justify=CENTER)
			exitBtn = Button(self.resultWin, text='Exit', width=12, height=1, command=self.master.quit, font='Helvetica 11')
			saveBtn = Button(self.resultWin, text='Save & Exit', width=15, height=1, command=self._save_exit, font='Helvetica 11')
			cancelBtn = Button(self.resultWin, text='Cancel', width=12, height=1, command=self.resultWin.destroy, font='Helvetica 11')
			label.grid(row=0, column=0, columnspan=3, padx=(10,10), pady=(10,15), sticky=W+E)
			exitBtn.grid(row=1, column=0, pady=(5,15), sticky=E)
			saveBtn.grid(row=1, column=1, padx=(5,0), pady=(5,15), sticky=E)
			cancelBtn.grid(row=1, column=2, padx=(5,10), pady=(5,15), sticky=E)
		else:
			self.master.quit()
		return

	def _pop_help(self):
		self.helpWin = Toplevel(width=200, height=100)
		self.helpWin.title('Help')
		text = 'This is for trained professionals to help prepare correct labels for training images:\n\n'
		text = text + '· Use the mouse or left/right arrow on the keyboard to change image;\n the image number is displayed below the image.\n\n'
		text = text + '· Use the mouse or up/down arrow on the keyboard to select an appropriate label;\n the selected label is highlighted.\n\n'
		text = text + '· Use the mouse or Ctrl+s to save your changes.\n\n'
		text = text + 'Your help is deeply appreciated! :)'
		label = Label(self.helpWin, text=text, justify=LEFT, wraplength=600, font='Helvetica 11')
		btn = Button(self.helpWin, text='Okay', width=16, height=1, command=self.helpWin.destroy)
		label.grid(row=0, column=0, padx=20, pady=20)
		btn.grid(row=1, column=0, padx=(0,20), pady=(0,20), sticky=E)

	def _browse(self):
		self.browse_entry = filedialog.askopenfilename()
		self.fname_show.set(self.browse_entry)
		return

	def _get_imgList(self):
		try:
			if not self.fname_entry.get() and self.browse_entry == None:
				self.imgListFile = '5_90017_detail.txt'
				# self._error_popup("ERROR: Please choose a image list.")
				# return
			else:
				self.imgListFile = self.fname_entry.get()
				if self.imgListFile[-3:] != 'txt':
					self._error_popup("ERROR: Invalid format: Please select a '.txt' file")
					return
		except ValueError:
			self._error_popup("ERROR: unexpected error.\nPlease check your file type ('.txt' expected).")
			return
		# Init attributes
		self.imgList = [line.strip().replace(' ', '').split(':') for line in open(self.imgListFile, 'r')]
		self.img_list_label_txt.set(self.imgListFile)
		self.imgCnt = len(self.imgList)
		self.curr_img = 0
		self._display()

	def _backImg(self):
		self.curr_img = (self.curr_img - 1) % self.imgCnt
		self._display()
		return

	def _nextImg(self):
		self.curr_img = (self.curr_img + 1) % self.imgCnt
		self._display()
		return

	def _select_label(self):
		self.save_flag = True
		self.imgList[self.curr_img][1] = self.label_val.get()
		self._display()
		return

	def _save(self):
		fout = open(self.imgListFile, 'w')
		for img, label in self.imgList:
			fout.write(img + ': ' + label + '\n')
		fout.close()
		self.save_flag = False
		return

	def _display(self):
		# display config
		self.dispImg = Image.open(self.imgList[self.curr_img][0])
		self.tkImg = ImageTk.PhotoImage(self.dispImg)
		self.img_label_txt.set('{:d}/{:d}'.format(self.curr_img+1, self.imgCnt))
		# canvas
		self.canvas.create_image(200, 200, anchor=CENTER, image=self.tkImg)

		# Body Layout
		self.body.grid(row=1, column=0, sticky=W+E+S)
		# image related
		self.img_related.grid(row=0, column=0, rowspan=2)
		self.canvas.grid(row=0, column=0)
		self.img_label.grid(row=1, column=0, pady=(0,10))
		self.img_list_label.grid(row=2, column=0, pady=(0,0))
		# radio buttons
		self.radioBtns.grid(row=0, column=1, pady=(40,0))
		self.label_val.set(self.imgList[self.curr_img][1]) # default choice for the radio buttons is the predicted value
		# for i, (text, val) in enumerate(self.txt_label[:-1]):
		# 	b = Radiobutton(self.radioBtns, text=text, variable=self.label_val, value=val, command=self._select_label,
		# 		indicatoron=0, width=15, height=1)
		# 	b.grid(row=i, column=1, pady=(10,0))
		# Radiobutton(self.radioBtns, text=text, variable=self.label_val, value='5', command=self._select_label,
		# 		indicatoron=0, width=15, height=1).grid(row=4, column=1, pady=(25,0))
		for i, (text, val) in enumerate(self.txt_label):
			b = Radiobutton(self.radioBtns, text=text, variable=self.label_val, value=val, command=self._select_label,
				indicatoron=0, width=15, height=1)
			if i == 4:
				b.grid(row=i, column=1, pady=(25,0))
			else:
				b.grid(row=i, column=1, pady=(10,0))
		# control buttons
		self.controlBtns.grid(row=1, column=1, pady=(40,5))
		self.backBtn.grid(row=0, column=0, padx=(10,2))
		self.nextBtn.grid(row=0, column=1, padx=(2,10))
		self.saveBtn.grid(row=1, column=1, padx=(7,5))

if __name__ == "__main__":
	master = Tk()
	master.title('BV Image')
	master.resizable(0,0)

	# create proposal box displayer
	imgDisp = ImageDisp(master)
	master.mainloop()