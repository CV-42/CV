import numpy as np
from rekursive_Hilfsfunktion import *


f_input = open("input.txt")
f_output = open("output.txt","w")
T = int(f_input.readline())

for t in range(T):
    A = [int(i) for i in f_input.readline().split(" ")]
    print(A)
    output_line = test(A, 0, int(np.ceil(sum(A) / 2)))
    print(output_line)
    f_output.write("case " + str(t) + ": " + str(output_line) + "\n")
f_input.close
f_output.close