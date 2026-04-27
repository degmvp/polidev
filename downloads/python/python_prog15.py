print('✅' * 50)
print('''
#---------------------------------------
# ✅ AppB01 
# ✅ Python 3.66 alterado: 2018/08/04
# ✅ Objetivo: Ler uma imagem.jpg/png
#---------------------------------------''')
print('✅' * 50)
import matplotlib.pyplot as plt
import matplotlib.cbook as cbook

image_file = cbook.get_sample_data('P:\\app_prog_xpydb\\app_abmzs\modulo.png')

image = plt.imread(image_file)

fig, ax = plt.subplots()
ax.imshow(image)
ax.axis('off')  # clear x- and y-axes
plt.show()
