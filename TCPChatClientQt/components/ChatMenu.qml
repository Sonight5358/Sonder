import QtQuick 2.15
import QtQuick.Controls.Basic
import QtQuick.Effects
import QtQuick.Layouts

Menu{
    id: root

    property color mainColor
    property color textColor
    property color borderColor
    property int marginChatsField
    property double opacityPanels
    property font appTextFont
    property double borderIdleOpacity
    property double opacityMenu
    property font appSmallFont

    implicitWidth: 200

    topPadding: marginChatsField
    bottomPadding: marginChatsField

    background: Item{
        id: itemRoot

        RectangularShadow{
            id: menuShadow

            anchors.fill: backRect

            radius: backRect.radius
            blur: 30
            spread: 5
            color: Qt.rgba(0, 0, 0, opacityPanels - 0.1)
        }

        Rectangle{
            id: backRect

            anchors.fill: parent

            color: Qt.alpha(mainColor, opacityMenu)
            radius: 8

            border.width: 1
            border.color: Qt.alpha(borderColor, borderIdleOpacity)
        }
    }

    delegate: MenuItem{
        id: menuItem

        leftInset: 6
        rightInset: 6
        leftPadding: 12
        rightPadding: 12

        contentItem: RowLayout{
            opacity: enabled ? 1 : 0.35

            Text{
                text: menuItem.text
                font: appTextFont
                color: textColor
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignBaseline
            }
            Text{
                text: menuItem.action?.shortcutText ?? ""
                font: appSmallFont
                color: Qt.alpha(textColor, 0.7)
                Layout.alignment: Qt.AlignBaseline
            }
        }

        background: Rectangle{
            color: Qt.alpha(textColor, 0.08)
            opacity: menuItem.highlighted ? 1 : 0
            radius: 6

            Behavior on opacity{
                NumberAnimation{
                    duration: 75
                    easing.type: Easing.InOutCubic
                }
            }
        }
    }

    enter: Transition{
        NumberAnimation{
            property: "opacity"
            from: 0
            to: 1
            duration: 150
            easing.type: Easing.OutCubic
        }
    }
    exit: Transition{
        NumberAnimation{
            property: "opacity"
            from: 1
            to: 0
            duration: 100
            easing.type: Easing.InCubic
        }
    }
}