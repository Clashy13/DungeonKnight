import QtQuick
import Felgo

Rectangle {
    id: healthBar
    color: "red"
    property int value
    property int max

    Rectangle {
        color: "#0f0"
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width * (value / max)
    }
}
