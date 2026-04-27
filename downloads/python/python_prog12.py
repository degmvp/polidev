print('✅' * 50)
print('''
#---------------------------------------
# ✅ binN07
# ✅ Python 3.6 alterado: 2018/07/29
# ✅ Objetivo:container-scroll-multi-pges
# ✅         :Gerenciador de Telas
#---------------------------------------''')
print('✅' * 50)
import tkinter as tk  # python 3
from tkinter import font  as tkfont  # python 3
import io
from contextlib import redirect_stdout


class SampleApp(tk.Tk):

    def __init__(self, *args, **kwargs):
        tk.Tk.__init__(self, *args, **kwargs)

        self.title_font = tkfont.Font(family='Helvetica', size=12, weight="bold", slant="italic")

        # the container is where we'll stack a bunch of frames
        # on top of each other, then the one we want visible
        # will be raised above the others
        container = tk.Frame(self)
        container.pack(side="top", fill="both", expand=True)
        container.grid_rowconfigure(0, weight=1)
        container.grid_columnconfigure(0, weight=1)

        self.frames = {}
        for F in (StartPage, PageOne, PageTwo, Page3):
            page_name = F.__name__
            frame = F(parent=container, controller=self)
            self.frames[page_name] = frame

            # put all of the pages in the same location;
            # the one on the top of the stacking order
            # will be the one that is visible.
            frame.grid(row=0, column=0, sticky="nsew")

        self.show_frame("StartPage")

    def show_frame(self, page_name):
        '''Show a frame for the given page name'''
        frame = self.frames[page_name]
        frame.tkraise()


class StartPage(tk.Frame):

    def __init__(self, parent, controller):
        tk.Frame.__init__(self, parent, bg='#006')
        self.controller = controller
        label = tk.Label(self, bd=8, text="Gerenciador de Telas --> BinN07 ", bg='GOLDENROD',
                         font=controller.title_font)
        label.pack(side="top", fill="x", pady=10)

        button1 = tk.Button(self, bd=16, text="Chama Tela 1", bg='GOLDENROD', fg='white',
                            command=lambda: controller.show_frame("PageOne"))
        button2 = tk.Button(self, bd=16, text="Chama Tela 2", bg='red', fg='white',
                            command=lambda: controller.show_frame("PageTwo"))
        button4 = tk.Button(self, bd=16, text="Chama Tela 3", bg='GOLDENROD', fg='white',
                            command=lambda: controller.show_frame("Page3"))
        button3 = tk.Button(self, bd=16, text="Final prog! ", bg='green', fg='white',
                            command=exit)
        button1.pack()
        button2.pack()
        button4.pack()
        button3.pack()

    def exit():
        app.destroy()


class PageOne(tk.Frame):

    def __init__(self, parent, controller):
        tk.Frame.__init__(self, parent, bg='gray')
        self.controller = controller
        label = tk.Label(self, bd=16, text="Tela 1 - App --> BINN07", bg='red', font=controller.title_font)
        label.pack(side="top", fill="x", pady=10)

        bt3 = tk.Button(self, bd=16, text="Visual Tela", bg='#006', fg='#FFF', \
                        command=self.visual)
        bt3.pack()
        bt1 = tk.Button(self, bd=16, text="Ler texto", bg='#006', fg='#FFF', \
                        command=self.helpForm)
        bt1.pack()
        bt2 = tk.Button(self, bd=16, text="Del texto", bg='#006', fg='#FFF', \
                        command=self.clearForm)
        bt2.pack()

        bt4 = tk.Button(self, bd=16, text="Close-V", bg='#006', fg='#FFF', \
                        command=self.close)
        bt4.pack()

        button = tk.Button(self, bd=16, text="Gerenciador", bg='red',
                           command=lambda: controller.show_frame("StartPage"))
        button.pack()
        # ----------------------------------------------------

    def visual(self):
        self.wintxt = tk.Tk()
        self.wintxt.title('Visualização de Texto - BinN07 - Tela 1')

        scrollbar = tk.Scrollbar(self.wintxt)
        c = tk.Canvas(self.wintxt, background='#006', yscrollcommand=scrollbar.set)
        scrollbar.config(command=c.yview)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        self.elframe = tk.Frame(c)
        width = 600
        height = 600
        x = (self.wintxt.winfo_screenwidth() // 2) - (width // 2)
        y = (self.wintxt.winfo_screenheight() // 2) - (height // 2)

        c.pack(side='left', fill='both', expand=True)
        c.create_window(0, 0, window=self.elframe, anchor='ne')
        self.wintxt.geometry('{}x{}+{}+{}'.format(width, height, x, y))
        self.labex = tk.Label(self.elframe, wraplength=16000, width=80, height=500, text=' ', bg='#006', fg='#FFF')
        self.labex.pack()
        self.wintxt.update()
        c.config(scrollregion=c.bbox('all'))

    def helpForm(self):
        vet = []
        arqv = 'P:\\app_prog_xpydb\\adv_bin\SQL1.txt'
        if arqv != '':
            with open(arqv) as f:
                for i in f:
                    vet.append(i)
        # redirecionamento da função print()
        file = io.StringIO()
        with redirect_stdout(file):
            for i, x in enumerate(vet):
                print("{0:<0}".format(vet[i]), end="")
            output = file.getvalue()
            self.labex['text'] = output

    def clearForm(self):
        self.labex['text'] = ' '

    def close(self):
        self.wintxt.destroy()


class PageTwo(tk.Frame):

    def __init__(self, parent, controller):
        tk.Frame.__init__(self, parent, bg='gray')
        self.controller = controller
        label = tk.Label(self, bd=8, text="Tela 2  - App --> cmd007", bg='red', font=controller.title_font)
        label.pack(side="top", fill="x", pady=10)

        bt3 = tk.Button(self, bd=8, text="Visual Tela", bg='#006', fg='#FFF', \
                        command=self.visual2)
        bt3.pack()

        bt1 = tk.Button(self, bd=8, text="Ler texto", bg='#006', fg='#FFF', \
                        command=self.fonte)
        bt1.pack()
        bt2 = tk.Button(self, bd=8, text="Del texto", bg='#006', fg='#FFF', \
                        command=self.clearForm2)
        bt2.pack()

        bt4 = tk.Button(self, bd=8, text="Close-V", bg='#006', fg='#FFF', \
                        command=self.close2)
        bt4.pack()
        button = tk.Button(self, bd=8, text="Gerenciador", bg='red',
                           command=lambda: controller.show_frame("StartPage"))
        button.pack()
        # ------------------------------------------------------------

    def visual2(self):
        self.wintxt = tk.Tk()
        self.wintxt.title('Visualização de Texto - BinN07 - Tela 2')

        scrollbar = tk.Scrollbar(self.wintxt)
        c = tk.Canvas(self.wintxt, background='#006', yscrollcommand=scrollbar.set)
        scrollbar.config(command=c.yview)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        self.elframe = tk.Frame(c)
        width = 600
        height = 600
        x = (self.wintxt.winfo_screenwidth() // 2) - (width // 2)
        y = (self.wintxt.winfo_screenheight() // 2) - (height // 2)

        c.pack(side='left', fill='both', expand=True)
        c.create_window(0, 0, window=self.elframe, anchor='ne')
        self.wintxt.geometry('{}x{}+{}+{}'.format(width, height, x, y))
        self.labex = tk.Label(self.elframe, wraplength=16000, width=80, height=500, text=' ', bg='#006', fg='#FFF')
        self.labex.pack()
        self.wintxt.update()
        c.config(scrollregion=c.bbox('all'))

    def fonte(self):
        vet = []
        arqv = 'P:\\app_prog_xpydb\\adv_bin\SQL1.txt'
        if arqv != '':
            with open(arqv) as f:
                for i in f:
                    vet.append(i)
        # redirecionamento da função print()
        file = io.StringIO()
        with redirect_stdout(file):
            for i, x in enumerate(vet):
                print("{0:<0}".format(vet[i]), end="")
            output = file.getvalue()
            self.labex['text'] = output

    def clearForm2(self):
        self.labex['text'] = ' '

    def close2(self):
        self.wintxt.destroy()


class Page3(tk.Frame):

    def __init__(self, parent, controller):
        tk.Frame.__init__(self, parent, bg='gray')
        self.controller = controller
        label = tk.Label(self, bd=8, text="Tela 3  - App --> BINN07", bg='red', font=controller.title_font)
        label.pack(side="top", fill="x", pady=10)

        bt3 = tk.Button(self, bd=8, text="Visual Tela", bg='#006', fg='#FFF', \
                        command=self.visual3)
        bt3.pack()

        bt1 = tk.Button(self, bd=8, text="Ler texto", bg='#006', fg='#FFF', \
                        command=self.fonte)
        bt1.pack()
        bt2 = tk.Button(self, bd=8, text="Del texto", bg='#006', fg='#FFF', \
                        command=self.clearForm3)
        bt2.pack()

        bt4 = tk.Button(self, bd=8, text="Close-V", bg='#006', fg='#FFF', \
                        command=self.close3)
        bt4.pack()
        button = tk.Button(self, bd=8, text="Gerenciador", bg='red',
                           command=lambda: controller.show_frame("StartPage"))
        button.pack()

        # ------------------------------------------------------------

    def visual3(self):
        self.wintxt = tk.Tk()
        self.wintxt.title('Visualização de Texto - BinN07 - Tela 3')

        scrollbar = tk.Scrollbar(self.wintxt)
        c = tk.Canvas(self.wintxt, background='#006', yscrollcommand=scrollbar.set)
        scrollbar.config(command=c.yview)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        self.elframe = tk.Frame(c)
        width = 600
        height = 600
        x = (self.wintxt.winfo_screenwidth() // 2) - (width // 2)
        y = (self.wintxt.winfo_screenheight() // 2) - (height // 2)

        c.pack(side='left', fill='both', expand=True)
        c.create_window(0, 0, window=self.elframe, anchor='ne')
        self.wintxt.geometry('{}x{}+{}+{}'.format(width, height, x, y))
        self.labex = tk.Label(self.elframe, wraplength=16000, width=80, height=500, text=' ', bg='#006', fg='#FFF')
        self.labex.pack()
        self.wintxt.update()
        c.config(scrollregion=c.bbox('all'))

    def fonte(self):
        vet = []
        arqv = 'P:\\app_prog_xpydb\\adv_bin\SQL1.txt'
        if arqv != '':
            with open(arqv) as f:
                for i in f:
                    vet.append(i)
        # redirecionamento da função print()
        file = io.StringIO()
        with redirect_stdout(file):
            for i, x in enumerate(vet):
                print("{0:<0}".format(vet[i]), end="")
            output = file.getvalue()
            self.labex['text'] = output

    def clearForm3(self):
        self.labex['text'] = ' '

    def close3(self):
        self.wintxt.destroy()


if __name__ == "__main__":
    app = SampleApp()
    app.title('Container Frame')
    app.geometry("512x412")
    app.mainloop()
