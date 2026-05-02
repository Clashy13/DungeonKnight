import QtQuick
import Felgo
import QtQuick.Layouts

Rectangle {
    id: playerStatus
    color: "#303030"
    border.width: 2
    border.color: "#505050"
    width: 140
    height: 100

    property var playerStats

    function show(playerStats) {
        playerStatus.playerStats = playerStats;
        visible = true;
    }

    function playerStatNamesModel() {
        if(playerStatus.playerStats !== undefined) {
            return playerStatus.playerStats.map(stat => stat.name);
        }
        return [];

    }

    function playerStatValuesModel() {
        if(playerStatus.playerStats !== undefined) {
            return playerStatus.playerStats.map(stat => stat.value);
        }
        return [];
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
    }

    Column {
        anchors.fill: parent
        anchors.margins: 6
        spacing: 6

        AppText {
            text: "Player Stats"
            font.family: "PixelOperator8"
            font.pixelSize: 8
            color: "white"
        }

        Rectangle {
            width: parent.width
            height: 1
            color: "#606060"
        }

        Row {
            spacing: 6
            Column {
                spacing: 6
                Repeater {
                    model: playerStatus.playerStatNamesModel()
                    delegate: AppText {
                        text: modelData + ":"
                        font.family: "PixelOperator8"
                        font.pixelSize: 8
                        color: "white"
                    }
                }
            }
            Column {
                spacing: 6
                Repeater {
                    model: playerStatus.playerStatValuesModel()
                    delegate: AppText {
                        text: modelData
                        font.family: "PixelOperator8"
                        font.pixelSize: 8
                        color: "white"
                    }
                }
            }
        }
    }
}
