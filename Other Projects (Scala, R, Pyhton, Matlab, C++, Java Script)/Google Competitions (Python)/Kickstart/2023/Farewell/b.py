import numpy as np 
import math

T = int(input())

for t in range(T):
    W, N, D = [int(s) for s in input().split(" ")]
    X = [int(s)-1 for s in input().split(" ")]
    X = np.asarray(X)

    mgl = True
    anz = 0
    ggT = math.gcd(N,D)
    alle = np.arange(0, D, ggT)
    schrittrum = int(np.ceil(N / D))
    genullt = math.lcm(N,D) // D
    for i in range(W // 2):
        klein = min((X[W-1-i] , X[i]))
        gross = max((X[W-1-i] , X[i]))
        schrittran = (gross-klein) // D
        nah = klein + schrittran * D
        if not nah in alle:
            mgl = False
            break
        else:
            sorum = schrittran + schrittrum * ((gross - nah) // ggT)
        
        anz += min(sorum, genullt -sorum)

    if mgl:
        antwort = str(anz)
    else:
        antwort = "IMPOSSIBLE"
    print("Case #" + str(t + 1) + ": " + antwort)