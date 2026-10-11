num_molecules = 10
col_spacing = 25.0
row_spacing = 14.0
layer_spacing = 8.0
input_pdb = "BOC-ALA-RFP-ALA-BDP-OME.pdb"
output_pdb = "D1Cl1.pdb"

positions = [
    (0.0, 0.0, 0.0),                           # 1
    (col_spacing, 0.0, 0.0),                   # 2
    (0.0, row_spacing, 0.0),                   # 3
    (col_spacing, row_spacing, 0.0),           # 4
    (0.5 * col_spacing, 0.5 * row_spacing, layer_spacing),   # 5 (centered in 2nd layer)
    (0.0, 0.0, 2 * layer_spacing),             # 6
    (col_spacing, 0.0, 2 * layer_spacing),     # 7
    (0.0, row_spacing, 2 * layer_spacing),     # 8
    (col_spacing, row_spacing, 2 * layer_spacing),            # 9
    (0.5 * col_spacing, 0.5 * row_spacing, 3 * layer_spacing) # 10
]

with open("10_molecules.inp", "w") as f:
    f.write("tolerance 2.0\n")
    f.write("filetype pdb\n")
    f.write(f"output {output_pdb}\n\n")

    for pos in positions[:num_molecules]:
        x, y, z = pos
        f.write(f"structure {input_pdb}\n")
        f.write("  number 1\n")
        f.write(f"  fixed {x:.1f} {y:.1f} {z:.1f}   0.0 0.0 0.0\n")
        f.write("end structure\n\n")

print("Grid script generated: 10_molecules.inp")

