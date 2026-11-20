import QtQuick 2.15
import QtQuick.Controls.Basic
import QtQuick.Shapes

Button{
    id: root

    property int size
    property int radiusButton
    property color mainColor
    property string iconName
    property string tooltipText
    property color textColor
    property double opacityMenu
    property font appSmallFont
    property color borderColor
    property double borderIdleOpacity
    property bool toolTipVisible: true
    property real iconRot: 0
    property int iconSize: 16

    width: root.size
    height: root.size

    contentItem: Image{
        visible: iconName !== ""
        source: iconName !== "" ? "qrc:/qt/qml/TCPChatClientQt/assets/icons/" + iconName + ".svg" : ""

        fillMode: Image.Pad
        sourceSize: Qt.size(root.iconSize, root.iconSize)
    }

    background: Rectangle{
        id: buttonRectangleBottom

        radius: root.radiusButton
        color: root.hovered ? Qt.lighter(mainColor, 1.35) : mainColor

        Behavior on color{
            ColorAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
    }

    CustomToolTip{
        text: tooltipText

        visible: root.hovered && tooltipText !== "" && root.toolTipVisible

        mainColor: root.mainColor
        textColor: root.textColor
        opacityMenu: root.opacityMenu
        appSmallFont: root.appSmallFont
        borderColor: root.borderColor
        borderIdleOpacity: root.borderIdleOpacity
    }
}