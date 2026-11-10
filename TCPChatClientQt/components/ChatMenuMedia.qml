import QtQuick 2.15
import QtQuick.Controls.Basic
import QtQuick.Effects
import QtQuick.Layouts

Menu{
    id: root

    property color mainColor
    property color panelsColor
    property color textColor
    property color borderColor
    property int marginChatsField
    property double opacityPanels
    property font appTextFont
    property double borderIdleOpacity
    property double opacityMenu
    property font appSmallFont

    property real startY

    y: startY

    implicitWidth: 250
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

    topPadding: 10
    bottomPadding: 10

    background: Item{
        id: itemRoot

        RectangularShadow{
            id: rectShadow

            anchors.fill: parent

            radius: rectBottom.radius
            blur: 25
            spread: 3
            color: Qt.rgba(0, 0, 0, opacityPanels - 0.3)
        }

        Rectangle{
            id: rectBottom
            anchors.fill: parent

            color: Qt.alpha(panelsColor, opacityPanels)
            radius: 27

            border.width: 1
            border.color: Qt.alpha(borderColor, hoverHandler.hovered || root.currentIndex >= 0 ? 1 : borderIdleOpacity)

            Behavior on border.color{
                ColorAnimation{
                    duration: 150
                }
            }

            HoverHandler{
                id: hoverHandler
            }

            Rectangle {
                id: rectBottomTop
                anchors.fill: parent
                anchors.margins: marginChatsField
                color: mainColor
                radius: rectBottom.radius - marginChatsField
            }
        }
    }

    delegate: MenuItem{
        id: menuItem

        hoverEnabled: true

        onHoveredChanged: {
            if (!hovered && highlighted){
                root.currentIndex = -1
            }
        }

        leftInset: 10
        rightInset: 10
        leftPadding: 20
        rightPadding: 20

        contentItem: RowLayout{
            opacity: enabled ? 1 : 0.35

            Image{
                readonly property string iconName: menuItem.action?.iconName ?? ""

                visible: iconName !== ""
                source: iconName !== "" ? "qrc:/qt/qml/TCPChatClientQt/assets/icons/" + iconName + ".svg" : ""
                sourceSize: Qt.size(16, 16)
                Layout.preferredWidth: 16
                Layout.preferredHeight: 16
                Layout.alignment: Qt.AlignVCenter
            }

            Text{
                text: menuItem.text
                font: appTextFont
                color: textColor
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignBaseline

                transformOrigin: Item.Left
                scale: menuItem.highlighted ? 1.05 : 1

                Behavior on scale{
                    NumberAnimation{
                        duration: 75
                        easing.type: Easing.OutCubic
                    }
                }

                transform: Translate{
                    x: menuItem.highlighted ? 3 : 0

                    Behavior on x{
                        NumberAnimation{
                            duration: 75
                            easing.type: Easing.OutCubic
                        }
                    }
                }
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
            radius: rectBottomTop.radius - 10

            Behavior on opacity{
                NumberAnimation{
                    duration: 75
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    enter: Transition{
        ParallelAnimation{
            NumberAnimation{
                property: "y"
                from: startY + 14
                to: startY
                duration: 150
                easing.type: Easing.OutCubic
            }

            NumberAnimation{
                property: "opacity"
                from: 0
                to: 1
                duration: 150
                easing.type: Easing.OutCubic
            }
        }
    }

    exit: Transition{
        ParallelAnimation{
            NumberAnimation{
                property: "y"
                from: startY
                to: startY + 14
                duration: 150
                easing.type: Easing.OutCubic
            }

            NumberAnimation{
                property: "opacity"
                from: 1
                to: 0
                duration: 150
                easing.type: Easing.OutCubic
            }
        }
    }
}