# Same goal as haupt.py, but with object oriented programming

import numpy as np

f_input = open("Input.txt")
f_output = open("Output.txt","w")
T = int(f_input.readline())

class Knoten:
    gruppe = 0
    def __init__(self,name):
        self.name = name
    def __eq__(self, other):
        return self.name == other.name
    def __str__(self):
        return("Knoten(" + self.name + ")")
class Kante:
    def __init__(self,K1,K2):
        self.knoten1 = K1
        self.knoten2 = K2
    def __eq__(self, other):
        return (self.knoten2 == other.knoten1 and self.knoten1 == other.knoten2) or (self.knoten1 == other.knoten1 and self.knoten2 == other.knoten2)
    def __str__(self):
        return "Kante(" + str(self.knoten1) + "," + str(self.knoten2) + ")"

class Graph:
    def __init__(self):
        self.kanten_Liste = []
        self.knoten_Liste = []
    def add_Kante(self, kante):
        if kante not in self.kanten_Liste:
            self.kanten_Liste.append(kante)
        if kante.knoten1 not in self.knoten_Liste:
            self.knoten_Liste.append(kante.knoten1)
        if kante.knoten2 not in self.knoten_Liste:
            self.knoten_Liste.append(kante.knoten2)
    def __str__(self):
        res = " ".join([str(k) for k in self.kanten_Liste])
        res = res + "\n"
        res = res + " ".join([str(k) for k in self.knoten_Liste])
        return res
    def verbunden(self, k1, k2):
        res = False
        if Kante(k1,k2) in self.kanten_Liste:
            res = True
        if Kante(k2,k1) in self.kanten_Liste:
            res = True
        return res
    def verbundene_Knoten_Liste(self, knoten):
        return [k for k in self.knoten_Liste if self.verbunden(k, knoten)]
    def gruppierbar(self):
        res = True
        gruppenlos_Liste = self.knoten_Liste
        while len(gruppenlos_Liste) > 0:
            gruppe = 1
            momentane_Knoten = [gruppenlos_Liste[0]]
            while len(momentane_Knoten) > 0:
                naechste_Knoten = []
                for q in momentane_Knoten:
                    if q.gruppe == 0:
                        q.gruppe = gruppe
                        naechste_Knoten.extend(self.verbundene_Knoten_Liste(q))
                    elif not q.gruppe == gruppe:
                        res = False
                    else:
                        pass
                momentane_Knoten = naechste_Knoten
                gruppe = (1 if gruppe == 2 else 2)
            gruppenlos_Liste = [k for k in self.knoten_Liste if k.gruppe == 0]
        return res

for t in range(T):
    print("-----------------")
    print("Test Case", str(t))
    n = int(f_input.readline())

    g = Graph()
    
    for i in range(n):
        paar = [str(name).rstrip('\n') for name in f_input.readline().split(" ")]
        knoten1 = Knoten(paar[0])
        knoten2 = Knoten(paar[1])
        kante = Kante(knoten1, knoten2)
        g.add_Kante(kante)
    print(g)
    if g.gruppierbar():
        print("Es gibt eine erlaubte Zuteilung.")
    else:
        print("Funzt nicht.")

f_input.close
f_output.close

