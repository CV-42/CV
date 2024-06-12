package de.myname.battleships

import scala.swing._
import scala.swing.event.{ButtonClicked, MouseClicked}

object BattleShipsGameGUI extends SimpleSwingApplication {

    val game = new BattleShipsGameWithAI

    val top = new MainFrame {
        title = "Welcome"
        val prepareButton = new Button("Prepare Game")
        val helloLabel = new Label("Welcome")
        listenTo(prepareButton)
        reactions += {
            case ButtonClicked(prepareButton) =>
                game.playerOne.prepare()
                game.playerTwo.prepare()
                this.visible = false
                workingFrame.visible = true
        }
        contents = prepareButton
    }

    val workingFrame = new MainFrame {
        title = "Battleships Game"
        val oneRoundButton = new Button("Play one round")
        val remainingRoundsButton = new Button("Play remaining rounds")
        val plotCurrentButton = new Button("Plot currend state")
        contents = new FlowPanel(oneRoundButton,remainingRoundsButton,plotCurrentButton)
        listenTo(oneRoundButton, remainingRoundsButton, plotCurrentButton)
        reactions += {
            case ButtonClicked(oneRoundButton) => ???
  s          case event.ButtonClicked(`remainingRoundsButton`) =>
                game.playTheGame()
            case event.ButtonClicked(`plotCurrentButton`) =>
                game.plotTheMoment
        }
    }
}
