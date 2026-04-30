import QtQuick
import Felgo

import "../tilemap"
import "../entities"
import "../ui"

Scene {
    id: dungeonScene

    property int currentDungeonLevel: 1

    signal playerDied()

    onVisibleChanged: {
        if (visible) {
            playerManager.resetPlayerProperties();
            dungeonScene.createMap();
        } else {
            enemyManager.clearEnemies();
        }
    }

    function createMap() {
        const rows = 11;
        const columns = 7;

        const playerTileIndex = {row: rows - 2,column: Math.floor(columns/2)};
        const stairsTileIndex = {row: 1, column: playerTileIndex.column};

        // try 20 times to get a valid setup
        let successful = false;
        for(let i = 0; i < 20; i++) {
            enemyManager.clearEnemies();

            tilemap.reshapeMap(rows, columns,playerTileIndex,stairsTileIndex);

            playerManager.spawnPlayer(playerTileIndex.row,playerTileIndex.column);
            if(!tilemap.isPathPossible(playerTileIndex,stairsTileIndex)) {
                continue;
            }

            const enemiesSpawned = enemyManager.spawnEnemies(playerTileIndex,3);
            if(!enemiesSpawned) {
                continue;
            }

            successful = true;
            break;
        }

        if(!successful) {
            throw new Error("cannot create map");
        }
    }

    function doPlayerActionToTile(row,column) {
        if(enemyManager.pendingAnimations === 0 && !playerManager.animationRunning) {
            const playerTileIndex = playerManager.playerActionToTile(row,column);
            if(playerTileIndex !== null) {
                if(dungeonScene.playerReadyforNextLevel()) {
                    dungeonScene.createNextLevel();
                    dungeonScene.currentDungeonLevel++;
                } else {
                    enemyManager.enemyActionsToTile(playerTileIndex.row,playerTileIndex.column);
                }
            }
        }
    }

    function playerReadyforNextLevel() {
        return playerManager.player !== undefined && playerManager.player.row === tilemap.stairsPosition.row && playerManager.player.column === tilemap.stairsPosition.column // if player on stairs
               && enemyManager.enemies.length === 0; // if all enemies are defeated
    }

    function createNextLevel() {
        var f = function() {
            dungeonScene.createMap();
            playerManager.player.finishedAnimation.disconnect(f);
        }
        playerManager.player.finishedAnimation.connect(f);
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: "#101010"
    }

    Item {
        anchors.fill: parent
        anchors.topMargin: 40
        anchors.bottomMargin: 40
        anchors.leftMargin: 10
        anchors.rightMargin: 10

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

    UserInterface {
        id: userInterface
        anchors.fill: parent
        currentDungeonLevel: dungeonScene.currentDungeonLevel
    }
}
