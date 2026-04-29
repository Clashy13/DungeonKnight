import QtQuick
import Felgo

EntityManager {
    id: playerManager
    property variant tilemap
    property variant player

    function spawnPlayer() {
        const tileIndex = tilemap.getRandomFreeTilePosition();

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
            } else {
                player.row = row;
                player.column = column;
                player.imgSize = tilemap.tileSize;
                player.x = playerPostion.x;
                player.y = playerPostion.y;
            }
        }
    }

    function movePlayerTowards(row,column) {
        const nextTileIndex = tilemap.nextStepOnPath({row: player.row, column: player.column},{row,column}, false);
        if(nextTileIndex !== null && player !== undefined) {
            movePlayerToTileIndex(nextTileIndex.row,nextTileIndex.column);
            return nextTileIndex;
        }
        return null;
    }

    function movePlayerToTileIndex(row,column) {
        if(player !== undefined) {
            const playerPostion = tilemap.tileIndexToPosition(row,column);
            player.row = row;
            player.column = column;
            player.x = playerPostion.x;
            player.y = playerPostion.y;
        }
    }
}
