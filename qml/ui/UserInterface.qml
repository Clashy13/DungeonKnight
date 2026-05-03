import QtQuick
import Felgo
import QtQuick.Controls

Item {
    id: userInterface
    property int currentDungeonLevel
    property int playerMaxHealth
    property int playerCurrentHealth

    signal applyCurseBlessingPair(blessingId: string, curseId: string)
    signal requestPlayerStats()
    signal giveUp()

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
            font.family: "PixelOperator8"
            font.pixelSize: 12
        }

        Row {
            anchors.top: parent.top
            anchors.right: parent.right
            height: parent.height
            spacing: 6

            MouseArea {
                id: playerStatusButton
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

            MouseArea {
                id: giveUpButton
                width: parent.height
                height: parent.height
                onClicked: giveUpMenu.visible = true

                Rectangle {
                    anchors.fill: parent
                    color: "#505050"
                    border.width: 1
                    border.color: "#707070"
                }

                Image {
                    anchors.centerIn: parent
                    width: parent.width * 0.6
                    height: parent.height * 0.6
                    smooth: false
                    source: "../../assets/skull.png"
                }
            }
        }
    }

    GiveUpMenu {
        id: giveUpMenu
        visible: false
        anchors.centerIn: parent
        width: 200
        height: 100
        onGiveUp: userInterface.giveUp()
    }

    RewardPopup {
        id: rewardPopup
        anchors.fill: parent
        visible: false
        onApplyCurseBlessingPair: (blessingId, curseId) => userInterface.applyCurseBlessingPair(blessingId, curseId)
    }
}
