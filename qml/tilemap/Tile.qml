import QtQuick
import Felgo

Item {
   id: tile

   property int type
   property int row // row inside tilemap
   property int column // column inside tilemap

   signal clicked()

   enum Type {
      Stone,
      Lava
   }

   Image {
     anchors.fill: parent
     smooth: false
     source: {
       if (tile.type === Tile.Stone)
         return "../../assets/stone_tile.png"
       else
         return "../../assets/lava_tile.png"
     }
   }

   Rectangle {
      anchors.fill: parent
      color: Qt.rgba(0.17,0.93,0.89,0.4)
      visible: tile.type === Tile.Stone && mouseArea.containsMouse
   }

   MouseArea {
      id: mouseArea
      anchors.fill: parent
      hoverEnabled: true;
      onClicked: {
         if(tile.type === Tile.Stone) {
            tile.clicked()
         }
      }
   }
 }
