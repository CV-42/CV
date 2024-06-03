f.Plan.berechnen.aus.Matrizen <- function(Dudl.Matrix.schwarz.weiss,
                                          Dudl.Matrix.Fragezeichen,
                                          Wochentages.Vektor,
                                          Bearbeitungsreihenfolge,
                                          ist.Neuling.Vektor,
                                          min.Anzahl.Dienste.Vektor,
                                          max.Anzahl.Dienste.Vektor,
                                          max.Verzweigungsbreite.bei.der.Rekursion){
  # Berechnet aus den Dudl.Matrizen und so einen günstigsten Plan und dessen Wertung.
  
  # Bis jetzt noch keine Belegungen festgelegt
  Vorgabe <- Dudl.Matrix.schwarz.weiss & FALSE
  # Bemerkung: Obige Zeile nimmt die Form der Matrix Dudl.Matrix.schwarz.weiss,
  # setzt aber alle Felder auf FALSE.
  
  # Rekursive Berechnung aufrufen
  Hilf <- Ein.Schritt(Vorgabe = Vorgabe,
                      Dudl.Matrix.schwarz.weiss =  Dudl.Matrix.schwarz.weiss,
                      Dudl.Matrix.Fragezeichen =  Dudl.Matrix.Fragezeichen,
                      Wochentages.Vektor =  Wochentages.Vektor,
                      Bearbeitungsreihenfolge =  Bearbeitungsreihenfolge,
                      ist.Neuling.Vektor =  ist.Neuling.Vektor,
                      min.Anzahl.Dienste.Vektor =  min.Anzahl.Dienste.Vektor,
                      max.Anzahl.Dienste.Vektor =  max.Anzahl.Dienste.Vektor,
                      momentaner.Bestwert = Inf,
                      n.Tage.bereits.belegt = 0,
                      max.Verzweigungsbreite.bei.der.Rekursion = max.Verzweigungsbreite.bei.der.Rekursion)
  # Ausgabe Liste mit erstelltem Plan und dessen Wertung
  return(Hilf)
}


### Folgende Zeilen waren mal zum Testen von Laufzeiten gedacht. 
### (Damals war das Programm noch anders.)
# f.Zeitenreihen.testen <- function(Dudl.Matrix.schwarz.weiss,Dudl.Matrix.Fragezeichen,n.max.Tage=dim(Dudl.Matrix.schwarz.weiss)[2]){
#   # Zum Testen von Laufzeiten
#   # Funktioniert gerade nicht, weil u.a. Extrawünsche noch nicht eingebaut wurden
#   Zeit <- (2:n.max.Tage)/0
#   Zeit[1] <- NA
#   for (i in 2:n.max.Tage){
#     print(paste0("i=",i))
#     Zeit[i] <- system.time({
#       print(f.Plan.berechnen.aus.Matrizen(Dudl.Matrix.schwarz.weiss[,1:i],Dudl.Matrix.Fragezeichen[,1:i]))
#     })
#     print(paste0("Zeit[",i,"]=",Zeit[i]))
#   }
#   print(Zeit)
#   plot(1:n.max.Tage,Zeit)
# }
# 
# f.Sortierung.Testen <- function(Dudl.Matrix.schwarz.weiss,Dudl.Matrix.Fragezeichen,Anz.Tage.Zu.Testen = 9){
#   # Zum Testen von Laufzeiten
#   # Funktioniert gerade nicht, weil u.a. Extrawünsche noch nicht eingebaut wurden
#   
#   Anz.Testlaeufe <- 30
#   
#   Dudl.Matrix.schwarz.weiss <- Dudl.Matrix.schwarz.weiss[,1:Anz.Tage.Zu.Testen]
#   Dudl.Matrix.Fragezeichen <- Dudl.Matrix.Fragezeichen[,1:Anz.Tage.Zu.Testen]
#   
#   Zeit <- (1:Anz.Testlaeufe)/0
#   for (i in 1:Anz.Testlaeufe){
#     print(paste0("i=",i))
#     Neue.Sortierung <- sample(1:Anz.Tage.Zu.Testen)
#     Dudl.Matrix.schwarz.weiss <- Dudl.Matrix.schwarz.weiss[,Neue.Sortierung]
#     Dudl.Matrix.Fragezeichen <- Dudl.Matrix.Fragezeichen[,Neue.Sortierung]
#     Zeit[i] <- system.time({
#       print(f.Plan.berechnen.aus.Matrizen(Dudl.Matrix.schwarz.weiss,Dudl.Matrix.Fragezeichen))
#     })
#     print(paste0("Zeit[",i,"]=",Zeit[i]))
#   }
#   print(Zeit)
# }
# 
