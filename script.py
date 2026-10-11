copies = 10
res3 = [3 + 4*i for i in range(copies)]
res5 = [5 + 4*i for i in range(copies)]

with open("pi_pi_10copies.in", "w") as f:

    f.write("parm your_system.prmtop\n")
    f.write("trajin your_trajectory.nc\n\n")

    counter = 1

    for i in range(copies):
        for j in range(i+1, copies):

            rings_i = [
                f":{res3[i]}@CD21,CE22,CG22,CD22,CG21,CE21",
                f":{res3[i]}@CD11,CE11,CG11,CD12,CG12,CE12",
                f":{res5[i]}@CG2,CD2,CE1,CZ,CE2,CD3",
                f":{res5[i]}@CB,CG,CD,CE,CD1,CG1"
            ]

            rings_j = [
                f":{res3[j]}@CD21,CE22,CG22,CD22,CG21,CE21",
                f":{res3[j]}@CD11,CE11,CG11,CD12,CG12,CE12",
                f":{res5[j]}@CG2,CD2,CE1,CZ,CE2,CD3",
                f":{res5[j]}@CB,CG,CD,CE,CD1,CG1"
            ]

            for ri in rings_i:
                for rj in rings_j:
                    f.write(f"distance aryl_{counter:05d} {ri} {rj} out Aryl_distance.dat\n")
                    counter += 1

    f.write("\nrun\n")

print("Generated pi_pi_10copies.in")

