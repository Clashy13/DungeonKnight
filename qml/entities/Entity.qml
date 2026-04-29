import QtQuick
import Felgo

EntityBase {
    id: entity

    property int row // of tile
    property int column // of tile
    property string imgSrc
    property int imgSize

    Image {
        x: -entity.imgSize/ 2
        y: -entity.imgSize / 3 * 2
        width: entity.imgSize
        height: entity.imgSize
        smooth: false
        source: entity.imgSrc
    }
}
