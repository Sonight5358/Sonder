import QtQuick 2.15
import QtQuick.Controls.Basic
import QtQuick.Effects

ToolTip{
    id: root

    property color mainColor
    property color textColor
    property double opacityMenu
    property font appSmallFont
    property color borderColor
    property double borderIdleOpacity

    delay: 700
    padding: 6

    background: Item{
        id: itemRoot

        RectangularShadow{
            id: menuShadow

            anchors.fill: backRect

            radius: backRect.radius
            blur: 10
            spread: 2
            color: Qt.rgba(0, 0, 0, 0.6)
        }

        Rectangle{
            id: backRect

            anchors.fill: parent

            color: mainColor
            radius: 8

            border.width: 1
            border.color: Qt.alpha(borderColor, borderIdleOpacity)
        }
    }

    contentItem: Text{
        text: root.text

        font: appSmallFont
        color: textColor
    }

    enter: Transition{
        NumberAnimation{
            property: "opacity"
            from: 0
            to: 1
            duration: 150
            easing.type: Easing.InCubic
        }
    }

    exit: Transition{
        NumberAnimation{
            property: "opacity"
            from: 1
            to: 0
            duration: 200
            easing.type: Easing.OutCubic
        }
    }
}