import QtQuick
import Felgo
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: rewardPopup

    property int count: 3

    signal applyCurseBlessingPair(blessingId: string, curseId: string)

    function show() {
        rewardPopup.fillRewardModel();
        rewardPopup.visible = true;
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: Qt.rgba(0,0,0,0.7)
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        AppText {
            text: "Choose Blessing / Reward"
            font.family: "PixelOperator8"
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: 46
            font.pixelSize: 12
            color: "white"
        }

        ColumnLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 6

            Repeater {
                model: rewardModel
                delegate: Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: mouseArea.containsMouse ? "#505050" : "#303030"
                    border.width: 2
                    border.color: mouseArea.containsMouse ? "#707070" : "#505050"

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 10
                        anchors.margins: 10

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 12

                            AppText {
                                text: blessing.title
                                color: "#4ADE80"
                                font.family: "PixelOperator8"
                                font.pixelSize: 12
                            }

                            AppText {
                                text: blessing.description
                                font.family: "PixelOperator8"
                                color: "white"
                                font.pixelSize: 8
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 2
                            color: "#606060"
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 12

                            AppText {
                                text: curse.title
                                color: "#EF4444"
                                font.family: "PixelOperator8"
                                font.pixelSize: 12
                            }

                            AppText {
                                text: curse.description
                                color: "white"
                                font.family: "PixelOperator8"
                                font.pixelSize: 8
                            }
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: rewardPopup.applyCurseBlessingPair(blessing.identifier,curse.identifier)
                    }
                }
            }
        }
    }

    ListModel {
        id: rewardModel
    }

    ListModel {
        id: blessingModel
        ListElement {
            identifier: "increase_damage"
            title: "Increase Damage"
            description: "increases player damage by +1"
        }
        ListElement {
            identifier: "more_full_hp"
            title: "Increase Full HP"
            description: "increases player max hp by +1"
        }
        ListElement {
            identifier: "fully_heal"
            title: "Fully Heal"
            description: ""
        }
        ListElement {
            identifier: "berserk"
            title: "Berserk"
            description: "deal +1 damage for every 2 hp missing"
        }
        ListElement {
            identifier: "revive"
            title: "Revive"
            description: "adds one revive on next death"
        }
        ListElement {
            identifier: "lifesteal"
            title: "Lifesteal"
            description: "heals +1 hp on every enemy kill"
        }
    }

    ListModel {
        id: curseModel
        ListElement {
            identifier: "increase_enemy_hp"
            title: "Increases Enemy HP"
            description: "increases enemy hp by +1"
        }
        ListElement {
            identifier: "increase_enemy_damage"
            title: "Increases Enemy Damage"
            description: "increases enemy damage by +1"
        }
        ListElement {
            identifier: "increase_enemy_count"
            title: "More Enemies"
            description: "increases enemy count by +1"
        }
        ListElement {
            identifier: "double_enemy_count_next_level"
            title: "Double Enemies"
            description: "doubles enemy count for next level"
        }
    }

    function fillRewardModel() {
        const blessings = rewardPopup.pickRandomModelElements(blessingModel,rewardPopup.count);
        const curses = rewardPopup.pickRandomModelElements(curseModel,rewardPopup.count);

        rewardModel.clear();
        for(let i = 0; i < rewardPopup.count; i++) {
            rewardModel.append({blessing: blessings[i], curse: curses[i]});
        }
    }

    function pickRandomModelElements(model, count) {
        const indexes = [];
        while (indexes.length < count && indexes.length < model.count) {
            let r = Math.floor(Math.random() * model.count);
            if (indexes.indexOf(r) === -1)
                indexes.push(r);
        }

        const result = []
        for (let i = 0; i < indexes.length; i++) {
            result.push(model.get(indexes[i]));
        }
        return result;
    }
}
