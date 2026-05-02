import QtQuick
import Felgo

EntityBase {
    id: entity

    property int row // of tile
    property int column // of tile
    property string imgSrc // has to be squared for right image sizing
    property int imgSize
    property int walkSpeed: 5
    property int attackSpeed: 8

    property bool continousAnimation: false

    property int moveDuration
    signal finishedAnimation()
    signal finshedPartAnimation()

    Image {
        x: -entity.imgSize/ 2
        y: -entity.imgSize / 3 * 2
        width: entity.imgSize
        height: entity.imgSize
        smooth: false
        source: entity.imgSrc
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

        onFinished: {
            if(entity.continousAnimation) {
                entity.finshedPartAnimation();
            } else {
                entity.finishedAnimation();
            }
        }
    }

    function moveTo(targetX, targetY, speed) {
        var dx = targetX - x
        var dy = targetY - y
        var distance = Math.sqrt(dx*dx + dy*dy)

        moveDuration = distance / (entity.imgSize * speed) * 1000

        moveAnim.animations[0].to = targetX
        moveAnim.animations[1].to = targetY

        moveAnim.start();
    }

    function attack(targetX, targetY) {
        entity.continousAnimation = true;
        const currentX = entity.x;
        const currentY = entity.y;

        const xInBetween =  currentX + (targetX - currentX) * 0.65;
        const yInBetween =  currentY + (targetY - currentY) * 0.65;

        entity.moveTo(xInBetween,yInBetween,entity.attackSpeed);

        const f = () => {
            entity.moveTo(currentX,currentY,entity.attackSpeed);
            entity.continousAnimation = false;
            entity.finshedPartAnimation.disconnect(f);
        }
        entity.finshedPartAnimation.connect(f);
    }
}
