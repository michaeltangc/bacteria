from tkinter import *
from tkinter import filedialog
from tkinter import font
import tkinter.ttk as ttk
from PIL import Image
from PIL import ImageTk
from math import floor

class ImageDisp:
    def __init__(self, master):
        self.master = master
        # Bind keyboard events
        self.master.bind("<Left>", self._left_key)
        self.master.bind("<Right>", self._right_key)
        self.master.bind("<Control-s>", self._save_key)
        for i in range(10):
            self.master.bind(str(i), self._number_key)
            self.master.bind("<KP_" + str(i) + ">", self._number_key)
        self.save_flag = False
        # Image list
        self.imgListFile, self.imgList, self.imgCnt, self.curr_img = None, None, None, None
        self.txt_label = [('0', '0'), ('1', '1'), ('2', '2'), ('3', '3'), ('4', '4'),
            ('5', '5'), ('6', '6'), ('7', '7'), ('8', '8'), ('9', '9'),
            ('10', '10'), ('11', '11'), ('12', '12'), ('13','13'), ('14', '14'),
            ('15', '15'), ('16', '16'), ('17', '17'), ('18', '18'), ('19', '19')]

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
        self.body = Frame(self.master, width=620, height=600)
        # image
        self.img_related = Frame(self.body, width=300, height=600)
        self.canvas = Canvas(self.img_related, width=300, height=400, relief=SUNKEN)
        # Jump-to image
        self.jump_to_digit_0 = StringVar()
        self.jump_to_digit_1 = StringVar()
        self.jump_to_digit_2 = StringVar()
        self.jump_to_digit_3 = StringVar()
        self.jump_to_full = StringVar()
        self.num_range = ["0"]
        self.jump_to_digit_0.set(self.num_range[0])
        self.jump_to_digit_1.set(self.num_range[0])
        self.jump_to_digit_2.set(self.num_range[0])
        self.jump_to_digit_3.set(self.num_range[0])
        self.jump_to_0 = OptionMenu(self.img_related, self.jump_to_digit_0, "0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
        self.jump_to_1 = OptionMenu(self.img_related, self.jump_to_digit_1, "0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
        self.jump_to_2 = OptionMenu(self.img_related, self.jump_to_digit_2, "0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
        self.jump_to_3 = OptionMenu(self.img_related, self.jump_to_digit_3, "0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
        self.jump_to_full = Entry(self.img_related, textvariable = self.jump_to_full)
        self.jump_to_button = Button(self.img_related, text='Jump to image', height=1, width=18, fg='black', command=self._jump_to)
        # Image index (e.g. 18/599 means the 18th out of 599 images)
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
        self.automaticFowardEnabled = IntVar()
        self.automaticFowardCheckBtn = Checkbutton(self.controlBtns, text = "Auto-Forward", variable = self.automaticFowardEnabled, onvalue = 1, offvalue = 0, height=1, width = 10)
        # Go to next image after selection
        self.saveBtn = Button(self.controlBtns, text='Save', height=1, width=15, fg='black', command=self._save)
        self.pick_val_radioBtns = [Radiobutton(self.radioBtns, text=text, variable=self.label_val, value=val, command=self._select_label,
                indicatoron=0, width=6, height=1) for i, (text, val) in enumerate(self.txt_label)]
        # self._get_imgList() # Uncomment for convenience when debugging

    # Keyboard controls
    # change images
    def _left_key(self, event): return self._backImg()
    def _right_key(self, event): return self._nextImg()
    def _number_key(self, event):
        # print (self.master.focus_get())
        if self.master.focus_get() == self.jump_to_full:
            self._display()
            return 
        self.save_flag = True
        self.imgList[self.curr_img][1] = event.char
        if self.automaticFowardEnabled.get() == 1:
            return self._nextImg()
        self._display()
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
        text = 'This is for people to help prepare labels for training images.'
        text = text + '- Browse to choose a txt file containing a list of images.\n\n'
        text = text + '- Use the mouse or left/right arrow on the keyboard to change image;\n the image number is displayed below the image.\n\n'
        text = text + '- Use the mouse or number key (single-digit only) to select an appropriate number as bacteria count;\n the selected label is highlighted.\n\n'
        text = text + '- When the "Auto-Forward" function is enabled, the next image is automatically loaded whenever you select the bacteria count'
        text = text + '- Use the mouse or Ctrl+s to save your changes.\n\n'
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
                # self.imgListFile = '5_90017_detail.txt' # Uncomment for convenience when debugging
                self._error_popup("ERROR: Please choose a image list.")
                return
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

    def _jump_to(self):
        # Select each digit of anthe image index from four dropdown lists
        target_index = 1000*int(self.jump_to_digit_0.get()) + 100*int(self.jump_to_digit_1.get()) + 10*int(self.jump_to_digit_2.get()) + int(self.jump_to_digit_3.get()) - 1
        target_index = int(self.jump_to_full.get())
        if target_index<0 or target_index>=len(self.imgList):
            self._error_popup("ERROR: the image index must be an integer between 1 and " + str(len(self.imgList)))
            return
        self.curr_img = target_index
        self.master.focus()
        self._display()
        return

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
        if self.automaticFowardEnabled.get() == 1:
            return self._nextImg()
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
        self.canvas.grid(row=0, column=0, columnspan=5)
        self.jump_to_0.grid(row=1, column=0, padx=(5,2))
        self.jump_to_1.grid(row=1, column=1, padx=(0,2))
        self.jump_to_2.grid(row=1, column=2, padx=(0,2))
        self.jump_to_3.grid(row=1, column=3, padx=(0,2))
        self.jump_to_button.grid(row=1, column=4, padx=(0,5), pady=(0,10))
        self.jump_to_full.grid(row=2, column =0, padx = (0,0), columnspan=3)
        self.img_label.grid(row=2, column=4, columnspan=2, pady=(0,10))
        self.img_list_label.grid(row=3, column=0, columnspan=5, pady=(0,0))
        # radio buttons
        self.radioBtns.grid(row=0, column=1, pady=(40,0))
        self.label_val.set(self.imgList[self.curr_img][1]) # default choice for the radio buttons is the predicted value
        for i, b in enumerate(self.pick_val_radioBtns):
            b.grid(row=floor(i/5), column=i%5, padx=(5,5), pady=(10,0))
        # control buttons
        self.controlBtns.grid(row=1, column=1, pady=(40,5))
        self.backBtn.grid(row=0, column=0, padx=(10,2))
        self.nextBtn.grid(row=0, column=1, padx=(2,10))
        self.automaticFowardCheckBtn.grid(row=1, column=0, padx=(5,7))
        self.saveBtn.grid(row=1, column=1, padx=(7,5))

if __name__ == "__main__":
    master = Tk()
    master.title('BV Image')
    master.resizable(0,0)

    # create proposal box displayer
    imgDisp = ImageDisp(master)
    master.mainloop()