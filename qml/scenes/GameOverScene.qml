import QtQuick
import Felgo

import "../ui"

Scene {
    id: gameOverScene
    signal changeToDungeonScene()
    signal changeToMainMenuScene()
    property int currentDungeonLevel

    Rectangle {
        anchors.fill: parent

        Image {
            anchors.fill: parent
            source: "../../assets/dungeon_brickwall.png"
            smooth: false
            fillMode: Image.Tile
        }
    }

    FontLoader {
        id: pixelFont
        source: "../../assets/PixelOperator8.ttf"
    }

    Column {
        anchors.centerIn: parent
        spacing: 40

        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 26

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Game Over"
                font.family: pixelFont.name
                font.pixelSize: 30
                color: "red"
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Score: Level " + gameOverScene.currentDungeonLevel
                font.family: pixelFont.name
                font.pixelSize: 16
                color: "white"
            }
        }

        MenuButton {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Try Again"
            onClicked: changeToDungeonScene()
        }

        MenuButton {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Main Menu"
            onClicked: changeToMainMenuScene()
        }
    }
}
