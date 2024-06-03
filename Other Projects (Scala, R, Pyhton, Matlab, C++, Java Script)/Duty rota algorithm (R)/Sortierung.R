f.Sortieren <- function(Dudl.Matrix.schwarz.weiss){
  # Gibt einen Vektor aus. Dieser Vektor gibt an, in welcher Reihenfolge später
  # bei der Rekursion die Tage zu belegen versucht werden. (Tage, wo wenige
  # Leute Zeit haben, sollen zuerst belegt werden.)
  
  Anz.disponibler.Pers.des.Tages <- colSums(Dudl.Matrix.schwarz.weiss)
  
  # Lister der Tagesnummern (hier Tage von 1 bis ... 
  # durchnummeriert), sortiert nach Anz.disponibler.Pers.des.Tages
  Reihenfolge <- order(Anz.disponibler.Pers.des.Tages)
  
  return(Reihenfolge)
}