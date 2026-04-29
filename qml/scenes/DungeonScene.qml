import QtQuick
import Felgo

import "../tilemap"

Scene {
    id: dungeonScene

    Component.onCompleted: tilemap.updateRandom(11,7)

    Rectangle {
        id: background
        anchors.fill: parent
        anchors.margins: 10
        color: "#101010"

        Tilemap {
            id: tilemap
            anchors.centerIn: parent

            // keeps the tilemap in bounds regardless of the number of rows and columns
            property real aspectRatio: columns / rows
            width: Math.min(parent.width, parent.height * aspectRatio)
            height: width / aspectRatio

            rows: 0
            columns: 0
            tiles: []
        }
    }
}
