print('''
#---------------------------------------
# ✅ AppM01
# ✅ Python 3.6 alterado: 2017/08/15
# ✅ Objetivo:O módulo Image 
#---------------------------------------''')
print('✅' * 50)
import tkinter as tk
root = tk.Tk()
from PIL import Image, ImageFilter, ImageOps
import os, sys

def getExtension(name):
   fileName, fileExtension = os.path.splitext(name)
   return fileExtension

def isExtensionPermited(extension):
   extensions = ['png']
   for x in extensions:
       if extension[:1] == '.':
           if extension[1:].lower() == x:
               return True
       elif extension.lower() == x:
           return True
   return False

vetimg = []

def lookupDirectory(path):
   if os.path.isdir(path):
       k = 0
       files = os.listdir(path)
       for i in files:
           if i + '/' != 'windows/':
               if os.path.isdir(path + i + '/'):
                   lookupDirectory(path + i + '/')
               if isExtensionPermited(getExtension(i)) == True:
                  vetimg.append(i)
                  imgx = "P:\\HDRIMG\\"+ vetimg[k]
                  print(imgx)
                  imagem = tk.PhotoImage(file= imgx)
                  w = tk.Label(root, image=imagem)
                  w.imagem = imagem
                  w.pack()
                  img = Image.open(imgx)
                  img.thumbnail((512, 512),
                  Image.ANTIALIAS)
                  img = ImageOps.expand(img,
                                        border=2, fill=1)
                  img.show()
                  k += 1

lookupDirectory('P:\\HDRIMG')


