import pandas as pd
import matplotlib.pyplot as plt
import glob
import numpy as np

# -------------------------------------------------------
# PARAMETERS
# -------------------------------------------------------

THRESHOLD = 10.0

# -------------------------------------------------------
# READ ALL FILES
# -------------------------------------------------------

data_files = sorted(glob.glob("Aryl_*.dat"))

if len(data_files) == 0:
    raise FileNotFoundError("No files named 'Aryl_*.dat' were found.")

# Read and concatenate
dfs = []

for file in data_files:
    df = pd.read_csv(file, delim_whitespace=True)
    dfs.append(df)

df_concat = pd.concat(dfs, ignore_index=True)

# Frame column
frame_col = '#Frame' if '#Frame' in df_concat.columns else df_concat.columns[0]

x = df_concat[frame_col]

# Interaction columns
ar_cols = [c for c in df_concat.columns if c.startswith("aryl_")]

# -------------------------------------------------------
# SELECT INTERACTIONS THAT EVER GO BELOW THRESHOLD
# -------------------------------------------------------

selected_cols = []

print("\nInteractions reaching ≤ %.1f Å:\n" % THRESHOLD)

for col in ar_cols:

    minimum = df_concat[col].min()

    if minimum <= THRESHOLD:

        selected_cols.append(col)

        print(f"{col:12s} minimum = {minimum:6.2f} Å")

print("\nTotal selected interactions =", len(selected_cols))

# -------------------------------------------------------
# CREATE FIGURE
# -------------------------------------------------------

fig, ax = plt.subplots(figsize=(14,8))

# -------------------------------------------------------
# COLOR SCHEME
# -------------------------------------------------------

colors = (
    list(plt.cm.tab20(np.linspace(0,1,20))) +
    list(plt.cm.tab20b(np.linspace(0,1,20)))
)

colors = colors[:len(selected_cols)]

# -------------------------------------------------------
# PLOT COMPLETE TRAJECTORIES
# -------------------------------------------------------

for color, col in zip(colors, selected_cols):

    ax.plot(
        x,
        df_concat[col],
        linewidth=1.8,
        color=color,
        label=col
    )

# -------------------------------------------------------
# THRESHOLD REGION (SHADED ONLY)
# -------------------------------------------------------

ax.axhspan(
    0,
    THRESHOLD,
    color='lightgray',
    alpha=0.30,
    zorder=0
)

# -------------------------------------------------------
# AXES
# -------------------------------------------------------

ax.set_xlim(0,150000)
ax.set_xticks(np.arange(0,150001,15000))

ax.set_ylim(0,50)
ax.set_yticks(np.arange(0,51,5))

# -------------------------------------------------------
# LABELS
# -------------------------------------------------------

ax.set_xlabel(
    'Frame n° = (1 frame = 20 ps)',
    fontsize=30,
    fontname='Times New Roman',
    fontweight='bold'
)

ax.set_ylabel(
    'Aryl-Aryl Interaction (Å)',
    fontsize=30,
    fontname='Times New Roman',
    fontweight='bold'
)

# -------------------------------------------------------
# TITLE
# -------------------------------------------------------

ax.set_title(
    'D1Cl1_MD',
    fontsize=32,
    fontweight='bold',
    fontname='Times New Roman'
)

# -------------------------------------------------------
# TICKS
# -------------------------------------------------------

ax.tick_params(axis='both', labelsize=18)

for tick in ax.get_xticklabels():
    tick.set_fontname('Times New Roman')
    tick.set_fontweight('bold')

for tick in ax.get_yticklabels():
    tick.set_fontname('Times New Roman')
    tick.set_fontweight('bold')

# -------------------------------------------------------
# GRID
# -------------------------------------------------------

ax.grid(
    True,
    linestyle='--',
    linewidth=0.5,
    color='gray',
    alpha=0.6
)

# -------------------------------------------------------
# LEGEND
# -------------------------------------------------------

legend = ax.legend(
    loc='upper right',
    fontsize=20,
    ncol=4,
    frameon=False
)

for text in legend.get_texts():
    text.set_fontname('Times New Roman')
    text.set_fontweight('bold')

# -------------------------------------------------------
# SAVE
# -------------------------------------------------------

plt.tight_layout()

plt.savefig(
    "Reference_Aryl-Aryl_Selected_10A.png",
    dpi=300,
    bbox_inches='tight'
)

plt.show()
