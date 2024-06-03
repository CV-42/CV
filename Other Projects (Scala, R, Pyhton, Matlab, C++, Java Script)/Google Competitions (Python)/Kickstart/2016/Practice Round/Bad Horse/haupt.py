import numpy as np

f_input = open("Input.txt")
f_output = open("Output.txt","w")
T = int(f_input.readline())

def Moeglichkeiten(Namen):
    if len(Namen) == 1:
        return [[1], [2]]
    else:
        rest = Moeglichkeiten(Namen[1:])
        ergebnis = []
        for r in rest:
            ergebnis.append([1] + r)
            ergebnis.append([2] + r)
    return ergebnis

def Erlaubt(Namen, Paare, Gruppierung):
    problem = False
    for paar in Paare:
        p1 = paar[0]
        p2 = paar[1]
        k1 = Namen.index(p1)
        k2 = Namen.index(p2)
        g1 = Gruppierung[k1]
        g2 = Gruppierung[k2]
        if g1 == g2:
            problem = True
    return not problem



for t in range(T):
    print("-----------------")
    print("Test Case", str(t))
    n = int(f_input.readline())
    Paare = []
    Namen = []
    for i in range(n):
        paar = [str(name).rstrip('\n') for name in f_input.readline().split(" ")]
        if not paar[0] in Namen:
            Namen.append(paar[0])
        if not paar[1] in Namen:
            Namen.append(paar[1])
        Paare.append(paar)
    print("Namen:")
    print(Namen)
    print("Paare:")
    print(Paare)
    print("Ergebnis:")
    erlaubte_Moeglichkeiten = []
    for m in Moeglichkeiten(Namen):
        if Erlaubt(Namen, Paare, m):
            erlaubte_Moeglichkeiten.append(m)
    if len(erlaubte_Moeglichkeiten) >= 1:
        print("Es gibt eine erlaubte Zuteilung.")
    else:
        print("Funzt nicht.")



    # f_output.write("case " + str(t) + ": " + str(output_line) + "\n")

f_input.close
f_output.close