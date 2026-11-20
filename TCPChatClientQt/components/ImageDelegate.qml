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
    required property int imageWidth
    required property int imageHeight

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

        RoundedImage{
            id: photoFrame

            source: delegateRoot.imageSource
            radius: windowsRadius

            width: Math.round(Math.min(delegateRoot.imageWidth / dpr, delegateRoot.maxContentWidth))
            height:  Math.round(delegateRoot.imageHeight * width / delegateRoot.imageWidth)

            x: delegateRoot.isMine ? delegateRoot.width - width - 16 : 16

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

                anchors.fill: photoFrame

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