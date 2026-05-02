import QtQuick
import Felgo
import QtQuick.Controls
import QtQuick.Layouts

import "../ui"

Scene {
    id: mainMenuScene
    signal changeToDungeonScene()

    FontLoader {
        id: pixelFont
        source: "../../assets/PixelOperator8.ttf"
    }

    Rectangle {
        anchors.fill: parent

        Image {
            anchors.fill: parent
            source: "../../assets/dungeon_brickwall.png"
            smooth: false
            fillMode: Image.Tile
        }
    }

    ColumnLayout {
        anchors.fill: parent

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true;

            Image {
                anchors.centerIn: parent
                height: parent.height
                width: parent.height
                smooth: false
                source: "../../assets/dungeon_main_title.png"
                fillMode: Image.PreserveAspectFit
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true;

            MenuButton {
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Enter the Dungeon"
                onClicked: changeToDungeonScene()
            }
        }
    }
}
