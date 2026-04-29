import QtQuick
import Felgo

Item {
   id: tile

   property int type
   property int row // row inside tilemap
   property int column // column inside tilemap

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
 }
