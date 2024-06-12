import numpy as np

def kantenPunkte(objekt):
    [lux, luy, rox, roy] = objekt
    anzX = rox - lux + 1
    anzY = roy - luy + 1
    # # anz = (rox - lux + 1) * 2 + (roy - luy + 1) * 2 - 4
    # resU = np.zeros([anzX,2], dtype=int)
    # resO = np.zeros([anzX,2], dtype=int)
    # resR = np.zeros([anzY-2,2], dtype=int)
    # resL = np.zeros([anzY-2,2], dtype=int)
    # for i in range(anzX):
    #     resU[i,:] = [lux + i, luy]
    #     resO[i,:] = [rox - anzX + 1 + i, roy]
    # for i in range(anzY - 2):
    #     resL[i,:] = [lux, luy + 1 + i]
    #     resR[i,:] = [rox, roy - anzY + 2 + i]
    # return np.concatenate((resU,resO,resL,resR), axis = 0)
    res = np.zeros([anzX * anzY, 2], dtype=int)
    for i in range(anzX):
        for j in range(anzY):
            res[i + anzX * j, : ] = [lux + i, luy + j]
    return res


def dist(koord, objekt):
    x = koord[0]
    y = koord[1]
    if x < objekt[0]:
        dx = objekt[0] - x
    elif x > objekt[2]:
        dx = x - objekt[2]
    else:
        dx = 0
    
    if y < objekt[1]:
        dy = objekt[1] - y
    elif y > objekt[3]:
        dy = y - objekt[3]
    else:
        dy = 0

    return dx + dy

def distGes(koord, objekte, maxi):
    anzObj = objekte.shape[0]
    res = 0
    for o in range(anzObj):
        res += dist(koord, objekte[o])
        if res > maxi:
            break
    return res

T = int(input())

for t in range(T):
    K = int(input())
    Os = np.zeros([K,4], dtype=int)
    for i in range(K):
        Os[i,:] = [int(z) for z in input().split(" ")]
    # print(Os)
    
    lu = [np.min(Os[:,0]), np.min(Os[:,1])]
    ro = [np.max(Os[:,2]), np.max(Os[:,3])]

    # print(lu)
    # print(ro)
    besterWert = distGes(lu, Os, K*ro[0]*ro[1]+1)
    besteX = lu[0]
    besteY = lu[1]
    for k in range(K):
        punkte = kantenPunkte(Os[k])
        # print("-------Punkte: ")
        # print(punkte)
        for [x,y] in punkte:
            wert = distGes([x,y], Os, besterWert)
            # print("x,y,Wert,besterWert:  " + str(x) + ", " + str(y) + ", " + str(wert) + ", " + str(besterWert))
            # print("  besteX, besteY: " + str(besteX) + ", " + str(besteY))
            if wert < besterWert:
                besterWert = wert
                besteX = x
                besteY = y
            if (wert == besterWert) and (x < besteX):
                besteX = x
            if (wert == besterWert) and (x == besteX) and (y < besteY):
                besteY = y

    print("Case #" + str(t+1) + ": " + str(besteX) + " " + str(besteY))