import QtQuick
import Felgo

EntityManager {
    id: enemyManager
    property variant tilemap
    property var enemies: []
    property int pendingAnimations: 0

    property int defaultHealth: 5
    property int defaultDamage: 1
    property int defaultEnemyCount: 2
    property int maxEnemyCount: 20

    property int health: defaultHealth
    property int damage: defaultDamage

    property int enemyCount: defaultEnemyCount
    property bool enemyCountIsDoubled: false

    signal attackPlayer(damage: int)

    function spawnEnemies(playerTileIndex) {
        const tileIndexes = []
        const actualEnemyCount = enemyManager.enemyCountIsDoubled ? enemyManager.enemyCount * 2: enemyManager.enemyCount;
        for(let i = 0; i < actualEnemyCount; i++) {
            const tileIndex = enemyManager.possibleRandomTileIndex(playerTileIndex,tileIndexes);
            if(tileIndex === null) {
                return false;
            }
            tileIndexes.push(tileIndex);
        }

        for(let j = 0; j < tileIndexes.length; j++) {
            enemyManager.spawnEnemy(playerTileIndex, tileIndexes[j]);
        }
        return true;
    }

    function spawnEnemy(playerTileIndex, tileIndex) {
        const enemyPostion = tilemap.tileIndexToPosition(tileIndex.row,tileIndex.column);
        tilemap.setEntityTileOccupation(tileIndex.row,tileIndex.column);
        var newEntityProperties = {
            row: tileIndex.row,
            column: tileIndex.column,
            imgSize: tilemap.tileSize,
            x: enemyPostion.x,
            y: enemyPostion.y,
            currentHealth: enemyManager.health,
            maxHealth: enemyManager.health,
            damage: enemyManager.damage
        }

        const enemyId = enemyManager.createEntityFromUrlWithProperties(
                                    Qt.resolvedUrl("Enemy.qml"),
                                    newEntityProperties);
        const enemy = getLastAddedEntity();
        enemy.finishedAnimation.connect(enemyAnimationDone);
        enemies.push({id: enemyId, enemy: enemy})
        entityContainer.changeVisualEntityOrder();
    }

    function possibleRandomTileIndex(playerTileIndex, preventTileIndexes) {
        // try 5 times to get a valid position
        for(let i = 0; i < 5; i++) {
            const tileIndex = tilemap.getRandomFreeTilePosition(preventTileIndexes);
            if(tileIndex === null) {
                return null;
            }

            // check if there is a possible path to the player
            if(tilemap.isPathPossible(tileIndex,playerTileIndex,true)) {
                return tileIndex;
            }
        }
        return null;
    }

    function enemyActionsToTile(row,column) {
        for (var i = 0; i < enemies.length; i++) {
            enemyManager.enemyActionToTile(enemies[i].enemy,row,column);
        }
    }

    function enemyActionToTile(enemy,row,column) {
        if(enemyManager.isNeighboringTile(enemy,row,column)) {
            enemyManager.attackPlayer(enemy.damage);
        } else {
            enemyManager.moveEnemyTowards(enemy,row,column);
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
        tilemap.changeEntityTileOccupation(enemy.row,enemy.column,row,column);
        enemy.row = row;
        enemy.column = column;
        pendingAnimations++;
        enemy.moveTo(enemyPostion.x,enemyPostion.y);
        entityContainer.changeVisualEntityOrder();
    }

    function attackEnemy(damage,row,column) { // returns true if enemy has been killed
        const enemyProperties = enemyManager.enemyAtPosition(row,column);
        if(enemyProperties !== null) {
            const {id, enemy} = enemyProperties;
            enemy.currentHealth -= damage;
            if(enemy.currentHealth <= 0) {
                enemyManager.removeEnemy(enemy,id)
                return true;
            }
        }
        return false;
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
        entityContainer.changeVisualEntityOrder();
    }

    function clearEnemies() {
        removeAllEntities();
        enemyManager.pendingAnimations = 0;
        for(let i = 0; i < enemies.length; i++) {
            tilemap.removeEntity(enemies[i].row,enemies[i].column);
        }
        if(enemies.length > 0) {
            enemies.length = 0;
            entityContainer.changeVisualEntityOrder();
        }
    }

    function resetEnemyProperties() {
        enemyManager.health = enemyManager.defaultHealth;
        enemyManager.damage = enemyManager.defaultDamage;
        enemyManager.enemyCount = enemyManager.defaultEnemyCount;
        enemyManager.enemyCountIsDoubled = false;
    }
}
