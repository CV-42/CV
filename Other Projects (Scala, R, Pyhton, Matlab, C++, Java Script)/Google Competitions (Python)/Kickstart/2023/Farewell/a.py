import numpy as np 

T = int(input())

for t in range(T):
    N = int(input())
    A = [int(s) for s in input().split(" ")]
    A = np.asarray(A)
    La, Ra, Lb, Rb = [int(s)-1 for s in input().split(" ")]

    LSum = A.cumsum(0)
    RSum = np.flip(A,0)
    RSum = RSum.cumsum(0)
    RSum = np.flip(RSum)

    spanneA = range(La,Ra+1)
    spanneB = range(Lb,Rb+1)
    maksA = 0
    for i in spanneA:
        j = -1
        if i in spanneB:
            if  ((i-1) in spanneB) and ((i+1) in spanneB):
                if LSum[i-1] > RSum[i+1]:
                    j = i-1
                else:
                    j = i+1
            elif ((i-1) in spanneB) and ((i+1) not in spanneB):
                j = i-1
            elif ((i-1) not in spanneB) and ((i+1) in spanneB):
                j = i+1


            # Falls B nichts wählen konnte:
            if j == -1:
                maksA = np.sum(A)
            #Falls B doch wählen konnte:
            else:
                if j < i:
                    maksA = max(maksA, RSum[i])
                if j > i:
                    maksA = max(maksA, LSum[i])

        # Falls i nicht in spanneB:
        else:
            if Ra < Lb:
                maksA = max([maksA, LSum[int(Ra + np.ceil((Lb-Ra-1)/2))]])
            if Rb < La:
                maksA = max([maksA, RSum[int(La - np.ceil((La-Rb-1)/2))]])
    
    antwort = str(maksA)
    print("Case #" + str(t + 1) + ": " + antwort)