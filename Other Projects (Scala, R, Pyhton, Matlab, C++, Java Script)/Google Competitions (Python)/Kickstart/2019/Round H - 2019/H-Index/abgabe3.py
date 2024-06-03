import numpy as np

T = int(input())

for t in range(1,T+1):
    # Für jeden der T Test-cases

    # Anzahl der Veröffentlichungen:
    n = int(input())

    # Für jede Veröffentlichung die Zitierzahl:
    A = [int(s) for s in input().split(" ")]

    # Hier kommt später die Lösung rein:
    lsg = []

    # Ohne Paper: H-Wert=0
    H_Wert = 0

    # Anzahl noch potentiell einschlägiger Blätter:
    ueber = 0

    # Zaehler:
    zlr = np.zeros(n+1)

    # Eigentlicher Algorithmus
    for i in range(n):
        if (A[i] >= H_Wert +1):
            if A[i] > n:
                zlr[n] += 1
            else:
                zlr[A[i]-1] += 1
            if A[i]> H_Wert + 1:
                ueber += 1
            if zlr[H_Wert] + ueber >= H_Wert + 1:
                H_Wert += 1
                ueber -= zlr[H_Wert]
        lsg.append(H_Wert)
        
    
    # Ausgabe:
    lsg = [str(i) for i in lsg]
    lsg = " ".join(lsg)
    print("Case #" + str(t) + ": " + lsg)