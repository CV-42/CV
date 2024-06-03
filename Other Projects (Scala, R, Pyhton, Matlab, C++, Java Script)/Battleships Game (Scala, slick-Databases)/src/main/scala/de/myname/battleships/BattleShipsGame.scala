package de.myname.battleships

//import slick.basic.DatabasePublisher
import breeze.linalg.DenseVector
import slick.jdbc.H2Profile.api._

import scala.concurrent.Future
//import slick.jdbc.H2Profile.api.Database
//import scala.concurrent.ExecutionContext.Implicits.global
import slick.lifted.{ForeignKeyQuery, ProvenShape}


abstract class BattleShipsGame (
                                  val fieldSize : Int = 42,
                                  val listShipSizes: List[Int] = List(2,3,3,4,4,5)
                                    ) {
    val listeAllerMoeglicherFeldkoordinaten: List[(Int,Int)] = {
        def listeWiederholen[T](n: Int, l: List[T]) =
            l.flatMap(e => l)
        def jedesElementWiederholen[T](n: Int, l: List[T]) =
            l.flatMap(e => List.fill(n)(e))
        val hilf = (0 until fieldSize).toList
        listeWiederholen(fieldSize, hilf) zip jedesElementWiederholen(fieldSize, hilf)
    }
    val playerOne : Player
    val playerTwo : Player
    var arrayObSpielerGewonnen = Array(false,false)

    class ShootAt(val x:Int, val y:Int){
        override def toString=
            "Schuss auf (" + x + "," + y + ")"
    }

    sealed abstract class Feedback()
    case class Hit(val x : Int, val y: Int) extends Feedback
    case class HitAndSunk(val x: Int, val y : Int, val bootsKoordinaten : List[(Int,Int)]) extends Feedback
    case class Miss(val x : Int, val y : Int) extends Feedback

    abstract class Player{
        class Ship(val koordinatenListe : List[(Int,Int)]){
            // Noch Sicherheitsabfragen einbauen!!! Z.B. darf nicht eine Koordinate zweimal belegt sein!!!!!!
            def length = koordinatenListe.length
            var listDestroyedBoolean = scala.collection.mutable.ListBuffer.fill(length)(false)
            def listDestroyedInt : List[Int] = {
                val indices = 0 until length
                indices.filter{listDestroyedBoolean(_) == true}.toList
            }
            def sunk =
                listDestroyedBoolean.forall(x=>x) // geht das kürzer ?????????????????????????????
            def liesOn(x:Int, y:Int) : Boolean =
                koordinatenListe.exists(_==(x,y))
            def getsDestroyedAt(x:Int, y:Int) ={
                val idx = koordinatenListe.indexWhere(_==(x,y))
                listDestroyedBoolean(idx) = true
            }
        }



        class Map(val size : Int){
            val feldAufgedeckt : Array[Array[Boolean]] = Array.ofDim[Boolean](fieldSize, fieldSize) //alles false am Anfang
            // lieber var und immutable oder val und mutable??????????????????????????????????????????
            var listeEntdeckterBootsteile : List[(Int,Int)] = Nil
            var listeListeKomplettEntdeckterBootskoordinaten : List[List[(Int,Int)]] = Nil
            def trefferEintragen(x:Int,y:Int) = {
                listeEntdeckterBootsteile = (x,y) :: listeEntdeckterBootsteile
                feldAufgedeckt(x)(y) = true
            }
            def versenkungEintragen(x:Int,y:Int,koordinatenListe:List[(Int,Int)]) ={
                trefferEintragen(x,y)
                listeListeKomplettEntdeckterBootskoordinaten = koordinatenListe :: listeListeKomplettEntdeckterBootskoordinaten
            }
            def fehlschussEintragen(x:Int,y:Int) =
                feldAufgedeckt(x)(y) = true
        }

        val map : Map = new Map(BattleShipsGame.this.fieldSize)
        var shipList : List[Ship] = Nil
        def prepare()
        def lost : Boolean = {
            shipList.forall(_.sunk)
        }
        def hasShipOn(x:Int, y:Int):Boolean ={
            if ( shipList.exists(boot => boot.liesOn(x,y)))
                true
            else
                false
        }

        def doShoot() : ShootAt
        def doShootAt(x:Int, y:Int) : ShootAt =
            new ShootAt(x,y)
        def reagierenUndReaktionAuf(shoot : ShootAt) : Feedback = {
            val x = shoot.x
            val y = shoot.y
            // besser mit match ?????????????????????????????
            val getroffenesBoot : Option[Ship] = shipList.find(boot => boot.liesOn(x,y))
            getroffenesBoot match{
                case Some(b) => b.getsDestroyedAt(x,y)
                    if (b.sunk)
                        new HitAndSunk(x,y,b.koordinatenListe)
                    else
                        new Hit(x,y)
                case None => new Miss(x,y)
            }
        }
        def zurKenntnisNehmen(feedback : Feedback) = {
            feedback match {
                case Hit(x,y) => map.trefferEintragen(x,y)
                case HitAndSunk(x,y,koordinatenListe) => map.versenkungEintragen(x,y,koordinatenListe)
                case Miss(x,y) => map.fehlschussEintragen(x,y)
            }
        }
    }

    def plotTheMoment = {
        import breeze.plot._

        val fig = Figure()
        val pltOne = fig.subplot(1,2,0) // setzt rows von fig auf 1 und cols auf 2 und setzt pltOne auf das nullte Feld
        val pltTwo = fig.subplot(1,2,1) // setzt rows... (also bleibt wie beim alten) und setzt pltTwo auf das erste Feld)

        def coordinatesOfShips(player: Player) : (DenseVector[Int], DenseVector[Int]) = {
            val hilfx = player.shipList.flatMap(_.koordinatenListe.map(_._1))
            val x = new DenseVector[Int]( hilfx.toArray )
            val hilfy = player.shipList.flatMap(_.koordinatenListe.map(_._2))
            val y = new DenseVector[Int]( hilfy.toArray )
            (x,y)
        }
        val (x1,y1) = coordinatesOfShips(playerOne)
        val (x2,y2) = coordinatesOfShips(playerTwo)

        def coordinatesOfDestroyedParts(player: Player) : (DenseVector[Int], DenseVector[Int]) = {
            val hilf : List[List[(Int,Int)]] = for (ship <- player.shipList) yield {
                val idxDestroyed = ship.listDestroyedInt
                for (idx <- idxDestroyed) yield
                    ship.koordinatenListe(idx)
            }
            val (x,y) = hilf.flatten.unzip
            (new DenseVector[Int](x.toArray), new DenseVector[Int](y.toArray))
        }

        val (dx1,dy1) = coordinatesOfDestroyedParts(playerOne)
        val (dx2,dy2) = coordinatesOfDestroyedParts(playerTwo)

        pltOne += plot(x1,y1,'.') // plot boats of playerOne
        pltOne += plot(dx1,dy1,style = '+') // plot destroyed parts of playerOne
        pltTwo += plot(x2,y2, style = '.') // plot boots of playerTwo
        pltTwo += plot(dx2,dy2, style = '+') // plot destroyed parts of playerTwo
         //fehtl noch Fehlschüsse hinzumalen
        fig.refresh()
    }


    def playTheGame() = {
        println("Vorbereitungen werden getroffen...")
        playerOne.prepare()
        playerTwo.prepare()
        def jeweilsEinenZugMachen(runde: Int) = {
            val schussEins = playerOne.doShoot()
            val rueckmeldungEins = playerTwo.reagierenUndReaktionAuf(schussEins)
            playerOne.zurKenntnisNehmen(rueckmeldungEins)

            val schussZwei = playerTwo.doShoot()
            val rueckmeldungZwei = playerOne.reagierenUndReaktionAuf(schussZwei)
            playerTwo.zurKenntnisNehmen(rueckmeldungZwei)

            databaseInterface.writeRoundToDb(runde, rueckmeldungEins, rueckmeldungZwei)

        }
        def weitereZuegeMachen(runde : Int): Unit = {
            if (runde%100 == 0)
                println("Start Runde " + runde)
            jeweilsEinenZugMachen(runde)
            if (playerOne.lost)
                arrayObSpielerGewonnen(1) = true
            if (playerTwo.lost)
                arrayObSpielerGewonnen(0) = true
            if (arrayObSpielerGewonnen.exists(x=>x))
                println("Spiel vorbei. Irgendwer hat gewonnen.")
            else
                weitereZuegeMachen(runde + 1)
        }
        weitereZuegeMachen(0)
        println("listeObSpielerGewonnen=" + arrayObSpielerGewonnen.mkString(" "))
    }

    // --------------- Ab hier Klassen und so zur Speicherung in Datenbank ----------------------
    // kann man das auch in einen Trait auslagern ?????????????????????????????????????????
    object databaseInterface {
        import scala.concurrent.ExecutionContext.Implicits.global
        import scala.concurrent.duration._
        import scala.concurrent._

        // Class that models the database entries
        class Rounds(tag: Tag) extends Table[(Int, Int, Int, Int, Int, Boolean, Boolean, Boolean, Boolean)](tag, "ROUNDS") {
            // This is the primary key column:
            def roundNumber: Rep[Int] = column[Int]("RUNDE", O.PrimaryKey)

            def shootOneX: Rep[Int] = column[Int]("SHOOT_ONE_X")
            def shootOneY: Rep[Int] = column[Int]("SHOOT_ONE_Y")
            def shootTwoX: Rep[Int] = column[Int]("SHOOT_TWO_X")
            def shootTwoY: Rep[Int] = column[Int]("SHOOT_TWO_Y")
            def hitOne: Rep[Boolean] = column[Boolean]("HIT_ONE")
            def hitTwo: Rep[Boolean] = column[Boolean]("HIT_TWO")
            def destroyedOne : Rep[Boolean] = column[Boolean]("DESTROYED_ONE")
            def destroyedTwo : Rep[Boolean] = column[Boolean]("DESTROYED_TWO")

            // Every table needs a * projection with the same type as the table's type parameter
            def * : ProvenShape[(Int, Int, Int, Int, Int, Boolean, Boolean, Boolean, Boolean)] =
                (roundNumber, shootOneX, shootOneY, shootTwoX, shootTwoY, hitOne, hitTwo, destroyedOne, destroyedTwo)
        }

        // create database
        val rounds = TableQuery[Rounds]
        lazy val db = Database.forConfig("h2mem1")
        Await.result(db.run(rounds.schema.create), Duration.Inf)
        //db.run(rounds.schema.create)
        // method for writing Entries to the database
        def writeRoundToDb(roundNumber: Int,
                           rueckmeldungEins: Feedback,
                           rueckmeldungZwei: Feedback): Unit ={
            val (shootOneX: Int,
                shootOneY: Int,
                hitOne: Boolean,
                destroyedOne: Boolean) = rueckmeldungEins match{
                case HitAndSunk(x,y,l) => (x,y,true, true)
                case Hit(x,y) => (x,y,true, false)
                case Miss(x,y) => (x,y,false,false)
            }
            val (shootTwoX: Int,
                shootTwoY: Int,
                hitTwo: Boolean,
                destroyedTwo: Boolean) = rueckmeldungZwei match{
                case HitAndSunk(x,y,l) => (x,y,true, true)
                case Hit(x,y) => (x,y,true, false)
                case Miss(x,y) => (x,y,false,false)
            }
            Await.result(
                db.run(
                    rounds +=  (roundNumber, shootOneX, shootOneY, shootTwoX, shootTwoY, hitOne, hitTwo, destroyedOne, destroyedTwo)
                ),
                Duration.Inf)
        }

        // method for extracting entry from Database
        def extractRound(roundNumbr: Int) : Future[Seq[(Int, Int, Int, Int, Int, Boolean, Boolean, Boolean, Boolean)]]={
            val query = rounds.filter(_.roundNumber === roundNumbr)
            val queryAction = query.result
            val result = db.run(queryAction)
            Await.result(result, Duration.Inf)
            result
        }

        def printRound(roundNumber: Int):Unit={
            val resultFuture = extractRound(roundNumber)
            Await.result(resultFuture,Duration.Inf)
            resultFuture onComplete{
                case scala.util.Success(x) => println(x.head)
                case scala.util.Failure(t) => println("An error has occurred: " + t.getMessage)
            }
        }

    }



}