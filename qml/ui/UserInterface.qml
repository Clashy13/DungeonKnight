import QtQuick
import Felgo

Item {
    id: userInterface
    property int currentDungeonLevel
    anchors.margins: 10

    Column {
        id: levelIndicator
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 2

        AppText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Level " + currentDungeonLevel
            color: "white"
            font.pixelSize: 12
        }
    }
}
