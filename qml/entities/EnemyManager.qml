import QtQuick
import Felgo

EntityManager {
    id: enemyManager
    property variant tilemap
    property var enemies: []
    property int pendingAnimations: 0

    signal attackPlayer(damage: int)

    function spawnEnemies(count) {
        for(let i = 0; i < count; i++) {
            spawnEnemy();
        }
    }

    function spawnEnemy() {
        const tileIndex = tilemap.setEntityToRandomTileIndex()
        if(tileIndex !== null) {
            const enemyPostion = tilemap.tileIndexToPosition(tileIndex.row,tileIndex.column);
            var newEntityProperties = {
                row: tileIndex.row,
                column: tileIndex.column,
                imgSize: tilemap.tileSize,
                x: enemyPostion.x,
                y: enemyPostion.y
            }

            const enemyId = enemyManager.createEntityFromUrlWithProperties(
                                        Qt.resolvedUrl("Enemy.qml"),
                                        newEntityProperties);
            const enemy = getLastAddedEntity();
            enemy.finishedAnimation.connect(enemyAnimationDone);
            enemies.push({id: enemyId, enemy: enemy})
        }
    }

    function moveEnemiesTowards(row,column) {
        for (var i = 0; i < enemies.length; i++) {
            moveEnemyTowards(enemies[i].enemy,row,column);
        }
    }

    function moveEnemyTowards(enemy,row,column) {
        if(!enemyManager.isNeighboringTile(enemy,row,column)) {
            const nextTileIndex = tilemap.nextStepOnPath({row: enemy.row, column: enemy.column},{row,column},true);
            if(nextTileIndex !== null) {
                moveEnemyToTileIndex(enemy,nextTileIndex.row,nextTileIndex.column);
            }
        }
    }

    function isNeighboringTile(enemy,row,column) {
        return Math.abs(enemy.row-row) <= 1 && Math.abs(enemy.column-column) <= 1
    }

    function moveEnemyToTileIndex(enemy,row,column) {
        const enemyPostion = tilemap.tileIndexToPosition(row,column);
        tilemap.changeEntityTileIndex(enemy.row,enemy.column,row,column);
        enemy.row = row;
        enemy.column = column;
        pendingAnimations++;
        enemy.moveTo(enemyPostion.x,enemyPostion.y);
    }

    function enemyAnimationDone() {
        pendingAnimations--;
    }

    function enemyAtPosition(row,column) {
        for(let i = 0; i < enemies.length; i++) {
            if(enemies[i].enemy.row === row && enemies[i].enemy.column === column) {
                return enemies[i];
            }
        }
        return null;
    }

    function removeEnemy(enemy, id) {
        removeEntityById(id);
        tilemap.removeEntity(enemy.row,enemy.column);
        enemies = enemies.filter((enemy) => enemy.id !== id);
    }

    function clearEnemies() {
        removeAllEntities();
        for(let i = 0; i < enemies.length; i++) {
            tilemap.removeEntity(enemies[i],row,enemies[i].column);
        }
        enemies.length = 0;
    }
}
