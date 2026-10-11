import pandas as pd
import matplotlib.pyplot as plt

# Load data using updated separator
file_path = "dihedral_angle.dat"  # Change if your filename is different
df = pd.read_csv(file_path, sep='\s+')

# Check data structure
print("Columns detected:", df.columns)
print(df.head())

# Define x and y columns
x_col = '#Frame' if '#Frame' in df.columns else df.columns[0]
y_cols = ['BDP_plane']  # Columns to plot

# Set up the plot
fig, ax = plt.subplots(figsize=(10, 6))

# Plot each column with distinct color (no marker for clean lines)
colors = ['#B58900', '#0000FF']
for y_col, color in zip(y_cols, colors):
    ax.plot(df[x_col], df[y_col], linestyle='-', linewidth=1.5, color=color, label=y_col)

# Set axis limits and ticks
ax.set_xlim(0, 140000)
ax.set_ylim(-360, 360)
ax.set_xticks(range(0, 140001, 20000))
ax.set_yticks(range(-360, 361, 100))

# Axis labels
ax.set_xlabel('Frame n° = (1 frame = 20ps)', fontsize=38, fontname='Times New Roman', fontweight='bold')
ax.set_ylabel('Dihedral Angle (°)', fontsize=38, fontname='Times New Roman', fontweight='bold')

# Tick styling
ax.tick_params(axis='both', labelsize=22)
for label in ax.get_xticklabels() + ax.get_yticklabels():
    label.set_fontname('Times New Roman')
    label.set_fontweight('bold')

# Add grid
ax.grid(True, which='major', linestyle='--', linewidth=2, color='gray', alpha=1)

# Add legend
handles, labels = ax.get_legend_handles_labels()
if handles:
    legend = ax.legend(loc='upper right', fontsize=38)
    for text in legend.get_texts():
        text.set_fontname('Times New Roman')
        text.set_fontweight('bold')
else:
    print("⚠️ No handles found for legend — nothing was plotted.")

# Title
ax.set_title('D1Cl1', fontsize=38, fontweight='bold', fontname='Times New Roman', loc='center')

# Save and display
plt.tight_layout()
plt.savefig('Dihedral-Angles.png', dpi=300)
plt.show()

