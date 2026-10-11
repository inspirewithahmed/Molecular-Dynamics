import numpy as np
import matplotlib.pyplot as plt

data = np.loadtxt('density.dat', skiprows=1)
time = data[:,0]
density = data[:,1]

plt.plot(time, density)
plt.xlabel('Time (ps)')
plt.ylabel('Density (g/cm³)')
plt.title('Density vs Time')
plt.show()
