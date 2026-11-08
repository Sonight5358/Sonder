import QtQuick 2.15
import QtQuick.Controls.Basic

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

    width: root.size
    height: root.size

    contentItem: Image{
        visible: iconName !== ""
        source: iconName !== "" ? "qrc:/qt/qml/TCPChatClientQt/assets/icons/" + iconName + ".svg" : ""
        sourceSize: Qt.size(22, 22)

        fillMode: Image.Pad
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
        visible: root.hovered && tooltipText !== ""

        mainColor: root.mainColor
        textColor: root.textColor
        opacityMenu: root.opacityMenu
        appSmallFont: root.appSmallFont
        borderColor: root.borderColor
        borderIdleOpacity: root.borderIdleOpacity
    }
}