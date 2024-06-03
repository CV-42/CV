import numpy as np 

T = int(input())

for t in range(T):
    N = int(input())
    D = [int(s) for s in input().split(" ")]
    l = 0
    r = N-1
    anz = 0
    aktuell  = 0

    while (l <= r):
        weg = 0
        if D[l] <= D[r]:
            weg = D[l]
            l = l+1
        else:
            weg = D[r]
            r = r - 1
        if weg >= aktuell:
            aktuell = weg
            anz += 1

    print("Case #" + str(t + 1) + ": " + str(anz))