import numpy as np 

T = int(input())

for t in range(T):
    N, K = [int(s) for s in input().split(" ")]
    S = input()
    SS = S[::-1]
    k = 0
    for i in range(N//2):
        if SS[i] == S[i]:
            k += 1
    antwort = str(abs(K-k))

    print("Case #" + str(t + 1) + ": " + antwort)