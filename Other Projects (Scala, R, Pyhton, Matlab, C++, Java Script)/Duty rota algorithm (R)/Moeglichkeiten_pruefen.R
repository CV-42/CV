f.naechste.Moeglichkeiten <- function(Vorgabe, 
                                      Dudl.Matrix.schwarz.weiss, 
                                      max.Anzahl.Dienste.Vektor, 
                                      aktuell.zu.bearbeitender.Tag){

  # Berechnung, wie viele Tage die einzelnen Personen schon arbeiten müssen
  Anzahl.Tage.Der.Personen <- rowSums(Vorgabe)
  
  # Kurzschreibweise
  t <- aktuell.zu.bearbeitender.Tag
  
  # Überprüfung, welche Personen verfügbar sind
  Pers.verfuegbar <- (Anzahl.Tage.Der.Personen < max.Anzahl.Dienste.Vektor)&(Dudl.Matrix.schwarz.weiss[,t]==TRUE)
  verfuegbare.Pers <-which(Pers.verfuegbar)
  
  if (length(verfuegbare.Pers)<2) {
    # Wenn es keine zwei Leute gibt, die an jenem Tag arbeiten können,
    # wird einfach der Alte Plan zurück gegeben.
    # (D.h. die Spalte des aktuellen Tages hat nur FALSE drin.
    # Das schlägt sich später in der Wertung nieder.)
    Neue.Vorgaben.Liste <- list(1)
    Neue.Vorgaben.Liste[[1]] <- Vorgabe
  }else{
    # Wenn es >=2 Leute, die Zeit haben und noch nicht zu viele
    # Dienste haben, gibt, werden alle Möglichkeiten von Paarbelegungen erfasst.
    
    # verfügbare Paare in Matrixform
    verfuegbare.Paare <- t(combn(verfuegbare.Pers,2))
    n.verfuegbare.Paare <- dim(verfuegbare.Paare)[1]
    
    # verfügbare Paare in Listenform 
    Liste.verfuegbare.Paare <- lapply(1:n.verfuegbare.Paare,function(x)verfuegbare.Paare[x,])
    
    # Alle neuen Pläne in einer Liste zusammengefasst
    Neue.Vorgaben.Liste <- lapply(Liste.verfuegbare.Paare,function(x){
      Hilf <- Vorgabe
      Hilf[x[1],t] <- TRUE
      Hilf[x[2],t] <- TRUE
      return(Hilf)
    })
    
    # Die Möglichkeit, dass der Tag einfach frei gelassen wird,
    # soll trotzdem noch bedacht werden:
    Neue.Vorgaben.Liste[[length(Neue.Vorgaben.Liste)+1]] <- Vorgabe
  }
  return(Neue.Vorgaben.Liste)
}