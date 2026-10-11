"""
H-bond Analysis Plotter
========================
Takes CPPTRAJ intermolecular H-bond output and plots H-bond count vs. frame.
Accepts command-line arguments so you don't have to edit the script for each system.

Usage
-----
    python H-bond.py                            # uses defaults defined below
    python H-bond.py --input my_hbonds.dat
    python H-bond.py --input my_hbonds.dat --output my_plot.png --title MySystem_aMD

Input format
------------
    Whitespace-delimited file with at least two columns:
        #Frame    H-bond
        0         45
        1         47
        ...

Output
------
    PNG figure at 300 dpi (or whatever --dpi you pass).

Author: Saeed Ahmed (saeed.ahmed@unimi.it)
"""

import argparse
import sys
import pandas as pd
import matplotlib.pyplot as plt

# ---------------------------------------------------------------------------
# USER CONFIGURATION  (edit here, or pass command-line arguments)
# ---------------------------------------------------------------------------
DEFAULT_INPUT  = "intermol_hbonds.dat"
DEFAULT_OUTPUT = "D1Cl1-H-bond.png"
DEFAULT_TITLE  = "D1Cl1_aMD"
DEFAULT_DPI    = 300

FRAME_MIN, FRAME_MAX, FRAME_STEP = 0, 80_000, 10_000
HBOND_MIN, HBOND_MAX, HBOND_STEP = 30, 130, 10
# ---------------------------------------------------------------------------


def parse_args():
    parser = argparse.ArgumentParser(description="Plot H-bond count vs. simulation frame.")
    parser.add_argument("--input",  default=DEFAULT_INPUT,  help="Input .dat file (default: %(default)s)")
    parser.add_argument("--output", default=DEFAULT_OUTPUT, help="Output PNG filename (default: %(default)s)")
    parser.add_argument("--title",  default=DEFAULT_TITLE,  help="Plot title (default: %(default)s)")
    parser.add_argument("--dpi",    default=DEFAULT_DPI, type=int, help="Output DPI (default: %(default)s)")
    return parser.parse_args()


def load_data(filepath: str) -> pd.DataFrame:
    """Load whitespace-delimited CPPTRAJ output into a DataFrame."""
    try:
        # sep=r'\s+' replaces the deprecated delim_whitespace=True
        df = pd.read_csv(filepath, sep=r'\s+')
    except FileNotFoundError:
        sys.exit(f"[ERROR] Input file not found: {filepath}")
    except Exception as exc:
        sys.exit(f"[ERROR] Could not read {filepath}: {exc}")
    return df


def select_columns(df: pd.DataFrame):
    """Return (x_col, y_col) — prefer named columns, fall back to positional."""
    x_col = "#Frame" if "#Frame" in df.columns else df.columns[0]
    y_col = "H-bond" if "H-bond" in df.columns else df.columns[1]
    return x_col, y_col


def make_plot(df: pd.DataFrame, x_col: str, y_col: str, title: str, output: str, dpi: int):
    font = {"fontname": "Times New Roman", "fontweight": "bold"}

    fig, ax = plt.subplots(figsize=(10, 6))

    ax.plot(df[x_col], df[y_col],
            color="steelblue", linestyle="-", linewidth=1.5,
            marker="o", markersize=3, label="H-bond count")

    # Axis limits and ticks
    ax.set_xlim(FRAME_MIN, FRAME_MAX)
    ax.set_ylim(HBOND_MIN, HBOND_MAX)
    ax.set_xticks(range(FRAME_MIN, FRAME_MAX + 1, FRAME_STEP))
    ax.set_yticks(range(HBOND_MIN, HBOND_MAX + 1, HBOND_STEP))

    # Labels and title
    ax.set_xlabel("Frame  (1 frame = 20 ps)", fontsize=14, **font)
    ax.set_ylabel("H-bond Count",              fontsize=14, **font)
    ax.set_title(title,                         fontsize=16, **font)

    # Tick font
    for label in ax.get_xticklabels() + ax.get_yticklabels():
        label.set_fontname("Times New Roman")
        label.set_fontweight("bold")
        label.set_fontsize(11)

    # Grid and legend
    ax.grid(True, which="major", linestyle="--", linewidth=0.8, color="gray", alpha=0.7)
    ax.legend(loc="upper right", fontsize=11)

    plt.tight_layout()
    plt.savefig(output, dpi=dpi)
    print(f"[OK] Figure saved → {output}")
    plt.show()


def main():
    args = parse_args()
    df = load_data(args.input)
    x_col, y_col = select_columns(df)
    print(f"[INFO] Loaded {len(df)} frames from '{args.input}'  (x={x_col}, y={y_col})")
    make_plot(df, x_col, y_col, title=args.title, output=args.output, dpi=args.dpi)


if __name__ == "__main__":
    main()
