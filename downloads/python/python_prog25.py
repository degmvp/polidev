print('✅' * 50)
print('''
#---------------------------------------
# ✅ PyVideoV1
# ✅ Python 3.6 alterado: 2017/01/20
# ✅ Objetivo:Download Video from youtube 
# ✅         :Download V-Mp3 from yotube

#---------------------------------------''')
print('✅' * 50)
import pytube
print('Informe o link youtube -->: ')
link = input()

yt = pytube.YouTube(link)
videos = yt.get_videos()

s = 1
for v in videos:
    print(str(s)+'. '+str(v))
    s += 1

print('Informe o numero do videos: ')
n = int(input())
vid = videos[n-1]

print('P:\YTVIDEOS folder destino ')
destination = 'P:\YTVIDEOS'

vid.download(destination)

print(yt.filename+'\n Executado com sucesso!')