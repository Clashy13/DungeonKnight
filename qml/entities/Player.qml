import QtQuick
import Felgo

Entity {
    id: player

    entityType: "player"
    imgSrc: "../../assets/knight.png"

    maxHealth: 3
    currentHealth: 3
    damage: 1
}
