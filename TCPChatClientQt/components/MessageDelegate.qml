import QtQuick 2.15
import QtQuick.Effects

Item{
    id: delegateRoot

    property double maxContentWidth: delegateRoot.width * 0.7 - 24

    required property string nick
    required property string messageText
    required property double timeStamp
    required property bool isMine
    required property int index
    property alias messageItem: message

    readonly property bool highlighted: hoverHandler.hovered
                                        || (chatMenu.visible && root.menuIndex === index)

    function unselectFade(){
        unselectAnim.start()
    }

    height: delegateBottom.height
    width: ListView.view.width

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
                chatMenu.textSelected = message.selectedText
            }
        }

        width: column.width + 24
        height: column.implicitHeight + 16

        x: delegateRoot.isMine ? delegateRoot.width - width - 22 : 22

        color: delegateRoot.isMine? Qt.alpha("#2E2E2E", opacityPanels) : Qt.alpha(panelsColor, opacityPanels)
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

        Column{
            id: column

            anchors.top: parent.top
            anchors.topMargin: 8
            anchors.left: parent.left
            anchors.leftMargin: 12

            spacing: 1

            Text{
                id: nickname

                text: delegateRoot.nick
                font: root.appSmallFont
                color: root.colorNick(delegateRoot.nick)

                width: Math.min(implicitWidth, delegateRoot.maxContentWidth)
                elide: Text.ElideRight

                visible: !delegateRoot.isMine
            }

            Row{
                spacing: 4

                TextEdit{
                    id: message

                    width: Math.min(implicitWidth, delegateRoot.maxContentWidth)

                    readOnly: true
                    selectByKeyboard: true
                    selectByMouse: true

                    selectionColor: selectedText.length > 0 ? textColor : "transparent"
                    selectedTextColor: selectedText.length > 0 ? "#171717" : textColor

                    text: delegateRoot.messageText
                    color: textColor
                    font: appTextFont

                    wrapMode: Text.Wrap

                    Behavior on selectionColor{
                        ColorAnimation {
                            duration: 150
                            easing.type: Easing.InCubic
                        }
                    }
                    Behavior on selectedTextColor{
                        ColorAnimation {
                            duration: 150
                            easing.type: Easing.InCubic
                        }
                    }
                }

                Text{
                    text: Qt.formatTime(new Date(timeStamp), "hh:mm")

                    anchors.bottom: parent.bottom

                    font: appTimeFont
                    color: Qt.alpha(textColor, 0.7)
                }
            }
        }

        SequentialAnimation{
            id: unselectAnim

            ScriptAction{
                script: {
                    message.deselect()
                }
            }
        }
    }
}