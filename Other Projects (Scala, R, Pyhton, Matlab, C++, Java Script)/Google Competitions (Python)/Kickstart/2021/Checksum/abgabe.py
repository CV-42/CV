import numpy as np

def fAnzBesetztInReihe(Besetzt):
    return np.sum(Besetzt, axis = 1)

def fAnzBesetztInSpalte(Besetzt):
    return np.sum(Besetzt, axis = 0)

def fuelleReihen(B, iListe):
    for i in iListe:
        B[i,:] = 0
    return B
def fuelleSpalten(B, jListe):
    for j in jListe:
        B[:,j] = 0
    return B

def vereinfache(B):
    N = B.shape[0]
    verbesserbar = True
    while verbesserbar:
        Besetzt = B == 0
        AnzBesetztInReihe = fAnzBesetztInReihe(Besetzt)
        AnzBesetztInSpalte = fAnzBesetztInSpalte(Besetzt)
        iListe = np.where(AnzBesetztInReihe == N-1)[0]
        jListe = np.where(AnzBesetztInSpalte == N-1)[0]
        if len(iListe) > 0 or len(jListe) > 0:
            B = fuelleReihen(B, iListe)
            B = fuelleSpalten(B, jListe)
        else:
            verbesserbar = False
    return B

def fertig(B):
    return sum(sum(B)) == 0

def wertung(B, schonBenoetigteZeit = 0, momentanerBestwert = -1):
    B = vereinfache(B)
    if fertig(B):
        return schonBenoetigteZeit
    else:
        iListe, jListe = np.where(B != 0)
        werteListe = B[iListe, jListe]
        reihenfolge = np.argsort(werteListe)
        zeitListe = []
        for n in range(len(iListe)):
            i = iListe[reihenfolge[n]]
            j = jListe[reihenfolge[n]]
            zusaetzlicheZeit = B[i, j]
            neueBenoetigteZeit = zusaetzlicheZeit + schonBenoetigteZeit
            if (momentanerBestwert == -1) or (neueBenoetigteZeit < momentanerBestwert):
                Bn = B.copy()
                Bn[i, j] = 0
                w = wertung(Bn, neueBenoetigteZeit,  momentanerBestwert)
                zeitListe.append(w)
                if (momentanerBestwert == -1) or (w < momentanerBestwert):
                    momentanerBestwert = w
            else:
                zeitListe.append(momentanerBestwert)
        return int(min(zeitListe))
        
            
        



T = int(input())

for t in range(T):
    N = int(input())
    A = np.zeros([N,N])
    for i in range(N):
        A[i,:] = [int(s) for s in input().split(" ")]
    B = np.zeros([N,N])
    for i in range(N):
        B[i,:] = [int(s) for s in input().split(" ")]
    R = [int(s) for s in input().split(" ")]
    C = [int(s) for s in input().split(" ")]

    y = wertung(B)

    print("Case #" + str(t + 1) + ": " + str(y))