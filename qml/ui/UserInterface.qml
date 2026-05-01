import QtQuick
import Felgo

Item {
    id: userInterface
    property int currentDungeonLevel
    property int playerMaxHealth
    property int playerCurrentHealth

    signal applyCurseBlessingPair(blessingId: string, curseId: string)

    anchors.margins: 12

    function showReward() {
        rewardPopup.show();
    }

    function closeRewards() {
        rewardPopup.visible = false;
    }

    FontLoader {
        id: pixelFont
        source: "../../assets/PixelOperator8.ttf"
    }

    Item {
        id: toprow
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 16

        PlayerHealthBar {
            id: playerHealthBar
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            max: userInterface.playerMaxHealth
            value: userInterface.playerCurrentHealth
            width: parent.width / 3
        }

        AppText {
            anchors.centerIn: parent
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Level " + currentDungeonLevel
            color: "white"
            font.family: pixelFont.name
            font.pixelSize: 12
        }
    }

    // AppText {
    //     anchors.top: parent.top
    //     anchors.horizontalCenter: parent.horizontalCenter
    //     text: "Level " + currentDungeonLevel
    //     color: "white"
    //     font.family: pixelFont.name
    //     font.pixelSize: 12
    // }

    // PlayerHealthBar {
    //     id: playerHealthBar
    //     anchors.top: parent.top
    //     anchors.left: parent.left
    //     max: userInterface.playerMaxHealth
    //     value: userInterface.playerCurrentHealth
    //     width: parent.width / 3
    //     height: 16
    // }

    RewardPopup {
        id: rewardPopup
        anchors.fill: parent
        visible: false
        onApplyCurseBlessingPair: (blessingId,curseId) => userInterface.applyCurseBlessingPair(blessingId,curseId)
    }

    // Test {

    // }
}
