Ein.Schritt<- function(Vorgabe,
                       Dudl.Matrix.schwarz.weiss, # Wann hat wer (sicher oder vielleicht) Zeit
                       Dudl.Matrix.Fragezeichen,  # Wann hat wer nur vielleicht Zeit
                       Wochentages.Vektor,        # Vielleicht mal in späterer Version für Extrawünsche verwendtbar
                       Bearbeitungsreihenfolge,   # für Rekursionsreihenfolge
                       ist.Neuling.Vektor,        # Neulinge sollten nicht zusammen den ersten Dienst haben
                       min.Anzahl.Dienste.Vektor, # enthält Wünsche der NLer
                       max.Anzahl.Dienste.Vektor, # enthält Wünsche der NLer
                       momentaner.Bestwert = Inf, # Um Rekursion abbrechen zu können, wenn klar wird, dass der momentane Planentwurf schlechter ist, als der, der schonmal vorher gefunden wurde.
                       n.Tage.bereits.belegt,
                       max.Verzweigungsbreite.bei.der.Rekursion){
  # Ist eine rekursive Funktion, die einen Dienstplan berechnen kann
  # Gibt, wenn es was Richtiges am Ende der Rekursion gefunden hat,
  # als return die gefundene Lösung und deren Wertigkeit zurück.
  # Wenn sich der Pfad als Murks rausstellt, gibt er nur NA zurück.
  
  n.Tage <- dim(Vorgabe)[2]
  
  # entsprechend der Bearbeitungsreihenfolge den aktuell zu
  # bearbeitenden Tag raussuchen
  aktuell.zu.bearbeitender.Tag <- Bearbeitungsreihenfolge[n.Tage.bereits.belegt+1]
  
  # Möglichkeiten für Belegung des nächsten Tages suchen
  # (Ist eine Liste von Matrizen mit (i.A.) viel FALSE und ein paar TRUEs.)
  Liste.naechste.Moeglichkeiten <- f.naechste.Moeglichkeiten(Vorgabe = Vorgabe,
                                                             Dudl.Matrix.schwarz.weiss = Dudl.Matrix.schwarz.weiss, 
                                                             max.Anzahl.Dienste.Vektor = max.Anzahl.Dienste.Vektor,
                                                             aktuell.zu.bearbeitender.Tag = aktuell.zu.bearbeitender.Tag)
  
  # Die unterschiedlichen gefundenen Möglichkeiten bewerten
  Vektor.Werte.der.naechsten.Moeglichkeiten <- sapply(Liste.naechste.Moeglichkeiten,
                                                      f.Wert,   # Dies ist die Bewertungsfunktion, welche irgendwo in einer anderen Datei liegt.
                                                      Dudl.Matrix.Fragezeichen = Dudl.Matrix.Fragezeichen, # Dieser und die folgenden Werte werden an "f.Wert" als zusätzliche Argumente übergeben... so funzt die Syntax von lapply.
                                                      Bearbeitungsreihenfolge = Bearbeitungsreihenfolge,
                                                      n.Tage.bereits.belegt = n.Tage.bereits.belegt+1, 
                                                      Wochentages.Vektor = Wochentages.Vektor, 
                                                      max.Anzahl.Dienste.Vektor = max.Anzahl.Dienste.Vektor,
                                                      ist.Neuling.Vektor = ist.Neuling.Vektor)
  
  # Gucken, ob unter den Möglichkeiten noch was potentiell Besseres ist
  gute.Moeglichkeiten <- Vektor.Werte.der.naechsten.Moeglichkeiten < momentaner.Bestwert
  n.gute <- sum(gute.Moeglichkeiten)
  
  # Abbrechen, falls nichts besser werden kann
  if (n.gute == 0) return(NA)
  
  #  Unter den guten Möglichkeiten maximal max.Verzweigungsbreite.bei.der.Rekursion behalten
  # (kann auskommentiert werden)
    i.erste.Gute <- which(gute.Moeglichkeiten)[1:min(c(max.Verzweigungsbreite.bei.der.Rekursion,n.gute))]
    gute.Moeglichkeiten <- gute.Moeglichkeiten&FALSE
    gute.Moeglichkeiten[i.erste.Gute] <- TRUE
  
  # Liste auf gute Möglichkeiten einkürzen (also alle guten behalten)
    Liste.naechste.Moeglichkeiten <- Liste.naechste.Moeglichkeiten[gute.Moeglichkeiten]
    Vektor.Werte.der.naechsten.Moeglichkeiten <- Vektor.Werte.der.naechsten.Moeglichkeiten[gute.Moeglichkeiten]
  
  # Falls Ende der Rekursionstiefe erreicht
  if (n.Tage == n.Tage.bereits.belegt+1){
    i.bestes <- which(Vektor.Werte.der.naechsten.Moeglichkeiten==min(Vektor.Werte.der.naechsten.Moeglichkeiten))[1]
    return(list(Liste.naechste.Moeglichkeiten[[i.bestes]],Vektor.Werte.der.naechsten.Moeglichkeiten[i.bestes]))
  }
  
  #Rekursion tiefer gehen
  was.besseres.gefunden <- FALSE
  for (i in Liste.naechste.Moeglichkeiten){
    Hilf <- Ein.Schritt(Vorgabe = i,
                        Dudl.Matrix.schwarz.weiss =  Dudl.Matrix.schwarz.weiss, 
                        Dudl.Matrix.Fragezeichen =  Dudl.Matrix.Fragezeichen, 
                        Wochentages.Vektor = Wochentages.Vektor, 
                        ist.Neuling.Vektor = ist.Neuling.Vektor,
                        Bearbeitungsreihenfolge = Bearbeitungsreihenfolge, 
                        min.Anzahl.Dienste.Vektor = min.Anzahl.Dienste.Vektor,
                        max.Anzahl.Dienste.Vektor = max.Anzahl.Dienste.Vektor,
                        momentaner.Bestwert = momentaner.Bestwert, 
                        n.Tage.bereits.belegt = n.Tage.bereits.belegt + 1,
                        max.Verzweigungsbreite.bei.der.Rekursion = max.Verzweigungsbreite.bei.der.Rekursion)
    # Wenn in dieser Richtung nichts besseres rauskommt, ist das Ergebnis NA
    # falls aber was Besseres rauskommt, wird im Folgenden der momentane Besterwert
    # mit zugehörigem Plan aktualisiert
    if (!(is.na(Hilf))){
      momentaner.Bestwert <- Hilf[[2]]
      momentan.beste.Aufstellung <- Hilf[[1]]
      was.besseres.gefunden <- TRUE
    }
  }
  #Falls am Ende auch nichts besseres gefunden wurde, wieder NA zurückgeben
  if (!was.besseres.gefunden) return(NA)
  # Falls aber was besseres gefunden wurde, das dann auch zurückgeben:
  return(list(momentan.beste.Aufstellung,momentaner.Bestwert))
}