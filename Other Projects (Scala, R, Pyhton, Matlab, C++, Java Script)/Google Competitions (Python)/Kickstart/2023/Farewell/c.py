import numpy as np 

T = int(input())

for t in range(T):
    N, K = [int(s) for s in input().split(" ")]
    A = [int(s) for s in input().split(" ")]
    A = np.asarray(A)
    order = A.argsort()
    ranks = order.argsort()
    Sort = A[order]
    
    lsg = np.zeros(N)
    for i in range(N):
        j = ranks[i]
        yi = 1
        r = j + 1
        letzte = A[i] # = Sort[j]
        while r < N:
            if Sort[r] >= letzte + K:
                letzte = Sort[r]
                yi += 1
            r += 1
        letzte = A[i]
        l = j-1
        while l >= 0:
            if Sort[l] <= letzte - K:
                letzte = Sort[l]
                yi += 1
            l -= 1
        lsg[i] = yi

    antwort = " ".join(' '.join(str(int(x)) for x in lsg))
    print("Case #" + str(t + 1) + ": " + antwort)