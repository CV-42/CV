f.Wert <- function(Plan,
                   Bearbeitungsreihenfolge,
                   Dudl.Matrix.Fragezeichen,
                   Wochentages.Vektor,
                   ist.Neuling.Vektor,
                   max.Anzahl.Dienste.Vektor,
                   n.Tage.bereits.belegt
                   ){
  # Bestmöglicher Wert ist 0
  # Mit Punkten bestraft werden kann:
  # - Wenn ein Tag unbelegt bleibt,
  # - wenn Fragezeichen ausgenutzt werden,
  
  # Wert erstmal Null setzten
  r <- 0
  
  # Eine (sinnlose?) Sicherheitsabfrage
  if (is.na(Plan)) return(Inf)
  
  # Nützliche Hilfsgrößen
  n.Tage <- dim(Plan)[2]
  n.Pers <- dim(Plan)[1]
  Anz.Personen.des.Tages <- colSums(Plan)
  Anz.Dienste.der.Person <- rowSums(Plan)
  
  # Es ist schlecht, wenn Tage freigelassen wurden.
  Anz.bisher.freigelassener.Tage <- 
    sum(
    Anz.Personen.des.Tages[Bearbeitungsreihenfolge[1:n.Tage.bereits.belegt]]<2
    )

  # Es ist schlecht, wenn jemand mit Fragezeichen ran muss.
  Anz.genutzter.Fragezeichen <- sum(Plan&Dudl.Matrix.Fragezeichen)
  
  # Es ist schlecht, wenn jemand mehr Dienste machen muss, als gewünscht.
  # Vektor mit TRUE, falls entsprechende Person zu viel machen muss:
    Personen.mehr.als.gewuenscht <- Anz.Dienste.der.Person > max.Anzahl.Dienste.Vektor
  # Anzahl der TRUEs in diesem (vorigen) Vektor:
    Anz.Personen.mehr.als.gewuenscht <- sum(Personen.mehr.als.gewuenscht)
    
  # Es ist schlecht, wenn zwei Neulinge zusammen (also ohne Veteranen*innen)
  # Dienst machen müssen.
  Matrix.Neuling.hat.Dienst <- Plan & matrix(ist.Neuling.Vektor,n.Pers,n.Tage)
  Anz.Neulinge.pro.Tag <- colSums(Matrix.Neuling.hat.Dienst);
  Anz.Tage.wo.zwei.Neulinge.zusammen.Dienst <- sum(Anz.Neulinge.pro.Tag==2)
  
  r <- r + Anz.genutzter.Fragezeichen * 1
  r <- r + Anz.bisher.freigelassener.Tage * 10
  r <- r + Anz.Personen.mehr.als.gewuenscht * 100
  r <- r + Anz.Tage.wo.zwei.Neulinge.zusammen.Dienst *1000
  
  return(r)
}