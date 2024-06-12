package de.myname.battleships

class BattleShipsGameWithAI extends BattleShipsGame {
    class SpielerKI extends Player{
        override def prepare() = {
            shipList = List(
                new Ship(List((1,1),(1,2))),
                new Ship(List((3,2),(3,3),(3,4)))
            )
        }
        override def doShoot()= {
            // geht bestimmt auch schöner
            val uebrigeFelder = BattleShipsGameWithAI.this.listeAllerMoeglicherFeldkoordinaten filter
                { case (x, y) => SpielerKI.this.map.feldAufgedeckt(x)(y) == false
            }
            val zufallsGenerator = new scala.util.Random()
            val (x,y): (Int,Int) = uebrigeFelder(zufallsGenerator.nextInt(uebrigeFelder.length))
            SpielerKI.this.doShootAt(x,y)
        }
    }
    override val playerOne = new SpielerKI{
    }
    override val playerTwo = new SpielerKI{
    }
}
