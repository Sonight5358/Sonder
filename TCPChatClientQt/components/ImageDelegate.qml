import QtQuick 2.15
import QtQuick.Effects

Item{
    id: delegateRoot

    property double maxContentWidth: delegateRoot.width * 0.7 - 24

    required property string nick
    required property double timeStamp
    required property bool isMine
    required property int index
    required property string imageSource

    readonly property bool highlighted: hoverHandler.hovered
        || (chatMenu.visible && root.menuIndex === index)

    height: column.implicitHeight
    width: ListView.view.width

    Column{
        id: column

        anchors.fill: parent

        spacing: 1

        Text{
            id: nickname

            x: 28

            text: delegateRoot.nick
            font: root.appSmallFont
            color: root.colorNick(delegateRoot.nick)

            width: Math.min(implicitWidth, delegateRoot.maxContentWidth)
            elide: Text.ElideRight

            visible: !delegateRoot.isMine
        }

        Item{
            width: column.width
            height: photoFrame.height + 2

            RectangularShadow{
                id: rectShadow

                anchors.fill: delegateBottom

                radius: delegateBottom.radius
                blur: 20
                spread: 1
                color: Qt.rgba(0, 0, 0, opacityPanels - 0.15)
            }

            Rectangle{
                id: delegateBottom

                HoverHandler{
                    id: hoverHandler
                }
                TapHandler{
                    acceptedButtons: Qt.RightButton
                    onTapped: {
                        root.menuIndex = delegateRoot.index
                        chatMenu.popup()
                        chatMenu.textSelected = ""
                    }
                }

                width: photoFrame.width + 2
                height: photoFrame.height + 2

                x: delegateRoot.isMine ? delegateRoot.width - width - 16 : 16

                color: "transparent"
                radius: windowsRadius

                border.width: 1
                border.color: delegateRoot.isMine ? delegateRoot.highlighted ? Qt.lighter(myBorderColor, 1.5) : myBorderColor
                                        : delegateRoot.highlighted ? Qt.lighter(otherBorderColor, 1.5) : otherBorderColor

                Behavior on border.color{
                    ColorAnimation{
                        duration: 150
                        easing.type: Easing.OutCubic
                    }
                }
            }

            Item{
                id: photoFrame

                width: photo.implicitWidth > 0 ? Math.min(photo.implicitWidth, delegateRoot.maxContentWidth) : 0
                height: photo.implicitWidth > 0 ? photo.implicitHeight * width / photo.implicitWidth : 0

                x: delegateBottom.x + 1
                y: 1

                Image{
                    id: photo

                    anchors.fill: parent
                    source: delegateRoot.imageSource
                    fillMode: Image.PreserveAspectFit

                    layer.enabled: true
                    layer.smooth: true

                    visible: false
                }

                Rectangle{
                    id: roundedMask

                    anchors.fill: parent

                    radius: 10
                    color: "white"
                    antialiasing: true

                    layer.enabled: true
                    layer.smooth: true

                    visible: false
                }

                MultiEffect{
                    anchors.fill: parent

                    source: photo
                    maskEnabled: true
                    maskSource: roundedMask
                }

                Text{
                    text: Qt.formatTime(new Date(timeStamp), "hh:mm")

                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 4
                    anchors.right: parent.right
                    anchors.rightMargin: 8

                    font: appTimeFont
                    color: Qt.alpha(textColor, 0.7)
                }
            }
        }
    }
}