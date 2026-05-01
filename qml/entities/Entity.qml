import QtQuick
import Felgo

EntityBase {
    id: entity

    property int row // of tile
    property int column // of tile
    property string imgSrc // has to be squared for right image sizing
    property int imgSize

    property int moveDuration
    signal finishedAnimation()

    Image {
        x: -entity.imgSize/ 2
        y: -entity.imgSize / 3 * 2
        width: entity.imgSize
        height: entity.imgSize
        smooth: false
        source: entity.imgSrc
    }

    function moveTo(targetX, targetY) {
        var dx = targetX - x
        var dy = targetY - y
        var distance = Math.sqrt(dx*dx + dy*dy)

        const speed = entity.imgSize * 4
        moveDuration = distance / speed * 1000

        moveAnim.animations[0].to = targetX
        moveAnim.animations[1].to = targetY

        moveAnim.start();
    }

    ParallelAnimation {
        id: moveAnim

        NumberAnimation {
            target: entity
            property: "x"
            duration: moveDuration
            easing.type: Easing.Linear
        }

        NumberAnimation {
            target: entity
            property: "y"
            duration: moveDuration
            easing.type: Easing.Linear
        }

        onFinished: entity.finishedAnimation();
    }
}
