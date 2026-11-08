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
    property font appTimeFont
    property real sendAreaHeight: 0
    property int menuIndex: -1
    property bool isAppShown
    property int startupDuration
    readonly property var nickPalette: ["#8B7FD6", "#A47FCF", "#9A8FC7", "#6F8FE0",
        "#5A9BD5", "#4FA3A5", "#5FAE84", "#7FA866"]

    opacity: isAppShown ? 1 : 0

    Behavior on opacity{
        NumberAnimation{
            duration: startupDuration
            easing.type: Easing.OutCubic
        }
    }

    ListModel{
        id: messageModel
    }

    function addMessage(sender, text, timestamp, mine){
        messageModel.insert(0, {nick: sender, messageText: text, timeStamp: timestamp, isMine: mine})
    }

    function deleteMessage(i){
        if(i >= 0 && i < messageModel.count){
            messageModel.remove(i)
        }
    }

    function colorNick(nick){
        let h = 0
        for (let i = 0; i < nick.length; i++){
            h = h * 31 + nick.charCodeAt(i) | 0
        }
        let ind = Math.abs(h) % root.nickPalette.length
        return nickPalette[ind]
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

        implicitWidth: 180

        onClosed: {
            const item = entireChat.itemAtIndex(root.menuIndex)
            if (item){
                item.unselectFade()
            }


            root.menuIndex = -1
            chatMenu.textSelected = ""
        }

        Action{
            text: chatMenu.textSelected !== "" ? "Copy selection" : "Copy"
            onTriggered: {
                if (chatMenu.textSelected.length > 0){
                    Clipboard.setText(chatMenu.textSelected)
                }
                else{
                    Clipboard.setText(messageModel.get(root.menuIndex).messageText)
                }
            }

            property string iconName: "copy"
        }
        Action{
            text: "Delete"
            onTriggered: root.deleteMessage(root.menuIndex)
            property string iconName: "trash"
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

                    // temporary disabled
                    SequentialAnimation{
                        id: unselectAnim

                        // ParallelAnimation{
                        //     ColorAnimation{
                        //         target: message
                        //         property: "selectionColor"
                        //         to: "transparent"
                        //         duration: 150
                        //         easing.type: Easing.InOutCubic
                        //     }
                        //     ColorAnimation{
                        //         target: message
                        //         property: "selectedTextColor"
                        //         to: textColor
                        //         duration: 150
                        //         easing.type: Easing.InOutCubic
                        //     }
                        // }

                        ScriptAction{
                            script: {
                                message.deselect()
                                // message.selectionColor = Qt.binding(() => message.selectedText.length > 0 ? textColor : "transparent")
                                // message.selectedTextColor = Qt.binding(() => message.selectedText.length > 0 ? "#171717" : textColor)
                            }
                        }
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