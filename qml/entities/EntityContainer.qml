import QtQuick
import Felgo

Item {
    id: entityContainer

    // is called when an entity is added, removed or moved
    // ensures that entities are visually sorted from top to bottom
    function changeVisualEntityOrder() {
        const sortedIndexes = children
          .map((_, i) => i)
          .sort((a, b) => children[a].row - children[b].row);
        for(let i = 0; i < sortedIndexes.length; i++) {
            children[sortedIndexes[i]].z = i;
        }
    }
}
