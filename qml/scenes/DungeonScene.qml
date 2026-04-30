import QtQuick
import Felgo

import "../tilemap"
import "../entities"

Scene {
    id: dungeonScene

    onVisibleChanged: {
        if (visible) {
            dungeonScene.createMap();
        }
    }

    function createMap() {
        tilemap.updateRandom(11, 7);
        enemyManager.clearEnemies();
        playerManager.spawnPlayer();
        enemyManager.spawnEnemies(3);
    }

    function moveEntities(row,column) {
        if(!playerManager.animationRunning) {
            const playerTileIndex = playerManager.movePlayerTowards(row,column);
            if(playerTileIndex !== null) {
                enemyManager.moveEnemiesTowards(playerTileIndex.row,playerTileIndex.column);
            }
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

            onClicked: (row,column) => dungeonScene.moveEntities(row,column)
        }

        EnemyManager {
            id: enemyManager
            entityContainer: tilemap
            tilemap: tilemap
        }

        PlayerManager {
            id: playerManager
            entityContainer: tilemap
            tilemap: tilemap
        }
    }
}
