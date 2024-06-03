# Dieses Programm erstellt Dienstpläne aus Dudllisten

# Die Dudlliste muss mit diesem Firefox-Addon ("Table to CSV"??) in
# eine CSV-Datei gespeichert werden und etwas vorbearbeitet werden.
# Siehe dazu die (noch zu schreibende) programmexterne Anleitung.

# In alter Version wurde alles über eine Textdatei (keine CSV) gemacht.
# Die Dudlliste musste in eine Textdatei kopiert werden und etwas vorbearbeitet werden.
# Siehe dazu die (noch zu schreibende) programmexterne Anleitung.

# Autor: ******* (anonymisiert - Repobesitzer)
# Mail : ******* (anonymisiert - Repobesitzer)
# Könnt mich gerne Fragen zum Programm stellen.

# Version 2019, Oktober

###################################################################
##################### Noch zu tun: ################################
################################################################
# zustäzliche Funktion, die nur fertige Pläne berechnet, um min.Anz.Dienste.Vektor einbeziehen zu können
# Verzweigungsbreite der Rekursionen von außen festlegbar machen
# Fortschrittsanzeige
# Testen, ob alles gut implementiert (Funktioniert die Sortierung noch?)
# Kompilierte Datei herstellen ??
# Überprüfen, ob Mehrfachüberbelegungen (d.h. eine Person hat gleich mehrere Dienste zu viel) auch extra schlimm angerechnet wird.
# Bewertungen von außen abänderbar machen.

########################################################################################
############### Vorher vom Benutzer festzulegen!!!
########################################################################################
Ordnerpfad <- "****" # Ausfüllen!
Name.der.Dudldatei <- "participanttable.csv"

# Rechnung kann mit Inf sehr lange dauern. Mit 1 kann aber womöglich kein guter
# Plan gefunden werden.
max.Verzweigungsbreite.bei.der.Rekursion <- 20


########################################################################################
########### Arbeitspfad festlegen und benötigte Dateien einbinden
########################################################################################
setwd(Ordnerpfad)

# Enthält die Funktionen, die Dudldatei einzulesen und Matrizen draus zu machen:
source("CSV_Einlesen.R") # für Textdateien früher mal: source("Einlesen.R")

# Enthält die Funktionen, welche für einen teilweise Ausgefüllten Dienstplan berechnen,
# welche Belegungsmöglichkeiten es für den nächsten zu bearbeitenden Tag gibt:
source("Moeglichkeiten_pruefen.R")

# Enthält die Funktionen, die (auch nichtfertige) Pläne angesichts von Fragezeichenausnutzungt
# und ähnlichen Kriterien bewerten:
source("Plan_bewerten.R")

# Enthält die rekursive Funktion, welche einen Dienstplan erstellt, indem sie mit dem ersten Tag
# anfängt und dann in der Rekursion immer einen Tag mehr dazu nimmt:
source("Rekursive_Funktion.R")

# Um schneller zum optimalen Plan zu kommen, ist eine Vorsortierung sinnvoll. Es werden dann in der 
# Rekursion die Tage mit den wenigsten Freiwilligen zuerst behandelt:
source("Sortierung.R")

# Enthält zusammenfassende Funktionen, die dann hier im Hauptprogramm aufgerufen werden:
source("Hauptfunktionen.R")

########################################################################################
######################## Sachen aus der Textdatei einlesen
########################################################################################

# Aus Datei das Dudl einlesen
Einlese.Liste <- Einlesen.Csv(Name.der.Dudldatei)

# Hier steht drin (mit TRUE/FALSE), an welchem Tag wer Zeit hat 
# (Fragezeichen werden hier als "hat Zeit" gewertet):
Dudl.Matrix.schwarz.weiss <- Einlese.Liste[["Dudl.Matrix.schwarz.weiss"]] # Müssen doppelte Klammern nehmen, um als ergebnis nicht 'ne Liste der Länge 1, sondern nur das Element, zu erhalten.

# Hier stehen nur die Fragezeichen nochmal drin (TRUE/FALSE)
# (braucht man für die Bewertung möglicher Dienstpläne mittels f.Wert):
Dudl.Matrix.Fragezeichen <- Einlese.Liste[["Dudl.Matrix.Fragezeichen"]]

# Hier steht drin, welche Wochentage die einzelnen Tage sind
# (braucht man in einer möglichen neueren Version für die Bewertung möglicher Dienspläne mittels f.Wert):
Wochentages.Vektor <- Einlese.Liste[["Wochentages.Vektor"]]

# Hier stehen die maximal/minnimal gewünschten Anzahlen der Dienste drin:
min.Anzahl.Dienste.Vektor <- Einlese.Liste[["min.Anzahl.Dienste.Vektor"]]
max.Anzahl.Dienste.Vektor <- Einlese.Liste[["max.Anzahl.Dienste.Vektor"]]

# Hier steht drin, wer ein Neulinge*innen sind. (Und deshalb nicht zusammen
# Dienst haben sollten.)
ist.Neuling.Vektor <- Einlese.Liste[["ist.Neuling.Vektor"]]

# Namen der NLer
Namens.Vektor <- Einlese.Liste[["Namens.Vektor"]]

########################################################################################
################## Reihenfolge der Abhandlung der Tage festlegen
################## (damit der Algotithmus schneller läuft)
########################################################################################
Bearbeitungsreihenfolge <- f.Sortieren(Dudl.Matrix.schwarz.weiss)

########################################################################################
# Zum Testen der Laufzeiten können folgende Zeilen entkommentiert werden
# ! Momentan nicht funktionstüchtig!!! 
########################################################################################
  #f.Zeitenreihen.testen(Dudl.Matrix.schwarz.weiss,Dudl.Matrix.Fragezeichen)
  #f.Sortierung.Testen(Dudl.Matrix.schwarz.weiss,Dudl.Matrix.Fragezeichen,5)

########################################################################################
###################### Besten Plan berechnen. (Und dabei Rechenzeit messen.)
########################################################################################
system.time(
  Hilf <- 
  f.Plan.berechnen.aus.Matrizen(
    Dudl.Matrix.schwarz.weiss = Dudl.Matrix.schwarz.weiss,
    Dudl.Matrix.Fragezeichen = Dudl.Matrix.Fragezeichen,
    Wochentages.Vektor = Wochentages.Vektor,
    Bearbeitungsreihenfolge = Bearbeitungsreihenfolge,
    ist.Neuling.Vektor = ist.Neuling.Vektor,
    min.Anzahl.Dienste.Vektor = min.Anzahl.Dienste.Vektor,
    max.Anzahl.Dienste.Vektor = max.Anzahl.Dienste.Vektor,
    max.Verzweigungsbreite.bei.der.Rekursion = max.Verzweigungsbreite.bei.der.Rekursion)
)
Plan <- Hilf[[1]]
Wertung <- Hilf[[2]]

# Namensbeschriftung vom Plan nachträglich (nicht schön!) noch ranklatschen
rownames(Plan) <- Namens.Vektor

########################################################################################
############################ Ausgabe der Ergebnisse
########################################################################################
print("Der Plan ist:")
print(Plan)
print("Der Plan hat die Wertung:")
print(Wertung)

# Ausgabe in Datei
Name.der.Ausgabedatei <- paste("Diensplan, erstellt am_um ",format(Sys.time(), "%a %b %d %X %Y"),".csv")
print(Name.der.Ausgabedatei)
Schoenere.Ausgabetabelle <- Plan
Schoenere.Ausgabetabelle[Schoenere.Ausgabetabelle==FALSE] <- ""
write.csv(Schoenere.Ausgabetabelle, file = Name.der.Ausgabedatei)