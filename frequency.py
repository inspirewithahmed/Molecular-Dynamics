import pandas as pd
import matplotlib.pyplot as plt

# File path
file_path = "intermol_hbonds.dat"

# Read the data (whitespace-separated)
df = pd.read_csv(file_path, delim_whitespace=True)

# ✅ Create figure and axes first
fig, ax = plt.subplots(figsize=(10, 6))

# ✅ Plot with label (for legend)
#plt.figure(figsize=(10, 6))
ax.plot(df['#Frame'], df['H-bond'], marker='o', linestyle='-', color='blue')

# Set axis limits and ticks
plt.xlim(0, 68000)
plt.ylim(0, 30)
plt.xticks(range(0, 68001, 10000), fontsize=18, fontname='Times New Roman')
plt.yticks(range(0, 31, 5), fontsize=18, fontname='Times New Roman')
#plt.xticks(range(0, 68001, 20000))
#plt.yticks(range(0, 31, 5))

# Labels and title
plt.xlabel('Frame n° = (1 frame = 20ps)', fontdict={'fontsize': 20, 'fontname': 'Times New Roman', 'fontweight': 'bold'})
plt.ylabel('Number of H-bonds', fontdict={'fontsize': 20, 'fontname': 'Times New Roman', 'fontweight': 'bold'})
plt.title('D1Cl1', fontdict={'fontsize': 20, 'fontname': 'Times New Roman', 'fontweight': 'bold'})

# Add legend
plt.plot(df['#Frame'], df ['H-bond'], color='blue', marker='o', linestyle='-', label='H-bond')
#plt.legend(loc='upper right', fontsize=14, frameon=True, facecolor='white', edgecolor='blue')
#plt.xlabel('Frame n° = (1 frame = 20ps)')
#plt.ylabel('Number of H-bonds')
#plt.title('D1Cl1')
#plt.grid(True)

# Save the plot
plt.savefig('D1Cl1-H-bond.png', dpi=300)

# Show the plot
plt.show()

