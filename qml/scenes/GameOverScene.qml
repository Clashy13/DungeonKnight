import QtQuick
import Felgo

Scene {
    id: mainMenu
    signal changeToDungeonScene()
    signal changeToMainMenuScene()

    Rectangle {
        anchors.fill: parent
        color: "#101010"
    }

    Column {
        anchors.centerIn: parent
        spacing: 10

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Game Over"
            font.pixelSize: 20
            color: "white"
        }

        AppButton {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Retry"
            onClicked: changeToDungeonScene()
        }

        AppButton {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Main Menu"
            onClicked: changeToMainMenuScene()
        }
    }
}
