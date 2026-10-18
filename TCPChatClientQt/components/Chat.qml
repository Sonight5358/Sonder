import QtQuick 2.15
import QtQuick.Effects
import QtQuick.Controls.Basic
import TCPChatClientQt

Item{
    id: root

    property color panelsColor
    property color mainColor
    property color textColor
    property color borderColor
    property color myBorderColor
    property color otherBorderColor
    property double opacityPanels
    property double borderIdleOpacity
    property font appTextFont
    property Gradient defaultGrad
    property int windowsRadius
    property int marginChatsField
    property double opacityMenu
    property font appSmallFont
    property real sendAreaHeight: 0
    property int menuIndex: -1

    ListModel{
        id: messageModel
    }

    function addMessage(text, mine){
        messageModel.insert(0, {messageText: text, isMine: mine})
    }
    function deleteMessage(i){
        if(i >= 0 && i < messageModel.count){
            messageModel.remove(i)
        }
    }

    ChatMenu{
        id: chatMenu

        mainColor: root.mainColor
        textColor: root.textColor
        borderColor: root.borderColor
        marginChatsField: root.marginChatsField
        opacityPanels: root.opacityPanels
        borderIdleOpacity: root.borderIdleOpacity
        opacityMenu: root.opacityMenu
        appTextFont: root.appTextFont
        appSmallFont: root.appSmallFont

        implicitWidth: 140

        onClosed: root.menuIndex = -1

        Action{
            text: "Copy"
            onTriggered: Clipboard.setText(messageModel.get(root.menuIndex).messageText)
        }
        Action{
            text: "Delete"
            onTriggered: root.deleteMessage(root.menuIndex)
        }
    }

    Rectangle{
        id: rectChatBottom
        color: Qt.alpha(panelsColor, opacityPanels)
        radius: windowsRadius

        border.width: 1
        border.color: borderColor

        anchors.fill: parent

        Rectangle{
            id: rectChatTop

            anchors.fill: parent
            anchors.margins: marginChatsField

            gradient: defaultGrad
            radius: 4

            layer.enabled: true
            layer.format: ShaderEffectSource.RGBA16F
            layer.effect: ShaderEffect{
                fragmentShader: "qrc:/shaders/assets/DitheringShader.frag.qsb"
            }
        }

        ListView{
            id: entireChat

            TapHandler{
                onTapped: {
                    appWindow.contentItem.forceActiveFocus()
                }
            }
            anchors.fill: parent
            anchors.margins: marginChatsField

            verticalLayoutDirection: ListView.BottomToTop
            clip: true
            spacing: 12

            model: messageModel

            header: Item{
                width: entireChat.width
                height: root.sendAreaHeight + 12
            }

            footer: Item{
                width: entireChat.width
                height: marginChatsField * 2
            }

            add: Transition{
                ParallelAnimation{
                    NumberAnimation{
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 250
                        easing.type: Easing.OutCubic
                    }

                    NumberAnimation{
                        property: "scale"
                        from: 0.75
                        to: 1
                        duration: 250
                        easing.type: Easing.OutCubic
                    }
                }
            }

            addDisplaced: Transition{
                NumberAnimation{
                    properties: "y"
                    duration: 250
                    easing.type: Easing.OutCubic
                }
            }

            remove: Transition{
                ParallelAnimation{
                    NumberAnimation{
                        property: "opacity"
                        from: 1
                        to: 0
                        duration: 200
                        easing.type: Easing.InCubic
                    }

                    NumberAnimation{
                        property: "scale"
                        from: 1
                        to: 0.75
                        duration: 200
                        easing.type: Easing.InCubic
                    }
                }
            }

            removeDisplaced: Transition{
                NumberAnimation{
                    properties: "y"
                    duration: 200
                    easing.type: Easing.InCubic
                }
            }

            delegate: Item{
                id: delegateRoot

                required property string messageText
                required property bool isMine
                required property int index

                readonly property bool highlighted: hoverHandler.hovered
                                                    || (chatMenu.visible && root.menuIndex === index)

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
                        }
                    }

                    width: message.width + 24
                    height: message.implicitHeight + 16

                    x: delegateRoot.isMine ? delegateRoot.width - width - 16 : 16

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

                    Text{
                    id: message

                    anchors.centerIn: parent

                    width: Math.min(implicitWidth, delegateRoot.width * 0.7 - 24)

                    text: delegateRoot.messageText
                    color: textColor
                    font: appTextFont

                    wrapMode: Text.Wrap
                    }
                }
            }

            ScrollBar.vertical: ScrollBar{
                id: sbar

                contentItem: Rectangle{
                    implicitWidth: 4
                    radius: implicitWidth / 2
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
        }
    }
}