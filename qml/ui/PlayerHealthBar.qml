import QtQuick
import Felgo

Rectangle {
    id: healthBar
    border.width: 1
    border.color: "white"
    color: "transparent"
    property int value
    property int max

    Rectangle {
        color: "red"
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width * (value / max)
        z: -1
    }

    AppText {
        anchors.centerIn: parent
        text: `${healthBar.value} / ${healthBar.max}`
        color: "white"
        font.pixelSize: 8
        font.family: pixelFont.name
        font.bold: true
    }

    FontLoader {
        id: pixelFont
        source: "../../assets/PixelOperator8.ttf"
    }
}
