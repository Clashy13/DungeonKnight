import QtQuick
import Felgo

Entity {
    id: enemy
    entityType: "enemy"
    imgSrc: "../../assets/skeleton.png"

    property int currentHealth
    property int maxHealth
    property int damage

    EnemyHealthBar {
        id: healthBar
        visible: enemy.currentHealth < enemy.maxHealth
        width: enemy.imgSize * 0.8
        height: enemy.imgSize / 10
        x: -healthBar.width/ 2
        y: -enemy.imgSize / 3 * 2 - healthBar.height*2
        value: enemy.currentHealth
        max: enemy.maxHealth
    }
}
