import QtQuick
import QtQuick.Controls
import Felgo

Button {
    id: menuButton
    font.family: pixelFont.name
    font.bold: true
    palette.buttonText: "white"
    font.pixelSize: 12
    width: 200
    height: 40
    background: Rectangle {
        anchors.fill: parent
        color: menuButton.hovered ? "#404042" : "#202021"
        border.width: 2
        border.color: menuButton.hovered ? "#606063" : "#404042"
    }
    onClicked: changeToDungeonScene()

    FontLoader {
        id: pixelFont
        source: "../../assets/PixelOperator8.ttf"
    }
}
