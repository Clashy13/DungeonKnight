import QtQuick
import Felgo

Scene {
    id: mainMenuScene
    signal changeToDungeonScene()

    Rectangle {
        anchors.fill: parent
        color: "#101010"
    }

    AppButton {
        anchors.centerIn: parent
        text: "Play"
        onClicked: changeToDungeonScene()
    }
}
