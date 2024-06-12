import numpy as np
import matplotlib.pyplot as plt


def nachbarn(i, j, nx, ny):
    liste = []
    liste += [((i-1) % nx, (j) % ny)]
    liste += [((i+1) % nx, (j) % ny)]
    liste += [((i) % nx, (j-1) % ny)]
    liste += [((i) % nx, (j+1) % ny)]
    return liste
def H(s):
    nx, ny = s.shape
    summe = 0
    for i in range(1, nx-1):
        for j in range(1, ny-1):
            for iN, jN in nachbarn(i, j, nx, ny):
                summe += s[i,j]*s[iN,jN]
    return -summe

def hLokal(s, i, j):
    nx, ny = s.shape
    summe = 0
    for iN, jN in nachbarn(i, j, nx, ny):
        summe += s[i,j]*s[iN,jN]
    return - 2 * summe

def m(s):
    return sum(sum(s)) / np.prod(s.shape)

def zeige(s):
    nx, ny = s.shape
    X, Y = np.meshgrid(range(nx), range(ny))
    f = plt.figure()
    sp =  f.add_subplot(1,1,1)  
    plt.setp(sp.get_yticklabels(), visible=False)
    plt.setp(sp.get_xticklabels(), visible=False)      
    plt.pcolormesh(X, Y, s, cmap=plt.cm.RdBu)
    plt.show()

def einsVerdreht(s):
    nx, ny = s.shape
    i = np.random.randint(0, nx)
    j = np.random.randint(0, ny)
    sStrich = np.zeros([nx, ny])
    sStrich[:,:] = s
    sStrich[i,j] = -sStrich[i,j]
    return sStrich

def besser(sNeu, sAlt):
    hNeu = H(sNeu)
    hAlt = H(sAlt)
    if (hNeu < hAlt):
        return True
    else:
        return False

def DeltaE(sNeu, sAlt):
    return(H(sNeu) - H(sAlt))

def DeltaH(sAlt, i, j):
    # Energiedifferenz, falls nur Stelle (i,j) verdreht wird
    lokAlt = hLokal(sAlt, i, j)
    # sNeu = np.copy(sAlt)
    # sNeu[i,j] = - sNeu[i,j]
    # lokNeu = hLokal(sNeu, i, j)
    lokNeu = - lokAlt
    return lokNeu - lokAlt
def drehe(sAlt, i, j):
    sNeu = np.copy(sAlt)
    sNeu[i,j] = - sNeu[i,j]
    return sNeu

def akzeptiert(deltaE, T):
    if deltaE < 0:
        return True
    else:
        if np.random.uniform(size=1) < np.exp(- (deltaE / T)):
            return True
        else:
            return False

def verbessere (s0, TFunktion,  maxSchritte = 100):
    schritt = 0
    nx, ny = s0.shape
    eVek = []
    sAlt = s0
    HAlt = H(sAlt)
    while schritt < maxSchritte:
        # print("------------------")
        # print("Schritt ",schritt)
        # print("T = ",TFunktion(schritt))
        # sNeu = einsVerdreht(sAlt)
        # HNeu = H(sNeu)
        # print(sNeu==sAlt)
        # dE = HNeu - HAlt     # Hier Einsparpotential... HAlt HNeu!!!
        # print("dE = ", dE)
        i = np.random.randint(0, nx)
        j = np.random.randint(0, ny)
        dE = DeltaH(sAlt, i, j)
        # print("dE = ",dE)
        # print("sNeu = ",sNeu)
        if dE < 0:
            # print("Treu")
            sAlt = drehe(sAlt, i, j)
            HAlt += dE
        elif akzeptiert(dE,TFunktion(i)):
            # print("True")
            sAlt = drehe(sAlt, i, j)
            HAlt += dE
        schritt += 1
        eVek += [HAlt]
    return sAlt, eVek

def TFunktion1(i):
    return np.exp(- i / 100)

def testreihe(s0, temperaturen = 8 * np.linspace(0.1,0.9,10), schritte = 40):
    sFertigListe = []
    eFertigListe = []
    for t in temperaturen:
        print("Testreihe Temperatur ",t)
        s, e = verbessere(s0, lambda x: t, schritte)
        sFertigListe += [s]
        eFertigListe += [e[-1]]
        print(" eFertig = ", e[-1])
    return sFertigListe, eFertigListe




nx = 100
ny = 100
s0 = np.random.randint(0, 2, [nx, ny]) * 2 -1
zeige(s0)

nSchritte = 1000000
sFertig, eVek = verbessere(s0, lambda x: 1, 30000)
zeige(sFertig)

# temperaturen = np.linspace(1,20,40)
# sFertigListe, eFertigListe = testreihe(s0, temperaturen, schritte = 500000)
# print("eFertigListe = ", eFertigListe)
# hilf = np.array(eFertigListe)
# zeige(sFertigListe[np.argmin(hilf)])
# zeige(sFertigListe[np.argmax(hilf)])
# plt.plot(temperaturen, eFertigListe)
# plt.show()
