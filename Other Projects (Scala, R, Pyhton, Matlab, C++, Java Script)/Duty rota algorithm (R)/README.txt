Das Meiste dieses Programmes habe ich, ***** (Repobesitzer, anonymisiert), für den Verein geschrieben, und ***** (Kumpel) hat noch die Datei-Eingabe und -Ausgabe hinzugefügt, und evntl. noch kleine Sachen verändert.

Dieses Programm errechnet aus einer Dudltabelle einen möglichen Dienstplan.
Es wird versucht anhand von Bewertungen einen möglichst guten Dienstplan zu finden.
Gut heißt z.B. dass kein Dienst ausfällt, und die Leute wirklich nur die Dienste machen, die sie auch wollten.
Der Algorithmus funktioniert "rekursiv und schlau". Das heißt im Groben: Es wird ein Tag gewählt, wo möglichst wenige Leute Zeit haben. Da werden "max.Verzweigungsbreite.bei.der.Rekursion" viele Möglichkeiten ausprobiert, und der restliche (unfertige) Dienstplan für alle diese Möglichkeiten wieder zurück in die Rekursion gegeben. Wenn erkennbar ist, dass ein Verlauf am Ende nichts ordentliches mehr hervorbringen kann, wird dieser Verzweigungsweg abgebrochen. Sonst wären die Laufzeiten zu groß.

Das Hauptprogramm heißt "Haupt.R". In diesem kann man (relativ weit oben) festlegen, wie die Datei heißt, in welcher die Dudltabelle gespeichert ist. Die Dudltabelle sollte eine CSV-Datei sein und ein bestimmtes Format aufweisen. In "participanttable.csv" ist ein Beispiel für die Formatierung zu finden. (Diese CSV-Datei wurde mit dem Fierefox-Addon "TableToCSV"(?) runtergeladen und dann mit libre office calc etwas bereinigt.)

In der CSV-Datei gibt es drei zusätzliche Spalten. Zweie geben  Wünsche der Vereinsmitglieder wieder: Maximale und (eine momentan noch nicht im Programm beachtete) minimale gewünschte Anzahl von Diensten. Und eine Spalte enthält "ja", wenn die entsprechende Person ein Neuling ist.  (Neulinge dürfen nicht zusammen Dienst machen.)

Im Hauptprogramm "Haupt.R" kann (relativ weit oben) auch festgelegt werden, wie viele neue Äste bei der Rekursion (, die den Dienstplan berechnet) aufgemacht werden sollen. Mit 
	max.Verzweigungsbreite.bei.der.Rekursion <- 2
kommt im Beispiel schon was ganz vernünftiges raus. Mit
	max.Verzweigungsbreite.bei.der.Rekursion <- 3
dauert es schon einige Minuten, bringt aber auch nichts besseres zustande.
Mit
	max.Verzweigungsbreite.bei.der.Rekursion <- 4
habe ich es nicht zuende laufen lassen (nach 5min abgebrochen.)
	

Die Ausgabe erfolgt am Ende in einer CSV-Datei mit Datumsangabe.

! Um die Ausgabe in die Datei zu erhalten, muss die nötige Berechtigung für das Verzeichnis / den Ordner da sein. 

Bewertungen, um die Güte "r" eines Dienstplanes zu berechnen: (aus "Plan_bewerten.R" rauskopiert):
  r <- 0
  r <- r + Anz.genutzter.Fragezeichen * 1
  r <- r + Anz.bisher.freigelassener.Tage * 10
  r <- r + Anz.Personen.mehr.als.gewuenscht * 100
  r <- r + Anz.Tage.wo.zwei.Neulinge.zusammen.Dienst *1000