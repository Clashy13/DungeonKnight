import QtQuick
import Felgo

Item {
   id: tile

   property int type
   property int row // row inside tilemap
   property int column // column inside tilemap
   property bool occupied

   signal clicked()

   enum Type {
      Stone,
      Lava,
      Stairs
   }

   Image {
      anchors.fill: parent
      smooth: false
      source: {
         switch(tile.type) {
         case Tile.Stairs:
            return "../../assets/stairs_tile.png"
         case Tile.Lava:
            return "../../assets/lava_tile.png"
         default:
            return "../../assets/stone_tile.png"
         }
      }
   }

   Rectangle {
      anchors.fill: parent
      color: Qt.rgba(0.17,0.93,0.89,0.4)
      visible: (tile.type === Tile.Stone || tile.type === Tile.Stairs) && mouseArea.containsMouse
   }

   MouseArea {
      id: mouseArea
      anchors.fill: parent
      hoverEnabled: true;
      onClicked: {
         if(tile.type === Tile.Stone || tile.type === Tile.Stairs) {
            tile.clicked()
         }
      }
   }
}
