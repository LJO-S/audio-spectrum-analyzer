from pylab import *
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import to_rgba_array

cmap = cm.get_cmap("plasma")

k = 0
hex_colors = list()
for i in range(cmap.N):
    k += 1
    rgba = cmap(i)
    # rgb2hex accepts rgb or rgba
    print(matplotlib.colors.rgb2hex(rgba))
    hex_colors.append(matplotlib.colors.rgb2hex(rgba))


plt.imshow(to_rgba_array(hex_colors).reshape(1, len(hex_colors), 4))
plt.show()
