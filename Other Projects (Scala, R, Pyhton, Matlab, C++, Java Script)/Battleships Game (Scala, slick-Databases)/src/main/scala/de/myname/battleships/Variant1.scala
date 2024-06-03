// NON-FINISHED ATTEMPTS TO WRITE BETTER GUI



//package de.myname.battleships
//
//
// Variant1 is one outer application, with separate game and gui, sending events from one to the other
//
//import scala.swing._
//import scala.swing.event.Event
//
//object DoThis extends Event
//object DoThat extends Event
//
//class Game extends Publisher{
//        ...
//    if (...) publish(DoThis/DoThat)
//}
//
//class GUI extends Publisher{
//        ...
//    if (...) publish(DoThis/DoThat)
//}
//
//object mainProgram{
//    def main(args: Array[String]): Unit ={
//        val game = new Game
//        val gui = new BattleshipsGUI
//        listenTo(game,gui)
//        reactions +=  {
//            case DoThis => gui.doit
//            case DoThat => game.do...
//        }
//    }
//}