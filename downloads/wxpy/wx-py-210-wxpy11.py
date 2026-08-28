print('✅' * 50)
print('''
#-------------------------------------------------------
# ✅ Pyaudio10
# ✅ Python 3.6 alterado: 2018/06/10
# ✅ Objetivo:cmd avançado mediaplayer mp3,wav
# ✅ Comandos:import pygame,random,time,timeit,messagebox,from tkinter
# ✅ Funções :open(),close(),readline(),get(),set(),place(),Entry()
#-------------------------------------------------------''')
print('✅' * 50)
import imp
import os, sys
import pygame
from tkinter import *
import time
import timeit
from time import strftime
import tkinter as tk
import subprocess
from PIL import Image, ImageFilter, ImageOps
import simpleaudio as sa

root = Tk()
root.title("Media Player ✅ Pyaudio10 ")
root.geometry("850x550")
root.configure(bg="#006")
root.fg = "GOLDENROD"
root.resizable(width=False, height=False)

lista = []
listofsongs = []
index = 0
global flag
flag = int(input('Digite (0 ou 1) --> : '))
# ---------------------------------------------------------
rel = tk.Button(relief=SUNKEN)
rel['text'] = '00:00:00'
rel.place(x=10, y=15)
rel['font'] = 'Helvetica 12 bold'
rel['bd'] = 16
rel['bg'] = '#D4C4A8'
rel['fg'] = 'black'
# ---------------------------------------------------------
loadimage = tk.PhotoImage(file='P:\HDRIMG/btn3.png')
roundedbutton = tk.Button(root, image=loadimage)
roundedbutton["bg"] = "#006"
roundedbutton["border"] = "4"

loadimage1 = tk.PhotoImage(file='P:\HDRIMG/btn5.png')
roundedbutton1 = tk.Button(root, image=loadimage1)
roundedbutton1["bg"] = "#006"
roundedbutton1["border"] = "4"

loadimage2 = tk.PhotoImage(file='P:\HDRIMG/btn1.png')
roundedbutton2 = tk.Button(root, image=loadimage2)
roundedbutton2["bg"] = "#006"
roundedbutton2["border"] = "4"

loadimage3 = tk.PhotoImage(file='P:\HDRIMG/btn2.png')
roundedbutton3 = tk.Button(root, image=loadimage3)
roundedbutton3["bg"] = "#006"
roundedbutton3["border"] = "4"


# ---------------------------------------------------------
def fla():
    try:
        imp.reload(flagExterna)
        flagExterna.ponteiro()
        directorychooser()
    except Exception as e:
        print(str(e))


def called(event):
    root.destroy()


def callex(event):
    subprocess.call(["Explorer.exe"])
    print('Explorer chamado com sucesso!')
    status['text'] = 'Processing --> Explorer! '


def callplay(event):
    r2.destroy()


def nextsong(event):
    global index
    index += 1
    pygame.mixer.music.load(listofsongs[index])
    pygame.mixer.music.play()
    status['text'] = 'Playing ----->>>>>> ' + listofsongs[index] + '   index-->' + str(index)
    # flag1()


def prevsong(event):
    global index
    index -= 1
    pygame.mixer.music.load(listofsongs[index])
    pygame.mixer.music.play()
    status['text'] = 'Playing ----->>>>>> ' + listofsongs[index] + '   index-->' + str(index)


def stopsong(event):
    global index
    index = 0
    pygame.mixer.music.stop()


def timeclock(event):
    tac()
    flag0()


def cargaplay():
    archivo = open('mp1.txt', 'r')
    linea = archivo.readline()
    if linea:
        while linea:
            if linea[-1] == '\n':
                linea = linea[:-1]
            lista.append(linea)
            linea = archivo.readline()
    archivo.close()


def carga():
    archivo = open('mp.txt', 'r')
    linea = archivo.readline()
    if linea:
        while linea:
            if linea[-1] == '\n':
                linea = linea[:-1]
            lista.append(linea)
            linea = archivo.readline()
    archivo.close()


def r_play():
    pygame.mixer.init()
    pygame.mixer.music.load(listofsongs[0])
    pygame.mixer.music.play()
    status['text'] = 'Playing ----->>>>>> ' + listofsongs[0]


def directorychooser():
    global listofsongs
    directory = 'P:\\app_prog_xpydb\\app_area_tools'
    os.chdir(directory)

    for files in os.listdir(directory):
        if files.endswith('mp3'):
            listofsongs.append(files)
    listofsongs = sorted(listofsongs)
    r_play()


def directoryplay():
    global listofsongs
    directory = 'P:\\app_prog_xpydb\\app_area_music'
    os.chdir(directory)

    for files in os.listdir(directory):
        if files.endswith('mp3'):
            listofsongs.append(files)
    listofsongs = sorted(listofsongs)
    r_play()


label = Label(root, text='Music Media Player ', bg="#006", fg="#A9ACB6", \
              font=('Helvetica', 20)).place(x=230, y=10)
# -------------------------------------------------------------------------------------
status = Label(root, text='Preparing status bar...', fg='navy', bg='GOLDENROD', bd=1, relief=SUNKEN, anchor=W)
status.pack(side=BOTTOM, fill=X)
# -------------------------------------------------------------------------------------
if flag == 0:
    carga()
    r = Text(root, width=35, height=18, bg='#D4C4A8', fg="navy", relief="sunken", border=16)
    r['font'] = "time 10 bold"
    r.insert(INSERT, 'Playlist-Green Next: Gray Prev \n')
    lista = sorted(lista)
    for elemento in lista:
        arreglo = elemento.split('$')
        r.insert(INSERT, arreglo[0] + '\t\n')
        r.place(x=30, y=190)
# -----------------------------------------------------------------------------------------------
if flag == 1:
    cargaplay()
    r1 = Text(root, width=35, height=18, bg='#6A5D1B', relief="sunken", border=16)
    r1['font'] = "time 10 bold"
    r1['bg'] = '#D4C4A8'
    r1['fg'] = '#6A5D1B'
    r1.insert(INSERT, 'Playlist-Green Next: Gray Prev \n')
    lista = sorted(lista)
    for elemento in lista:
        arreglo = elemento.split('$')
        r1.insert(INSERT, arreglo[0] + '\t\n')
        r1.place(x=30, y=190)
    # -------------------------------------------------------------------------------


def flag1():
    global r2
    r2 = Text(root, width=35, height=18, bg='#D4C4A8', relief="groove", border=16)
    r2['bg'] = '#D4C4A8'
    r2.place(x=350, y=190)
    logo = PhotoImage(file='P:\HDRIMG/cap1.png')
    r2.logo = Label(r2, bg='black')
    r2.logo['image'] = logo
    r2.logo.image = logo
    r2.logo.pack()


def flag0():
    global r2
    r2 = Text(root, width=35, height=18, bg='#D4C4A8', relief="groove", border=16)
    r2['bg'] = '#D4C4A8'  # '#9B4703' # '#D4C4A8'
    r2.place(x=350, y=190)
    logo = PhotoImage(file='P:\HDRIMG/cap1.png')
    r2.logo = Label(r2, bg='black')
    r2.logo['image'] = logo
    r2.logo.image = logo
    r2.logo.pack()


# -------------------------------------------------------------------------------
nextbutton = roundedbutton  # Button(root,text='Next song',bg='GOLDENROD',relief="groove", border=16)
nextbutton.place(x=30, y=115)
prevbutton = roundedbutton1  # Button(root,text='Previous ',bg='GOLDENROD',relief="groove", border=16)
prevbutton.place(x=105, y=115)
stopbutton = roundedbutton2  # Button(root,text='Stop song ',bg='GOLDENROD',relief="groove", border=16)
stopbutton.place(x=180, y=115)
timebutton = roundedbutton3  # Button(root,text='Time Clock ',bg='GOLDENROD',relief="groove", border=16)
timebutton.place(x=255, y=115)

edbutton = Button(root, text='ShutDown', bg='#6A5D1B', fg='white', relief="groove", border=16)
edbutton.place(x=355, y=115)
exbutton = Button(root, text='Explorer', bg='Green', fg='white', relief="groove", border=16)
exbutton.place(x=450, y=115)

plbutton = Button(root, text='Stop-all', bg='#6A5D1B', fg='white', relief="groove", border=16)
plbutton.place(x=530, y=115)

nextbutton.bind("<Button-1>", nextsong)
prevbutton.bind("<Button-1>", prevsong)
stopbutton.bind("<Button-1>", stopsong)
timebutton.bind("<Button-1>", timeclock)
edbutton.bind("<Button-1>", called)
exbutton.bind("<Button-1>", callex)
plbutton.bind("<Button-1>", callplay)


def tac():
    rel['text'] = strftime('%H:%M:%S')
    rel.after(1000, tac)


if flag == 0:
    print('flag  ', flag)
    directorychooser()
else:
    if flag == 1:
        print('flag  ', flag)
        directoryplay()

root.mainloop()
