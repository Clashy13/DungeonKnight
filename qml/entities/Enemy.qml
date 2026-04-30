import QtQuick
import Felgo

Entity {
    id: enemy
    entityType: "enemy"
    imgSrc: "../../assets/skeleton.png"

    maxHealth: 1
    currentHealth: 1
    damage: 1
}
