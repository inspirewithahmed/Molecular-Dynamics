import pandas as pd
import matplotlib.pyplot as plt

# Load data
file_path = "sasa_combined_total.dat"
df = pd.read_csv(file_path, delim_whitespace=True)

# Confirm column names
print("Columns detected:", df.columns)
print(df.head())

# Determine column names
x_col = '#Frame' if '#Frame' in df.columns else df.columns[0]
y_col = 'SA_00001' if 'SA_00001' in df.columns else df.columns[1]

# Set up plot
fig, ax = plt.subplots(figsize=(10, 6))
ax.plot(df[x_col], df[y_col], marker='o', linestyle='-', color='blue', label='SASA (Å²)')

# Confirm legend contents
handles, labels = ax.get_legend_handles_labels()
print("Legend handles and labels:", labels)

# Dynamically set y-axis limits and ticks
y_min = df[y_col].min()
y_max = df[y_col].max()
y_pad = (y_max - y_min) * 0.05  # 5% of y-range
y_tick_step = round((y_max - y_min) / 6, -2) if (y_max - y_min) > 600 else 200

# Apply fixed x-ticks and dynamic y-limits
ax.set_xlim(0, 140000)
ax.set_xticks(range(0, 140001, 20000))
ax.set_ylim(y_min - y_pad, y_max + y_pad)
ax.set_yticks(range(int(y_min - y_pad), int(y_max + y_pad) + 1, int(y_tick_step)))

# Labels and fonts
ax.set_xlabel('Frame n° = (1 frame = 20ps)', fontsize=38, fontname='Times New Roman', fontweight='bold')
ax.set_ylabel('SASA (Å²)', fontsize=38, fontname='Times New Roman', fontweight='bold')

# Set tick font
ax.tick_params(axis='both', labelsize=22)
for label in ax.get_xticklabels() + ax.get_yticklabels():
    label.set_fontname('Times New Roman')
    label.set_fontweight('bold')  # ✅ Correct indentation here

ax.set_title('D1Cl1', fontsize=38, fontweight='bold', fontname='Times New Roman', loc='center')

# Add grid
ax.grid(True, which='both', linestyle='--', linewidth=2, alpha=1)


# Legend
if handles:
    legend = ax.legend(loc='upper right', fontsize=38)
    for text in legend.get_texts():
        text.set_fontname('Times New Roman')
        text.set_fontweight('bold')
else:
    print("⚠️ No handles found for legend — nothing was plotted.")

# Save and show
plt.savefig('D1Cl1-SASA.png', dpi=300)
plt.show()

