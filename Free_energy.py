import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# Constants
kB = 0.0019872041  # kcal/mol·K
T = 300

# Load data
hb_df = pd.read_csv("intermol_hbonds.dat", delim_whitespace=True)
sasa_df = pd.read_csv("sasa_combined_total.dat", delim_whitespace=True)

# Extract columns
hb_data = hb_df['intramol[UU]']
sasa_data = sasa_df['SA_00001']

# Ensure equal length
min_len = min(len(hb_data), len(sasa_data))
hb_data = hb_data[:min_len]
sasa_data = sasa_data[:min_len]

# 🔑 KEY FIXES
# Fewer bins + better suited for your data
H, xedges, yedges = np.histogram2d(
    sasa_data,
    hb_data,
    bins=[40, 10],   # ← asymmetric bins (CRITICAL)
    density=True
)

# Avoid log(0)
H = H + 1e-12

# Free energy
F = -kB * T * np.log(H)

# Normalize
F = F - np.min(F)

# Meshgrid
X, Y = np.meshgrid(xedges[:-1], yedges[:-1])

# Plot
plt.figure(figsize=(10, 8))

levels = np.linspace(np.min(F), np.max(F), 50)
contour = plt.contourf(X, Y, F.T, levels=levels)

cbar = plt.colorbar(contour)
cbar.set_label('Free Energy (kcal/mol)', fontsize=38,
               fontname='Times New Roman', fontweight='bold')

# Axis labels
plt.xlabel('SASA (Å²)', fontsize=38,
           fontname='Times New Roman', fontweight='bold')
plt.ylabel('Number of H-bonds', fontsize=38,
           fontname='Times New Roman', fontweight='bold')

# Title
plt.title('Free Energy Surface', fontsize=38,
          fontname='Times New Roman', fontweight='bold')

# Tick styling
plt.xticks(fontsize=22)
plt.yticks(fontsize=22)
ax = plt.gca()
for label in ax.get_xticklabels() + ax.get_yticklabels():
    label.set_fontname('Times New Roman')
    label.set_fontweight('bold')

# Grid
plt.grid(True, linestyle='--', linewidth=2)

plt.tight_layout()
plt.savefig('free_energy_surface.png', dpi=300)
plt.show()
