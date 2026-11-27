import QtQuick 2.15
import QtQuick.Effects

Item{
    id: photoFrame

    property string source
    property int radius
    property bool isShadow: true

    readonly property real dpr: Screen.devicePixelRatio

    RectangularShadow{
        id: rectShadow

        anchors.fill: photoFrame
        visible: isShadow

        radius: photoFrame.radius
        blur: 20
        spread: 1
        color: Qt.rgba(0, 0, 0, opacityPanels - 0.15)
    }

    Image{
        id: photo

        anchors.fill: parent
        anchors.margins: 1

        source: photoFrame.source
        sourceSize: Qt.size(2048, 2048)
        fillMode: Image.PreserveAspectCrop

        layer.enabled: true
        layer.smooth: true

        visible: false
    }

    Rectangle{
        id: roundedMask

        anchors.fill: parent
        anchors.margins: 1

        radius: photoFrame.radius - 1
        color: "white"
        antialiasing: true

        layer.enabled: true
        layer.smooth: true

        visible: false
    }

    MultiEffect{
        anchors.fill: parent
        anchors.margins: 1

        source: photo
        maskEnabled: true
        maskSource: roundedMask
    }
}