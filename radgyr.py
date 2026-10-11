import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

# Load data
file_path = "radgyr_backbone.dat"
df = pd.read_csv(file_path, delim_whitespace=True)

# Use pep column
y_col = 'pep' if 'pep' in df.columns else df.columns[1]

# Compute histogram
counts, bins = np.histogram(df[y_col], bins=40, range=(3.0, 5.8))

# Bin centers for plotting
bin_centers = 0.5 * (bins[1:] + bins[:-1])

# Set up plot
fig, ax = plt.subplots(figsize=(10, 6))

# Plot as line with markers
ax.plot(bin_centers, counts, marker='o', linestyle='-', color='blue', label='pep')

# X and Y labels
ax.set_xlabel('Radius_of_Gyration (Å)', fontsize=38, fontname='Times New Roman', fontweight='bold')
ax.set_ylabel('Frequency', fontsize=38, fontname='Times New Roman', fontweight='bold')

# Title
ax.set_title('D1Cl1', fontsize=38, fontweight='bold', fontname='Times New Roman')

# Axis limits
ax.set_xlim(3.0, 5.8)
ax.set_ylim(0, 20000)

# Axis ticks
ax.set_xticks(np.arange(3.0, 6.0, 0.5))
ax.set_yticks(range(0, 20001, 3000))

# Ticks
ax.tick_params(axis='both', labelsize=22)
for label in ax.get_xticklabels() + ax.get_yticklabels():
    label.set_fontname('Times New Roman')
    label.set_fontweight('bold')

# Legend
legend = ax.legend(loc='upper right', fontsize=38)
for text in legend.get_texts():
    text.set_fontname('Times New Roman')
    text.set_fontweight('bold')

# Grid
ax.grid(True, which='both', linestyle='--', linewidth=2, alpha=1)

# Save and show
plt.savefig('D1Cl1-Radgyr.png', dpi=300)
plt.show()

