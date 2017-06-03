from PIL import Image as Img
from tkinter import *

class Converter:
	def __init__(self, master):
		self.master = master
		frame = Frame(master)
		frame.pack()
		self.box_file, self.img_file = None, None
		# entry boxes for file names
		self.in_file_entry = Entry(frame)
		self.in_file_entry.pack(side=LEFT)
		self.out_file_entry = Entry(frame)
		self.out_file_entry.pack(side=LEFT)
		self.enter_files = Button(frame, text='Convert', fg='blue', command=self._convert)
		self.enter_files.pack(side=LEFT)
		# buttons
		self.exit = Button(frame, text='Exit', fg="red", command=frame.quit)
		self.exit.pack(side=LEFT)

	def _convert(self):
		if not self.in_file_entry.get() or not self.out_file_entry.get():
			print("ERROR: Please enter file names for both input file and output file.")
			return
		img = Img.open(self.in_file_entry.get())
		img.save(self.out_file_entry.get())
		self.in_file_entry.delete(0, END)
		self.out_file_entry.delete(0, END)
		return


if __name__ == "__main__":
	root = Tk()
	root.title('Image Format Converter')

	propDisp = Converter(root)
	root.mainloop()
	# im = Image.open('orig.jpg')
	# im.save('orig.pgm')