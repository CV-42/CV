Einlesen.Csv <- function(Dudl.Csv.Dateiname){
  
  ##### 2 Hilfsfunktionen #####
  
  f.Matrix.schwarz.weiss.erstellen <- function(Dudl.Matrix){
    # Fragezeichen und Häkchen durch TRUE ersetzen. Rest wird zu FALSE
    Matrix.schwarz.weiss <- (Dudl.Matrix == "?") | (Dudl.Matrix == intToUtf8(10004))
    return(Matrix.schwarz.weiss)
  }
  
  f.Matrix.Fragezeichen.erstellen <- function(Dudl.Matrix){
    # Nur Fragezeichen durch TRUE ersetzen
    Matrix.Fragezeichen <- Dudl.Matrix == "?"
    return(Matrix.Fragezeichen)
  }
  
  
  #### Eigentliche Einleseschritte #####
  
  # Von Datei in ein so genanntes Frame abspeichern
  Csv.Data.Frame <- read.csv(Dudl.Csv.Dateiname)
  
  # Namen der NLer extrahieren
  Namens.Vektor <- Csv.Data.Frame[,1] 
  
  # Liste der Datumsangaben extrahieren
  # !!! HIER DIE 3 ABÄNDERN, WENN ZUSÄTZLICHE SPALTEN DAZUKOMMEN !!!
  Datums.Vektor <- names(Csv.Data.Frame)[2:(length(names(Csv.Data.Frame))-3)] # Startet bei Zwei, weil erste Spalte die Namen der NLer enthält, und endet zweie vorher, weil die letzten zwei Zeilen für "min" und "max" stehen.
  
  # Zu jedem Datum den Wochentag extrahieren
  Wochentages.Vektor <- sapply(Datums.Vektor,function(x)substr(x,1,2))
  
  # Hilfsgrößen berechnen
  n.Tage <- length(Wochentages.Vektor)
  n.Leute <- length(Namens.Vektor)
  
  # eigentlichen Inhalt der Dudlmatrix extrahieren (mit Häkchen, Kreuzen und Fragezeichen)
  Dudl.Matrix <- Csv.Data.Frame[1:n.Leute,2:(n.Tage+1)]
  print(Dudl.Matrix)
  
  # Eine Matrix mit TRUE/FALSE für "Hat (sicher oder vielleicht) Zeit"
  Matrix.schwarz.weiss <- f.Matrix.schwarz.weiss.erstellen(Dudl.Matrix)
  # Eine Matrix mit TRUE/FALSE für "Hat nur vielleicht Zeit"
  Matrix.Fragezeichen <- f.Matrix.Fragezeichen.erstellen(Dudl.Matrix)
  
  # Maximale Anzahl der Dienste, die die Personen wollen
  max.Anzahl.Dienste.Vektor <- Csv.Data.Frame["max"] # entsprechende Frame-Spalte ist mit "max" beschriftet
  # Minimale Anzahl der Dienste, die die Personen wollen
  min.Anzahl.Dienste.Vektor <- Csv.Data.Frame["min"] # entsprechende Frame-Spalte ist mit "min" beschriftet
  
  # Vektor, der Angibt, ob jemand ein*e Neuling*in ist
  ist.Neuling.Vektor <- (Csv.Data.Frame["Neuling"]=="ja")
  # Hier kann was komisches passieren: Wenn die Spalte in der CSV-Datei leer ist, wenn also keine
  # Neulinge dabei sind, erhalten wir ist.Neuling.Vektor=c(NA,NA,...,NA). Das müssen wir abfangen:
  if (all(is.na(ist.Neuling.Vektor)))
    ist.Neuling.Vektor = rep(FALSE,n.Leute)
  
  # Rückgabe einer Liste, die benannte Elemente hat
  return(list(Dudl.Matrix.schwarz.weiss=Matrix.schwarz.weiss,
              Dudl.Matrix.Fragezeichen=Matrix.Fragezeichen,
              Wochentages.Vektor=Wochentages.Vektor,
              Datums.Vektor = Datums.Vektor,
              Namens.Vektor=Namens.Vektor,
              min.Anzahl.Dienste.Vektor = min.Anzahl.Dienste.Vektor,
              max.Anzahl.Dienste.Vektor = max.Anzahl.Dienste.Vektor,
              ist.Neuling.Vektor = ist.Neuling.Vektor))
}