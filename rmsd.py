import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

# Load data
file_path = "rmsd_backbone.dat"
df = pd.read_csv(file_path, delim_whitespace=True)

# Confirm column names
print("Columns detected:", df.columns)
print(df.head())

# Determine column names
x_col = '#Frame' if '#Frame' in df.columns else df.columns[0]
y_col = 'RMSD_00001' if 'RMSD_00001' in df.columns else df.columns[1]

# Set up plot
fig, ax = plt.subplots(figsize=(10, 6))
ax.plot(df[x_col], df[y_col], marker='o', linestyle='-', color='blue', label='RMSD (Å)')

# Confirm legend contents
handles, labels = ax.get_legend_handles_labels()
print("Legend handles and labels:", labels)

# Dynamically set y-axis limits and ticks
y_min = df[y_col].min()
y_max = df[y_col].max()
y_pad = (y_max - y_min) * 0.05  # 5% of y-range

# Adjust padded limits
y_min_pad = y_min - y_pad
y_max_pad = y_max + y_pad
y_range = y_max_pad - y_min_pad

# Safe tick step
y_tick_step = max(0.1, round(y_range / 6, 2))  # At least 0.1 and with 2 decimal precision
y_ticks = np.arange(y_min_pad, y_max_pad + y_tick_step, y_tick_step)

# Apply fixed x-ticks and dynamic y-limits
ax.set_xlim(0, 140000)
ax.set_xticks(range(0, 140001, 20000))
ax.set_ylim(y_min_pad, y_max_pad)
ax.set_yticks(y_ticks)

# Labels and fonts
ax.set_xlabel('Frame n° = (1 frame = 20ps)', fontsize=38, fontname='Times New Roman', fontweight='bold')
ax.set_ylabel('RMSD (Å)', fontsize=38, fontname='Times New Roman', fontweight='bold')

# Set tick font
ax.tick_params(axis='both', labelsize=22)
for label in ax.get_xticklabels() + ax.get_yticklabels():
    label.set_fontname('Times New Roman')
    label.set_fontweight('bold')

ax.set_title('D1Cl1', fontsize=38, fontweight='bold', fontname='Times New Roman', loc='center')

# Legend
if handles:
    legend = ax.legend(loc='upper right', fontsize=38)
    for text in legend.get_texts():
        text.set_fontname('Times New Roman')
        text.set_fontweight('bold')
else:
    print("⚠️ No handles found for legend — nothing was plotted.")

# Add grid
ax.grid(True, which='both', linestyle='--', linewidth=2, alpha=1)


# Save and show
plt.savefig('D1Cl1-RMSD.png', dpi=300)
plt.show()

