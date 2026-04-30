import QtQuick
import Felgo

EntityManager {
    id: playerManager
    property variant tilemap
    property variant player
    property variant enemyManager

    property bool animationRunning: false

    signal playerDied()

    function spawnPlayer() {
        playerManager.resetPlayerProperties();
        const tileIndex = tilemap.setEntityToRandomTileIndex();

        if(tileIndex !== null) {
            const {row,column} = tileIndex;
            const playerPostion = tilemap.tileIndexToPosition(row,column);

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
                player.finishedAnimation.connect(finishAnimation);
            } else {
                player.row = row;
                player.column = column;
                player.imgSize = tilemap.tileSize;
                player.x = playerPostion.x;
                player.y = playerPostion.y;
            }
            entityContainer.changeVisualEntityOrder();
        }
    }

    function playerActionToTile(row,column) { // returns {row, column} of next tile
        if(playerManager.isNeighboringTileToPlayer(row,column)) {
            if(tilemap.tiles[row][column].occupied) {
                const moved = playerManager.attackEnemy(row,column)
                if(moved) {
                    playerManager.movePlayerToTileIndex(row,column);
                    return {row: player.row,column: player.column};
                } else {
                    return {row: player.row,column: player.column}
                }
            } else {
                playerManager.movePlayerToTileIndex(row,column);
                return {row: player.row,column: player.column};
            }
        }
        return movePlayerTowards(row,column);
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
            animationRunning = true;
            player.moveTo(playerPostion.x,playerPostion.y);
            entityContainer.changeVisualEntityOrder();
        }
    }


    function attackEnemy(row,column) { // returns true if enemy has been killed and the player should move
        return enemyManager.attackEnemy(player.damage,row,column);
    }

    function isNeighboringTileToPlayer(row,column) {
        return Math.abs(player.row-row) <= 1 && Math.abs(player.column-column) <= 1
    }

    function attackPlayer(damage) {
        player.currentHealth -= damage;
        if(player.currentHealth <= 0) {
            playerManager.playerDied();
        }
    }

    function resetPlayerProperties() {
        if(player !== undefined) {
            player.currentHealth = player.maxHealth;
        }
    }

    function finishAnimation() {
        animationRunning = false;
    }
}
