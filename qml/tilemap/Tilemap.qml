import QtQuick
import QtQuick.Layouts
import Felgo

GridLayout {
    id: tilemap
    rowSpacing: 0
    columnSpacing: 0
    property variant tiles // 2d array of tiles forming rows and columns, value is the type: Tile.Type

    Repeater {
        model: rows*columns
        delegate: Tile {
            type: tiles[row][column]
            row: Math.floor(index / columns) // get row from model index
            column: index % columns // get column from model index
            Layout.fillWidth: true
            Layout.fillHeight: true
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
}

