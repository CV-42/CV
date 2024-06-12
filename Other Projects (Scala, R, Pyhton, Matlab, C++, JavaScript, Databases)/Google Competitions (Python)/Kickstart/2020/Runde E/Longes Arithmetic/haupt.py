import numpy as np

T = int(input())

for t in range(T):
    n = int(input())
    A = [int(s) for s in input().split(" ")]
    A = np.array(A)
    D = A[1:len(A)] - A[0:(len(A)-1)]
    DD = D[1:len(D)] - D[0:(len(D)-1)]
    k = [2]
    for i in range(len(DD)):
        if DD[i] == 0:
            k[-1] += 1
        else:
            k.append(2)
    
    print("Case #" + str(t + 1) + ":" + str(max(k)))