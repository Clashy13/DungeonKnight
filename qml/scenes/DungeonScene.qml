import QtQuick
import Felgo

import "../tilemap"
import "../entities"

Scene {
    id: dungeonScene

    onVisibleChanged: {
        if (visible) {
            tilemap.updateRandom(11, 7);
            playerManager.spawnPlayer();
        }
    }

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

            onClicked: (row,column) => playerManager.movePlayerTowards(row,column)
        }

        PlayerManager {
            id: playerManager
            entityContainer: tilemap
            tilemap: tilemap
        }
    }
}
