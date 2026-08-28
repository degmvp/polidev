print('✅' * 50)
print('''
#----------------------------------------------------
# ✅ trick05
# ✅ Python 3.6 alterado: 2018/09/09
# ✅ Objetivo: Videos do youtube
#----------------------------------------------------''')
print('✅' * 50)

import os
from tkinter import *

def PlayYT():
    url = video.get()
    if url != "" and IsValidURL(url):
        os.system("vlc "+url)
    else:
        video.set('Informe uma URL válida!')

def IsValidURL(url):
    ref = 'https://www.youtube.com'
    return url.startswith(ref)


def Limpar(event):
    video.set('')

def Sair():
    root.destroy()

root = Tk()
root.title("Media Player ✅ PyV1Media ")
root.geometry("850x550")
root.configure(bg="#006")
root.fg="GOLDENROD"
root.resizable(width=False, height=False)


video = StringVar()
txt = Entry(root, textvariable=video)
txt.pack()

bnt_play = Button(root, text='Play', command=PlayYT)
bnt_play.pack()

bnt_sair = Button(root, text='Sair', command=Sair)
bnt_sair.pack()


txt.bind("<Button-1>", Limpar)

root.mainloop()