import QtQuick
import Felgo
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: giveUpMenu
    color: "#303030"
    border.width: 2
    border.color: "#505050"

    signal giveUp()

    FontLoader {
        id: pixelFont
        source: "../../assets/PixelOperator8.ttf"
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
            anchors.margins: 10

            AppText {
                anchors.verticalCenter: parent.verticalCenter
                text: "Give up?"
                font.family: pixelFont.name
                font.pixelSize: 16
                color: "white"
            }
        }

        RowLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 10

            MouseArea {
                id: cancelButton
                Layout.fillHeight: true
                Layout.fillWidth: true
                hoverEnabled: true
                onClicked: giveUpMenu.visible = false

                Rectangle {
                    anchors.fill: parent
                    color: cancelButton.containsMouse ? "#404042" : "#202021"
                    border.width: 2
                    border.color: cancelButton.containsMouse ? "#606063" : "#404042"
                }

                Text {
                    anchors.centerIn: parent
                    text: "Cancel"
                    font.family: pixelFont.name
                    font.pixelSize: 14
                    color: "white"
                }
            }

            MouseArea {
                id: yesButton
                Layout.fillHeight: true
                Layout.fillWidth: true
                hoverEnabled: true
                onClicked: {
                    giveUpMenu.visible = false;
                    giveUpMenu.giveUp();
                }

                Rectangle {
                    anchors.fill: parent
                    color: yesButton.containsMouse ? "#404042" : "#202021"
                    border.width: 2
                    border.color: yesButton.containsMouse ? "#606063" : "#404042"
                }

                Text {
                    anchors.centerIn: parent
                    text: "Yes"
                    font.family: pixelFont.name
                    font.pixelSize: 14
                    color: "white"
                }
            }
        }
    }
}
