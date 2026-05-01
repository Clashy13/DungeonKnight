import QtQuick
import Felgo
import QtQuick.Controls

Item {
    id: userInterface
    property int currentDungeonLevel
    property int playerMaxHealth
    property int playerCurrentHealth
    width: implicitWidth + 20
    height: implicitHeight + 20

    signal applyCurseBlessingPair(blessingId: string, curseId: string)
    signal requestPlayerStats()

    anchors.margins: 12

    function showReward() {
        rewardPopup.show();
    }

    function closeRewards() {
        rewardPopup.visible = false;
    }

    function showPlayerStatus(playerStats) {
        playerStatus.show(playerStats);
    }

    function closePanels() {
        playerStatus.visible = false;
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

        MouseArea {
            id: playerStatusButton
            anchors.top: parent.top
            anchors.right: parent.right
            width: parent.height
            height: parent.height
            onClicked: playerStatus.visible ? playerStatus.visible = false : userInterface.requestPlayerStats()
            Rectangle {
                anchors.fill: parent
                color: "#505050"
                border.width: 1
                border.color: "#707070"
            }

            Image {
                anchors.centerIn: parent
                width: parent.width * 0.8
                height: parent.height * 0.8
                smooth: false
                source: "../../assets/knight.png"
            }

            PlayerStatus {
                id: playerStatus
                visible: false
                anchors.top: parent.bottom
                anchors.right: parent.right
            }
        }
    }

    RewardPopup {
        id: rewardPopup
        anchors.fill: parent
        visible: false
        onApplyCurseBlessingPair: (blessingId,curseId) => userInterface.applyCurseBlessingPair(blessingId,curseId)
    }
}
