import QtQuick
import Felgo

import "../tilemap"
import "../entities"

Scene {
    id: dungeonScene

    signal playerDied()

    onVisibleChanged: {
        if (visible) {
            dungeonScene.createMap();
        } else {
            enemyManager.clearEnemies();
        }
    }

    function createMap() {
        tilemap.updateRandom(11, 7);
        enemyManager.clearEnemies();
        playerManager.spawnPlayer();
        enemyManager.spawnEnemies(3);
    }

    function doPlayerActionToTile(row,column) {
        if(enemyManager.pendingAnimations === 0 && !playerManager.animationRunning) {
            const playerTileIndex = playerManager.playerActionToTile(row,column);
            if(playerTileIndex !== null) {
                enemyManager.enemyActionsToTile(playerTileIndex.row,playerTileIndex.column);
            }
        }
    }

    Rectangle {
        id: background
        anchors.fill: parent
        anchors.margins: 20
        color: "#101010"

        Tilemap {
            id: tilemap
            anchors.centerIn: parent

            // keeps the tilemap in bounds regardless of the number of rows and columns
            property real aspectRatio: columns / rows
            width: Math.min(parent.width, parent.height * aspectRatio)
            height: width / aspectRatio

            onClicked: (row,column) => dungeonScene.doPlayerActionToTile(row,column)

            EntityContainer {
                id: entityContainer
            }
        }

        EnemyManager {
            id: enemyManager
            entityContainer: entityContainer
            tilemap: tilemap
            onAttackPlayer: (damage) => playerManager.attackPlayer(damage)
        }

        PlayerManager {
            id: playerManager
            entityContainer: entityContainer
            tilemap: tilemap
            enemyManager: enemyManager
            onPlayerDied: dungeonScene.playerDied()
        }
    }
}
