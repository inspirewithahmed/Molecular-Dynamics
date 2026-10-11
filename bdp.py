import pandas as pd
import matplotlib.pyplot as plt

# Load data
file_path = "BDP-RFP_distance.dat"
df = pd.read_csv(file_path, delim_whitespace=True)

print("Columns detected:", df.columns)
print(df.head())

# Identify x and y columns
x_col = '#Frame' if '#Frame' in df.columns else df.columns[0]
y_cols = ['Ring_A-C', 'Ring_A-D', 'Ring_B-C', 'Ring_B-D']

# Set up plot
fig, ax = plt.subplots(figsize=(10, 6))

# Plot each distance column
#colors = ['blue', 'green', 'red', 'black']
#for y_col, color in zip(y_cols, colors):
    #ax.plot(df[x_col], df[y_col], marker='o', linestyle='-', color=color, label=y_col)

# Plot each column with distinct color (no marker for clean lines)
colors = ['#00008B', '#B58900', '#8B0000', '#800080']
for y_col, color in zip(y_cols, colors):
    ax.plot(df[x_col], df[y_col], linestyle='-', linewidth=1.5, color=color, label=y_col)


# Styling
ax.set_xlim(df[x_col].min(), 140000)
ax.set_ylim(0, 30)
ax.set_xticks(range(0, 140001, 20000))  # Note: 140001 to include 140000
ax.set_yticks(range(0, 31, 5))


ax.set_xlabel('Frame n° = (1 frame = 20ps)', fontsize=38, fontname='Times New Roman', fontweight='bold')
ax.set_ylabel('Ring–Ring Distance (Å)', fontsize=38, fontname='Times New Roman', fontweight='bold')

# Tick styling
ax.tick_params(axis='both', labelsize=22)
for label in ax.get_xticklabels() + ax.get_yticklabels():
    label.set_fontname('Times New Roman')
    label.set_fontweight('bold')

# Title
ax.set_title('D1Cl1', fontsize=38, fontweight='bold', fontname='Times New Roman', loc='center')

# Legend
handles, labels = ax.get_legend_handles_labels()
if handles:
    legend = ax.legend(loc='upper right', fontsize=28)
    for text in legend.get_texts():
        text.set_fontname('Times New Roman')
        text.set_fontweight('bold')
else:
    print("⚠️ No handles found for legend — nothing was plotted.")

# Add grid
ax.grid(True, which='both', linestyle='--', linewidth=2, alpha=1)


# Save and show plot
plt.tight_layout()
plt.savefig('Ring-Ring-Distances.png', dpi=300)
plt.show()

