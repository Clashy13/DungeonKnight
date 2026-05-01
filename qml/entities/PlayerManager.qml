import QtQuick
import Felgo

EntityManager {
    id: playerManager
    property variant tilemap
    property variant player
    property variant enemyManager

    property int defaultHealth: 8
    property int defaultDamage: 3

    property int currentHealth: defaultHealth
    property int maxHealth: defaultHealth
    property int damage: defaultDamage

    property int reviveCount: 0
    property bool berserkActive: false
    property int berserkIncreasedDamage: 0
    property int additionalHealthOntKill: 0

    signal playerDied()
    signal finishedTurn()

    function spawnPlayer(row,column) {
        const playerPostion = tilemap.tileIndexToPosition(row,column);
        tilemap.setEntityTileOccupation(row,column);

        if(player === undefined) {
            var newEntityProperties = {
                row: row,
                column: column,
                imgSize: tilemap.tileSize,
                x: playerPostion.x,
                y: playerPostion.y
            };

            playerManager.createEntityFromUrlWithProperties(
                        Qt.resolvedUrl("Player.qml"),
                        newEntityProperties);
            player = getLastAddedEntity();
        } else {
            player.row = row;
            player.column = column;
            player.imgSize = tilemap.tileSize;
            player.x = playerPostion.x;
            player.y = playerPostion.y;
        }
        entityContainer.changeVisualEntityOrder();
    }

    function playerStats() {
        return [
                {"name": "Damage","value":playerManager.damage},
                {"name": "Revives","value":playerManager.reviveCount},
                {"name": "Health on Kill","value":playerManager.additionalHealthOntKill},
                {"name": "Berserk Damage","value":playerManager.berserkDamage()}]
    }

    function playerActionToTile(row,column) { // returns {row, column} of next tile
        if(playerManager.isNeighboringTileToPlayer(row,column)) {
            if(tilemap.tiles[row][column].occupied) {
                const killed = playerManager.attackEnemy(row,column)
                if(killed) {
                    playerManager.healAmount(playerManager.additionalHealthOntKill);
                    playerManager.movePlayerToTileIndex(row,column);
                    playerManager.finishTurnAfterAnimation();
                    return {row: player.row,column: player.column};
                } else {
                    playerManager.finishedTurn();
                    return {row: player.row,column: player.column}
                }
            } else {
                playerManager.movePlayerToTileIndex(row,column);
                playerManager.finishTurnAfterAnimation();
                return {row: player.row,column: player.column};
            }
        }
        const tileIndex = movePlayerTowards(row,column);
        playerManager.finishTurnAfterAnimation();
        return tileIndex;
    }

    function finishTurnAfterAnimation() {
        var f = () => {
            playerManager.finishedTurn();
            playerManager.player.finishedAnimation.disconnect(f);
        }
        playerManager.player.finishedAnimation.connect(f);
    }

    function movePlayerTowards(row,column) { // returns {row, column} of next tile or null if not moving
        const nextTileIndex = tilemap.nextStepOnPath({row: player.row, column: player.column},{row,column}, true);
        if(nextTileIndex !== null && player !== undefined) {
            playerManager.movePlayerToTileIndex(nextTileIndex.row,nextTileIndex.column);
            return nextTileIndex;
        }
        return null;
    }

    function movePlayerToTileIndex(row,column) {
        if(player !== undefined) {
            const playerPostion = tilemap.tileIndexToPosition(row,column);
            tilemap.changeEntityTileOccupation(player.row,player.column,row,column);
            player.row = row;
            player.column = column;
            player.moveTo(playerPostion.x,playerPostion.y);
            entityContainer.changeVisualEntityOrder();
        }
    }


    function attackEnemy(row,column) { // returns true if enemy has been killed and the player should move
        const actualDamage = playerManager.damage + playerManager.berserkDamage();
        return enemyManager.attackEnemy(actualDamage,row,column);
    }

    function isNeighboringTileToPlayer(row,column) {
        return Math.abs(player.row-row) <= 1 && Math.abs(player.column-column) <= 1
    }

    function attackPlayer(damage) {
        playerManager.currentHealth -= damage;
        if(playerManager.currentHealth <= 0) {
            if(playerManager.reviveCount > 0) {
                playerManager.reviveCount--;
                playerManager.currentHealth = Math.floor(playerManager.maxHealth / 2);
            } else {
               playerManager.playerDied();
            }
        }
    }

    function resetPlayerProperties() {
        playerManager.currentHealth = playerManager.defaultHealth;
        playerManager.maxHealth = playerManager.defaultHealth;
        playerManager.damage = playerManager.defaultDamage;
        playerManager.reviveCount = 0;
        playerManager.berserkActive = false;
        playerManager.berserkIncreasedDamage = 0;
        playerManager.additionalHealthOntKill = 0;
    }

    function healAmount(amount) {
        if(amount > 0) {
            playerManager.currentHealth = Math.min(playerManager.maxHealth,playerManager.currentHealth+amount);
        }
    }

    function berserkDamage() {
        if(playerManager.berserkActive) {
            const missingHP = playerManager.maxHealth - playerManager.currentHealth;
            return Math.floor(missingHP / 2) * playerManager.berserkIncreasedDamage;
        }
        return 0;
    }
}
