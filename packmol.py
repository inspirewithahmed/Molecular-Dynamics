# Parameters
grid_size = 8           # 8x8 grid
col_spacing = 25.0      # spacing between molecules in a row (x-direction)
row_spacing = 15.0      # spacing between rows (y-direction), decreased
input_pdb = "D1Cl1_Conf-1.pdb"
output_pdb = "D1Cl1_8x8.pdb"

# Start writing the script
with open("8x8.inp", "w") as f:
    f.write("tolerance 2.0\n")
    f.write("filetype pdb\n")
    f.write(f"output {output_pdb}\n\n")

    for row in range(grid_size):
        for col in range(grid_size):
            x = col * col_spacing
            y = row * row_spacing  # use the smaller row spacing
            z = 0.0  # flat grid
            f.write(f"structure {input_pdb}\n")
            f.write("  number 1\n")
            f.write(f"  fixed {x:.1f} {y:.1f} {z:.1f}   0.0 0.0 0.0\n")
            f.write("end structure\n\n")

print("Grid script generated: 8x8.inp")

