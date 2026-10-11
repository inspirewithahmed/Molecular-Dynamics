import pandas as pd
import matplotlib.pyplot as plt

# Load data
file_path = "intermol_hbonds.dat"
df = pd.read_csv(file_path, delim_whitespace=True)

print("Columns detected:", df.columns)  # 👈 Make sure column names are as expected
print(df.head())  # 👈 Preview first few lines

# Use actual column names
x_col = '#Frame' if '#Frame' in df.columns else df.columns[0]
y_col = 'H-bond' if 'H-bond' in df.columns else df.columns[1]

# Set up plot
fig, ax = plt.subplots(figsize=(10, 6))
ax.plot(df[x_col], df[y_col], marker='o', linestyle='-', color='blue',
        label='Number of H-bonds')

# Confirm what is registered for legend
handles, labels = ax.get_legend_handles_labels()
print("Legend handles and labels:", labels)  # 👈 Check this

# Continue with styling
ax.set_xlim(0, 140000)
ax.set_ylim(0, 15)
ax.set_xticks(range(0, 140001, 20000))
ax.set_yticks(range(0, 16, 2))
ax.set_xlabel('Frame n° = (1 frame = 20ps)', fontsize=38, fontname='Times New Roman', fontweight='bold')
ax.set_ylabel('Number of H-bonds', fontsize=38, fontname='Times New Roman', fontweight='bold')
#ax.set_title('D1Cl1', fontsize=20, fontname='Times New Roman', fontweight='bold')

# Set tick font
ax.tick_params(axis='both', labelsize=22)
for label in ax.get_xticklabels() + ax.get_yticklabels():
    label.set_fontname('Times New Roman')
    label.set_fontweight('bold')  # ✅ Correct indentation here

ax.set_title('D1Cl1', fontsize=38, fontweight='bold', fontname='Times New Roman', loc='center')


# Add legend if any handles exist
if handles:
    legend = ax.legend(loc='upper right', fontsize=38)
    for text in legend.get_texts():
        text.set_fontname('Times New Roman')
        text.set_fontweight('bold')
else:
    print("⚠️ No handles found for legend — nothing was plotted.")

# Add grid
ax.grid(True, which='both', linestyle='--', linewidth=2, alpha=1)

# Finish plot
#ax.grid(True)
plt.savefig('D1Cl1-H-bond.png', dpi=300)
plt.show()

