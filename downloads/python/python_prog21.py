print('✅' * 50)
print('''
#---------------------------------------
# ✅ AppB06
# ✅ Python 3.6 alterado: 2017/08/13
# ✅ Objetivo: import numpy as np
#---------------------------------------''')
print('✅' * 50)
import numpy as np
my_array = np.array([0,1,2,3])
print(my_array)
#array([0, 1, 2, 3])

print(my_array.dtype)
#dtype('int32')

str_array = my_array.astype(str)
for i in my_array:
    print(i * 4)

for i in str_array:
    print(i * 4)

print(len(my_array))

print(len(str_array))

dim2_array = np.array([[0,1,2,3],[0,1,2,3],[0,1,2,3]])
print(dim2_array)
print(dim2_array.ndim)
print(dim2_array.shape)
print(dim2_array.size)
print(np.mean(dim2_array))
print(np.mean(dim2_array, axis = 0))
#array([ 0.,  1.,  2.,  3.])

print(np.mean(dim2_array, axis = 1))
#array([ 1.5,  1.5,  1.5])
print('-' * 30)
print(dim2_array[:])
print('-' * 30)
print(dim2_array[:2])
print('-' * 30)
print(dim2_array[:2,:])
print('-' * 30)
print(dim2_array[:2,:2])
print('-' * 30)
print(dim2_array[::-1])
print('-' * 30)
print(dim2_array[0][::-1])
'''
>>> dim2_array[:]
array([[0, 1, 2, 3],
       [0, 1, 2, 3],
       [0, 1, 2, 3]])
>>> dim2_array[:2]
array([[0, 1, 2, 3],
       [0, 1, 2, 3]])
>>> dim2_array[:2,:]
array([[0, 1, 2, 3],
       [0, 1, 2, 3]])
>>> dim2_array[:2,:2]
array([[0, 1],
       [0, 1]])
>>> dim2_array[::-1]
array([[0, 1, 2, 3],
       [0, 1, 2, 3],
       [0, 1, 2, 3]])
>>> dim2_array[0][::-1]
array([3, 2, 1, 0])'''
x = np.arange(10)
print(x)
