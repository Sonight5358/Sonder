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
    required property int imageWidht
    required property int imageHeight

    readonly property real dpr: Screen.devicePixelRatio

    readonly property bool highlighted: hoverHandler.hovered
        || (chatMenu.visible && root.menuIndex === index)

    height: Math.ceil(column.implicitHeight)
    width: ListView.view.width

    Column{
        id: column

        width: parent.width

        spacing: 1

        Text{
            id: nickname

            x: 28

            text: delegateRoot.nick
            font: root.appSmallFont
            color: root.colorNick(delegateRoot.nick)

            width: Math.min(implicitWidth, delegateRoot.maxContentWidth)
            height: Math.ceil(implicitHeight)

            elide: Text.ElideRight

            visible: !delegateRoot.isMine
        }

        Item{
            id: photoFrame

            width: Math.round(Math.min(delegateRoot.imageWidht / dpr, delegateRoot.maxContentWidth))
            height:  Math.round(delegateRoot.imageHeight * width / delegateRoot.imageWidht)

            x: delegateRoot.isMine ? delegateRoot.width - width - 16 : 16


            RectangularShadow{
                id: rectShadow

                anchors.fill: photoFrame

                radius: windowsRadius
                blur: 20
                spread: 1
                color: Qt.rgba(0, 0, 0, opacityPanels - 0.15)
            }

            Image{
                id: photo

                anchors.fill: parent
                anchors.margins: 1

                source: delegateRoot.imageSource
                sourceSize: Qt.size(width * dpr, height * dpr)
                fillMode: Image.PreserveAspectCrop

                layer.enabled: true
                layer.smooth: true

                visible: false
            }

            Rectangle{
                id: roundedMask

                anchors.fill: parent
                anchors.margins: 1

                radius: windowsRadius - 1
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

            Text{
                text: Qt.formatTime(new Date(timeStamp), "hh:mm")

                anchors.bottom: parent.bottom
                anchors.bottomMargin: 4
                anchors.right: parent.right
                anchors.rightMargin: 8

                font: appTimeFont
                color: Qt.alpha(textColor, 0.7)
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

                anchors.fill: parent

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
        }
    }
}