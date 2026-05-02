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

    property var targetTileIndex

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
        playerManager.targetTileIndex = {row:row,column:column};
        if(player.row === row && player.column === column) {
            playerManager.finishedTurn();
            return {row,column: column};
        }

        if(playerManager.isNeighboringTileToPlayer(row,column)) {
            if(tilemap.tiles[row][column].occupied) {
                const killed = playerManager.attackEnemy(row,column)
                if(killed) {
                    playerManager.healAmount(playerManager.additionalHealthOntKill);
                    playerManager.movePlayerToTileIndex(row,column,true);
                    playerManager.finishTurnAfterAnimation();
                    return {row: player.row,column: player.column};
                } else {
                    const position = tilemap.tileIndexToPosition(row,column);
                    player.attack(position.x,position.y,player.attackSpeed);
                    playerManager.finishTurnAfterAnimation();
                    return {row: player.row,column: player.column}
                }
            } else {
                playerManager.movePlayerToTileIndex(row,column);
                playerManager.finishTurnAfterAnimation();
                return {row: player.row,column: player.column};
            }
        }
        const tileIndex = movePlayerTowards(row,column);
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
        if(enemyManager.enemies.length === 0) {
            playerManager.movePlayerAlongPathTo(row,column);
        } else {
            const nextTileIndex = tilemap.nextStepOnPath({row: player.row, column: player.column},{row,column}, true);
            if(nextTileIndex !== null && player !== undefined) {
                playerManager.movePlayerToTileIndex(nextTileIndex.row,nextTileIndex.column);
                playerManager.finishTurnAfterAnimation();
                return nextTileIndex;
            }
            return null;
        }
    }

    function movePlayerAlongPathTo(row,column) {
        if(player !== undefined) {
            const pathOfTiles = tilemap.getPath(player.column,player.row,column,row);
            if(pathOfTiles !== null) {
                const path = pathOfTiles.map(tileIndex => {
                    return {tile: tileIndex, position: tilemap.tileIndexToPosition(tileIndex.row,tileIndex.column)};
                });
                playerManager.movePlayerAlongPath(path,1,row,column);
                if(playerManager.targetTileChanged(row,column)) {
                    playerManager.movePlayerAlongPathTo(playerManager.targetTileIndex.row,playerManager.targetTileIndex.column);
                }
            }
        }
    }

    function movePlayerAlongPath(path, index, targetrow, targetColumn) {
        if(playerManager.targetTileChanged(targetrow,targetColumn)) {
            player.continousAnimation = false;
            return;
        }
        player.continousAnimation = true;
        const {row,column} = path[index].tile;
        const {x,y} = path[index].position;
        player.moveTo(x,y,player.walkSpeed);

        const f = () => {
            tilemap.changeEntityTileOccupation(player.row,player.column,row,column);
            player.row = row;
            player.column = column;
            if(index + 1 < path.length) {
                playerManager.movePlayerAlongPath(path, index + 1, targetrow, targetColumn);
            }
            else {
                player.continousAnimation = false;
            }
            playerManager.finishedTurn();
            player.finshedPartAnimation.disconnect(f);
        }
        player.finshedPartAnimation.connect(f);
    }

    function targetTileChanged(row,column) {
        return row !== playerManager.targetTileIndex.row || column !== playerManager.targetTileIndex.column;
    }

    function movePlayerToTileIndex(row,column, kill) {
        if(player !== undefined) {
            const playerPostion = tilemap.tileIndexToPosition(row,column);
            tilemap.changeEntityTileOccupation(player.row,player.column,row,column);
            player.row = row;
            player.column = column;
            const speed = kill ? player.attackSpeed : player.walkSpeed
            player.moveTo(playerPostion.x,playerPostion.y,speed);
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
