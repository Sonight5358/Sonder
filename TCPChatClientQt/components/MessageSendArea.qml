import QtQuick 2.15
import QtQuick.Controls.Basic
import QtQuick.Effects

Item{
    id: root
    height: Math.max(60, Math.min(200, messageField.implicitHeight + 25))

    property bool isEmpty: messageField.text.trim().length === 0

    property color panelsColor
    property color mainColor
    property color textColor
    property color borderColor
    property int rightContentMargin
    property double opacityPanels
    property font appTextFont

    RectangularShadow{
        id: rectShadow

        anchors.fill: parent


        radius: rectBottom.radius
        blur: 30
        spread: 5
        color: Qt.rgba(0, 0, 0, opacityPanels - 0.1)
    }

    Rectangle{
        id: rectBottom
        anchors.fill: parent

        color: Qt.alpha(panelsColor, opacityPanels)
        radius: 30

        Behavior on height{
                NumberAnimation{
                    duration: 75
                    easing.type: Easing.InOutQuad
                }
        }

        Rectangle {
            id: rectBottomTop
            anchors.fill: parent
            anchors.margins: 10
            color: Qt.alpha(mainColor, opacityPanels)
            radius: 30

            Behavior on height{
                    NumberAnimation{
                        duration: 75
                        easing.type: Easing.InOutQuad
                    }
            }
        }

        Flickable{
            id: flick

            anchors.left: parent.left
            anchors.leftMargin: 20

            anchors.right: parent.right
            anchors.rightMargin: rightContentMargin

            anchors.top: parent.top
            anchors.topMargin: 10

            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10

            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ScrollBar.vertical: ScrollBar{
                id: sbar

                contentItem: Rectangle{
                    implicitWidth: 5
                    radius: 2.5
                    color: textColor
                    opacity: sbar.active ? 0.7 : 0

                    Behavior on opacity{
                        NumberAnimation{
                            duration: 150
                            easing.type: Easing.OutCubic
                        }
                    }
                }
                background: null
            }

            TextArea.flickable: TextArea{
                id: messageField
                background: null

                rightPadding: 10

                font: appTextFont
                color: textColor

                placeholderText: "Message"
                placeholderTextColor: Qt.alpha(textColor, 0.6)

                wrapMode: TextEdit.Wrap
            }
        }
    }
}