import QtQuick
import QtQuick.Layouts
import Felgo

Item {
    id: tilemap
    property variant tiles: [] // 2d array of tiles forming rows and columns, value is {type: Tile.type, occupied: bool}
    property int tileSize: width / columns
    property int rows: 0
    property int columns: 0
    property variant stairsPosition
    signal clicked(row: int,column: int);

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
                        return tiles[row][column].type;
                    else
                        return Tile.Stone;
                }
                occupied:  {
                    if(tiles[row] !== undefined && tiles[row][column] !== undefined)
                        return tiles[row][column].occupied;
                    else
                        return false;
                }
                row: Math.floor(index / tilemap.columns) // get row from model index
                column: index % tilemap.columns // get column from model index
                Layout.fillWidth: true
                Layout.fillHeight: true
                onClicked: tilemap.clicked(row, column)
            }
        }
    }

    function reshapeMap(rows, columns, playerPosition, stairsPosition) {
        tilemap.rows = rows;
        tilemap.columns = columns;
        tilemap.stairsPosition = stairsPosition;

        const newTiles = [];
        for(let row = 0; row < rows; row++) {
            for(let col = 0; col < columns; col++) {
                if(newTiles[row] === undefined) {
                    newTiles[row] = [];
                }
                if(row === playerPosition.row && col === playerPosition.column) {
                    newTiles[row][col] = {type: Tile.Stone, occupied: false};
                } else if(row === stairsPosition.row && col === stairsPosition.column) {
                    newTiles[row][col] = {type: Tile.Stairs, occupied: false};
                } else {
                    addNewRandomTile(newTiles,row,col);
                }
            }
        }
        tilemap.tiles = newTiles;
    }

    function addNewRandomTile(tiles, row, column) {
        // chance of lava tiles appearing
        const lavaChance = (column > 0 && tiles[row][column-1] === Tile.Lava) // if left tile is lava
                         || (row > 0 && tiles[row-1][column] === Tile.Lava) // or if above tile is lava
                         ? 0.4 // higher chance for lava appearing in cluster
                         : 0.1; // lower change for lava
        const type = Math.random() < lavaChance ? Tile.Lava : Tile.Stone;
        tiles[row][column] = {type: type, occupied: false};
    }

    function tileIsFree(row,col) {
        return (
                    row >= 0 &&
                    col >= 0 &&
                    row < tilemap.tiles.length &&
                    col < tilemap.tiles[0].length &&
                    (tilemap.tiles[row][col].type === Tile.Stone || tilemap.tiles[row][col].type === Tile.Stairs) &&
                    !tiles[row][col].occupied
                    );
    }

    // calculate x and y of tile center
    function tileIndexToPosition(row,column) {
        let y = (row +0.5) / rows * height;
        let x = (column + 0.5) / columns * width;
        return Qt.point(x,y);
    }

    function setEntityToRandomTileIndex() { // returns {row,column} of tile or null if no free tile found
        const position = getRandomFreeTilePosition();
        if(position === null) {
            return null;
        }
        tiles[position.row][position.column].occupied = true;
        return position;
    }

    function changeEntityTileOccupation(currentRow,currentColumn,newRow,newColumn) {
        tiles[currentRow][currentColumn].occupied = false;
        tiles[newRow][newColumn].occupied = true;
    }

    function setEntityTileOccupation(row,column) {
        tiles[row][column].occupied = true;
    }

    function removeEntity(row,column) {
        if(tiles[row] !== undefined && tiles[row][column] !== undefined) {
            tiles[row][column].occupied = false;
        }
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

    function isPathPossible(source, destination, lastTileOccupied) {
      return getPath(source.column,source.row,destination.column,destination.row, lastTileOccupied) !== null;
    }

    function nextStepOnPath(source, destination, lastTileOccupied) {
        const result = tilemap.getPath(source.column,source.row,destination.column,destination.row, lastTileOccupied);
        if (!result || result.length < 2)
            return null;
        return result[1]; // next tile after source
    }

    function getPath(x1, y1, x2, y2, lastTileOccupied) {
        const openSet = [];
        const closedSet = new Set();

        function nodeKey(x, y) {
            return `${x},${y}`;
        }

        function heuristic(x, y) {
            // Manhattan distance
            return Math.abs(x - x2) + Math.abs(y - y2);
        }

        // Directions (8-way movement)
        const directions = [
            [1, 0], [-1, 0], [0, 1], [0, -1], // straight
            [1, 1], [1, -1], [-1, 1], [-1, -1] // diagonals
        ];

        openSet.push({
            x: x1,
            y: y1,
            g: 0,
            h: heuristic(x1, y1),
            f: 0,
            parent: null
        });

        while (openSet.length > 0) {
            // Get node with lowest f
            openSet.sort((a, b) => a.f - b.f);
            const current = openSet.shift();

            if (current.x === x2 && current.y === y2) {
                // Reconstruct path
                const path = [];
                let node = current;
                while (node) {
                    // convert x,y to row and column
                    path.push({row: node.y, column: node.x});
                    node = node.parent;
                }
                return path.reverse();
            }

            closedSet.add(nodeKey(current.x, current.y));

            for (const [dx, dy] of directions) {
                const nx = current.x + dx;
                const ny = current.y + dy;

                // convert x,y to row and column

                if(!(lastTileOccupied && ny === y2 && nx === x2) && !(nx === x1 && ny === y1)) {
                    if (!tilemap.tileIsFree(ny, nx)) continue;
                }

                if (closedSet.has(nodeKey(nx, ny))) continue;

                const isDiagonal = dx !== 0 && dy !== 0;
                const cost = isDiagonal ? Math.SQRT2 : 1;
                const g = current.g + cost;

                let neighbor = openSet.find(n => n.x === nx && n.y === ny);

                if (!neighbor) {
                    neighbor = {
                        x: nx,
                        y: ny,
                        g: g,
                        h: heuristic(nx, ny),
                        f: 0,
                        parent: current
                    };
                    neighbor.f = neighbor.g + neighbor.h;
                    openSet.push(neighbor);
                } else if (g < neighbor.g) {
                    neighbor.g = g;
                    neighbor.f = neighbor.g + neighbor.h;
                    neighbor.parent = current;
                }
            }
        }

        return null; // No path found
    }
}

