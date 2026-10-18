import QtQuick
import QtQuick.Controls.Basic
import "components"
import TCPChatClientQt

ApplicationWindow{
    id: appWindow

    width: 1280
    height: 720
    minimumWidth: 1280
    minimumHeight: 720

    visible: true
    color: "transparent"
    title: "Sonder"
    font: appFont
    opacity: 1
    FontLoader{
        id: manrope
        source: "qrc:/qt/qml/TCPChatClientQt/fonts/Manrope-VariableFont_wght.ttf"
    }

    property color panelsColor: "#0A0A0A"
    property color mainColor: "#171717"
    property color textColor:  "#E5E4E2"
    property color borderColor: "#686868"
    property int marginEl: 10
    property int marginChatsField: 6
    property int marginTopBottom: 5
    property double opacityPanels: 0.6
    property double opacityMenu: 0.9
    property double borderIdleOpacity: 0.4
    property int windowsRadius: 8
    property font appFont: Qt.font({family: manrope.name, weight: 600, pixelSize: 22})
    property font appTextFont: Qt.font({family: manrope.name, weight: 500, pixelSize: 18})
    property font appSmallFont: Qt.font({family: manrope.name, weight: 500, pixelSize: 14})
    property Gradient defaultGrad: Gradient{
        GradientStop{
            position: 0.0
            color: Qt.alpha("#2E2E2E", opacityPanels)
        }
        GradientStop{
            position: 1.0
            color: Qt.alpha("#0C0C0C", opacityPanels)
        }
    }
    property Gradient defaultGradInverted: Gradient{
        GradientStop{
            position: 0.0
            color: Qt.alpha("#0C0C0C", opacityPanels)
        }
        GradientStop{
            position: 1.0
            color: Qt.alpha("#2E2E2E", opacityPanels)
        }
    }

    TapHandler{
        onTapped: {
            appWindow.contentItem.forceActiveFocus()
        }
    }




    // Field with messages
    Chat{
        id: rectChat

        anchors.top: parent.top
        anchors.topMargin: marginEl
        anchors.bottom: parent.bottom
        anchors.bottomMargin: marginEl
        anchors.left: rectLeft.right
        anchors.leftMargin: marginChatsField
        anchors.right: parent.right
        anchors.rightMargin: marginEl

        panelsColor: appWindow.panelsColor
        mainColor: appWindow.mainColor
        textColor: appWindow.textColor
        borderColor: appWindow.borderColor
        opacityPanels: appWindow.opacityPanels
        appTextFont: appWindow.appTextFont
        defaultGrad: appWindow.defaultGrad
        windowsRadius: appWindow.windowsRadius
        marginChatsField: appWindow.marginChatsField
        sendAreaHeight: rectChat.y + rectChat.height - messageSendArea.y
    }

    // List of chats
    People{
        id: rectLeft

        anchors.left: parent.left
        anchors.leftMargin: marginEl
        anchors.top: parent.top
        anchors.topMargin: marginEl
        anchors.bottom: parent.bottom
        anchors.bottomMargin: marginEl

        widthPanel: 300
        panelsColor: appWindow.panelsColor
        mainColor: appWindow.mainColor
        textColor: appWindow.textColor
        borderColor: appWindow.borderColor
        opacityPanels: appWindow.opacityPanels
        appTextFont: appWindow.appTextFont
        defaultGrad: appWindow.defaultGrad
        windowsRadius: appWindow.windowsRadius
        marginChatsField: appWindow.marginChatsField

        width: widthPanel
    }

    // Area of sending messages with a button
    MessageSendArea{
        id: messageSendArea

        onSendRequested: function(message){
            rectChat.addMessage(message, true)
            chatClient.messageReceived(message)
        }

        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        anchors.left: rectLeft.right
        anchors.leftMargin: 50
        anchors.right: parent.right
        anchors.rightMargin: 50

        panelsColor: appWindow.panelsColor
        mainColor: appWindow.mainColor
        textColor: appWindow.textColor
        borderColor: appWindow.borderColor
        opacityPanels: appWindow.opacityPanels
        borderIdleOpacity: appWindow.borderIdleOpacity
        appTextFont: appWindow.appTextFont
        appSmallFont: appWindow.appSmallFont
        rightContentMargin: sendButton.width + 15
        marginChatsField: appWindow.marginChatsField
        opacityMenu: appWindow.opacityMenu

        onToButton: function(){
            sendButton.startSend()
        }

        SendButton{
            id: sendButton

            onClicked: messageSendArea.send()

            anchors.bottom: messageSendArea.bottom
            anchors.bottomMargin: 6
            anchors.right: messageSendArea.right
            anchors.rightMargin: 5

            isEmpty: messageSendArea.isEmpty
            panelsColor: appWindow.panelsColor
            mainColor: appWindow.mainColor
            textColor: appWindow.textColor
            appFont: appWindow.appFont
        }
    }

    // Info about current chat
    ChatInformation{
        id: chatInformation

        anchors.top: parent.top
        anchors.topMargin: chatTopMargin
        anchors.left: rectLeft.right
        anchors.leftMargin: chatLeftMargin
        anchors.right: parent.right
        anchors.rightMargin: chatRightMargin

        panelsColor: appWindow.panelsColor
        mainColor: appWindow.mainColor
        textColor: appWindow.textColor
        borderColor: appWindow.borderColor
        opacityPanels: appWindow.opacityPanels
        appTextFont: appWindow.appTextFont
    }

    ChatClient{
        id: chatClient
    }
    Connections{
        target: chatClient
        function onMessageReceived(message){
            rectChat.addMessage(message, false)
        }
    }
}