import QtQuick 2.15
import QtQuick.Effects
import QtQuick.Controls.Basic
import TCPChatClientQt
import QtQml.Models

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
        messageModel.insert(0, {nick: sender, messageText: text, timeStamp: timestamp, isMine: mine,
                                isImage: false, imageWidth: 0, imageHeight: 0, imageSource: ""})
    }
    function addImage(sender, url, timestamp, mine, width, height){
        messageModel.insert(0, {nick: sender, imageSource: url, timeStamp: timestamp, isMine: mine,
                            messageText: "", isImage: true, imageWidth: width, imageHeight: height})
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

        implicitWidth: 220

        onClosed: {
            root.menuIndex = -1
            chatMenu.textSelected = ""
        }

        Action{
            text: chatMenu.textSelected !== "" ? "Copy selection" : "Copy"
            onTriggered: {
                const item = messageModel.get(root.menuIndex)
                //const item = entireChat.itemAtIndex(root.menuIndex)


                if (item.isImage){
                    Clipboard.setImage(item.imageSource)
                }

                else{
                    if (chatMenu.textSelected.length > 0){
                        Clipboard.setText(chatMenu.textSelected)
                    }

                    else{
                        Clipboard.setText(messageModel.get(root.menuIndex).messageText)
                    }
                }
            }

            property string iconName: "copy"
        }
        Action{
            text: "Delete for yourself"
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
            delegate: chooser

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
                ParallelAnimation{
                    NumberAnimation{
                        properties: "y"
                        duration: 250
                        easing.type: Easing.OutCubic
                    }

                    NumberAnimation{
                        property: "opacity"
                        to: 1
                        duration: 250
                        easing.type: Easing.OutCubic
                    }

                    NumberAnimation{
                        property: "scale"
                        to: 1
                        duration: 250
                        easing.type: Easing.OutCubic
                    }
                }
            }

            remove: Transition{
                ParallelAnimation{
                    NumberAnimation{
                        property: "opacity"
                        from: 1
                        to: 0
                        duration: 250
                        easing.type: Easing.OutCubic
                    }

                    NumberAnimation{
                        property: "scale"
                        from: 1
                        to: 0.75
                        duration: 250
                        easing.type: Easing.OutCubic
                    }
                }
            }

            removeDisplaced: Transition{
                NumberAnimation{
                    properties: "y"
                    duration: 250
                    easing.type: Easing.OutCubic
                }
            }

            ScrollBar.vertical: ScrollBar{
                id: sbar

                visible: sbar.size < 1.0

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

    DelegateChooser{
        id: chooser

        role: "isImage"

        DelegateChoice{
            roleValue: true
            delegate: ImageDelegate {}
        }

        DelegateChoice{
            roleValue: false
            delegate: MessageDelegate {}
        }
    }
}