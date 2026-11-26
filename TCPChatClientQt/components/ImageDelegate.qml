import QtQuick
import QtQuick.Effects
import QtQuick.Shapes

Item{
    id: delegateRoot

    property double maxContentWidth: delegateRoot.width * 0.5 - 24

    required property string nick
    required property double timeStamp
    required property bool isMine
    required property int index
    required property string imageSource
    required property int imageWidth
    required property int imageHeight
    required property double totalToSend
    required property double sentBytes
    required property bool isSending
    required property bool isFailed

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

            scale: isSending === true || delegateRoot.isFailed === true ? 0.95 : 1
            opacity: isSending === true || delegateRoot.isFailed === true ? 0.75 : 1

            Behavior on scale{
                NumberAnimation{
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on opacity{
                NumberAnimation{
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }

            width: Math.min(delegateRoot.imageWidth / dpr, delegateRoot.maxContentWidth)
            height:  delegateRoot.imageHeight * width / delegateRoot.imageWidth

            x: delegateRoot.isMine ? delegateRoot.width - width - 16 : 16

            Rectangle{
                width: delegateRoot.isFailed ? 54 : 35
                height: 15
                radius: 4

                color: delegateRoot.isMine ? delegateRoot.highlighted ? Qt.lighter(myBorderColor, 1.5) : myBorderColor
                : delegateRoot.highlighted ? Qt.lighter(otherBorderColor, 1.5) : otherBorderColor

                Behavior on color{
                    ColorAnimation{
                        duration: 150
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on width{
                    NumberAnimation{
                        duration: 150
                        easing.type: Easing.OutCubic
                    }
                }

                anchors.bottom: parent.bottom
                anchors.bottomMargin: 4
                anchors.right: parent.right
                anchors.rightMargin: 4

                Row{
                    anchors.centerIn: parent

                    spacing: 4

                    Image{
                        visible: opacity > 0
                        opacity: delegateRoot.isFailed ? 1 : 0
                        source: "qrc:/qt/qml/TCPChatClientQt/assets/icons/square-exclamation-point.svg"
                        sourceSize: Qt.size(14, 14)

                        Behavior on opacity{
                            NumberAnimation{
                                duration: 150
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    Text{
                        text: Qt.formatTime(new Date(timeStamp), "hh:mm")

                        font: appTimeFont
                        color: Qt.alpha(textColor, 0.7)
                    }
                }
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

            Rectangle{
                id: roundedProgress

                anchors.centerIn: parent

                width: 50
                height: 50
                radius: windowsRadius

                property real progress: delegateRoot.totalToSend > 0 ? Math.min(1, delegateRoot.sentBytes / delegateRoot.totalToSend) : 0

                color: "transparent"
                opacity: isSending === true ? 1 : 0
                visible: opacity > 0

                Behavior on opacity{
                    NumberAnimation{
                        duration: 150
                        easing.type: Easing.OutCubic
                    }
                }

                Shape{
                    anchors.fill: parent

                    preferredRendererType: Shape.CurveRenderer

                    ShapePath{
                        fillColor: "transparent"
                        strokeColor: Qt.alpha(textColor, 0.25)
                        strokeWidth: 8
                        capStyle: ShapePath.RoundCap

                        PathRectangle{
                            x: 1.5
                            y: 1.5
                            width: roundedProgress.width - 3
                            height: roundedProgress.height - 3
                            radius: roundedProgress.radius - 1.5
                        }
                    }

                    ShapePath{
                        fillColor: "transparent"
                        strokeColor: Qt.alpha(textColor, 0.85)
                        strokeWidth: 7
                        capStyle: ShapePath.RoundCap
                        trim.end: roundedProgress.progress

                        PathRectangle{
                            x: 1.5
                            y: 1.5
                            width: roundedProgress.width - 3
                            height: roundedProgress.height - 3
                            radius: roundedProgress.radius - 1.5
                        }
                    }
                }
            }
        }
    }
}