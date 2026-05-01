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
            enemyManager.resetEnemyProperties();
            dungeonScene.createMap();
            userInterface.showReward();
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

            const enemiesSpawned = enemyManager.spawnEnemies(playerTileIndex);
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
                    dungeonScene.openReward();
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

    function openReward() {
        var f = function() {
            userInterface.showReward();
            dungeonScene.resetOneRoundRewards();
            playerManager.player.finishedAnimation.disconnect(f);
        }
        playerManager.player.finishedAnimation.connect(f);
    }

    function createNextLevel() {
        dungeonScene.currentDungeonLevel++;
        dungeonScene.createMap();
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
        playerMaxHealth: playerManager.maxHealth
        playerCurrentHealth: playerManager.currentHealth
        onApplyCurseBlessingPair: (blessingId,curseId) => {
                                        dungeonScene.applyBlessing(blessingId);
                                        dungeonScene.applyCurse(curseId);
                                        dungeonScene.createNextLevel();
                                        userInterface.closeRewards();
                                  }
    }

    function applyBlessing(id) {
        switch(id) {
        case "increase_damage":
            playerManager.damage++;
            break;
        case "more_full_hp":
            playerManager.maxHealth++;
            break;
        case "fully_heal":
            playerManager.currentHealth = playerManager.maxHealth;
            break;
        case "berserk":
            playerManager.berserkActive = true;
            playerManager.berserkIncreasedDamage++;
            break;
        case "revive":
            playerManager.reviveCount++;
            break;
        case "lifesteal":
            playerManager.additionalHealthOntKill++;
            break;
        default:
            throw new Error("no blessing id:",id)
        }
    }

    function applyCurse(id) {
        switch(id) {
        case "increase_enemy_hp":
            enemyManager.health++;
            break;
        case "increase_enemy_damage":
            enemyManager.damage++;
            break;
        case "increase_enemy_count":
            if(enemyManager.enemyCount < enemyManager.maxEnemyCount) {
                enemyManager.enemyCount++;
            }
            break;
        case "double_enemy_count_next_level":
            if(enemyManager.enemyCount * 2 <= enemyManager.maxEnemyCount) {
                enemyManager.enemyCountIsDoubled = true;
            }
            break;
        default:
            throw new Error("no curse id:",id)
        }
    }

    function resetOneRoundRewards() {
        enemyManager.enemyCountIsDoubled = false;
    }
}
