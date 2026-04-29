import QtQuick
import QtQuick.Layouts
import Felgo

Item {
    id: tilemap
    property variant tiles: [] // 2d array of tiles forming rows and columns, value is the type: Tile.Type
    property int tileSize: width / columns
    property int rows: 0
    property int columns: 0

    GridLayout {
        id: gridlayout
        anchors.fill: parent
        rows: tilemap.rows
        columns: tilemap.columns
        rowSpacing: 0
        columnSpacing: 0

        Repeater {
            model: tilemap.rows*tilemap.columns
            delegate: Tile {
                type: {
                    if(tiles[row] !== undefined && tiles[row][column] !== undefined)
                        return tiles[row][column];
                    else
                        return Tile.Stone;
                }
                row: Math.floor(index / tilemap.columns) // get row from model index
                column: index % tilemap.columns // get column from model index
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }

    function updateRandom(rows, columns) {
        tilemap.rows = rows;
        tilemap.columns = columns;
        const newTiles = [];
        for(let row = 0; row < rows; row++) {
            for(let col = 0; col < columns; col++) {
                if(newTiles[row] === undefined) {
                    newTiles[row] = [];
                }
                addNewTile(newTiles,row,col);
            }
        }
        tilemap.tiles = newTiles;
    }

    function addNewTile(tiles, row, column) {
        // chance of lava tiles appearing
        const lavaChance = (column > 0 && tiles[row][column-1] === Tile.Lava) // if left tile is lava
                        || (row > 0 && tiles[row-1][column] === Tile.Lava) // or if above tile is lava
                        ? 0.4 // higher chance for lava appearing in cluster
                        : 0.1; // lower change for lava
        tiles[row][column] = Math.random() < lavaChance ? Tile.Lava : Tile.Stone;
    }

    function tileIsFree(row,col) {
        return (
            row >= 0 &&
            col >= 0 &&
            row < tilemap.tiles.length &&
            col < tilemap.tiles[0].length &&
            tilemap.tiles[row][col] === Tile.Stone
          );
    }

    // calculate x and y of tile center
    function tileIndexToPosition(row,column) {
        let y = (row +0.5) / rows * height;
        let x = (column + 0.5) / columns * width;
        return Qt.point(x,y);
    }

    function getRandomFreeTilePosition() {
        if(!tilemap.freeTileExists()) {
            return null;
        }

        while(true) {
            const row = tilemap.randomNumberBetween(0,rows);
            const column = tilemap.randomNumberBetween(0,columns);
            if(tilemap.tileIsFree(row,column)) {
                return {row,column};
            }
        }
    }

    function randomNumberBetween(min,max) {
        return Math.floor(Math.random() * (max - min + 1) + min);
    }

    function freeTileExists() {
        for(let row = 0; row < tilemap.rows; row++) {
            for(let col = 0; col < tilemap.columns; col++) {
                if(tilemap.tileIsFree(row,col)) {
                    return true;
                }
            }
        }
        return false;
    }
}

