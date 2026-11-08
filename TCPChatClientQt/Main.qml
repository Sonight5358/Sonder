import QtQuick
import QtCore
import QtQuick.Controls.Basic
import "components"
import TCPChatClientQt

ApplicationWindow{
    id: appWindow

    width: 1280
    height: 720
    minimumWidth: 900
    minimumHeight: 500

    visible: false
    color: "transparent"
    title: "Sonder"
    font: appFont
    opacity: 1
    FontLoader{
        id: manrope
        source: "qrc:/qt/qml/TCPChatClientQt/fonts/Manrope-VariableFont_wght.ttf"
    }

    Settings{
        id: settings
        property string nickname: ""
    }

    property color panelsColor: "#0A0A0A"
    property color mainColor: "#171717"
    property color textColor:  "#E5E4E2"
    property color borderColor: "#686868"
    property color myBorderColor: "#484848"
    property color otherBorderColor: "#2E2E2E"
    property int marginEl: 2
    property int marginChatsField: 4
    property int marginTopBottom: 5
    property double opacityPanels: 0.6
    property double opacityMenu: 0.9
    property double borderIdleOpacity: 0.4
    property int windowsRadius: 8
    property bool isAppShown: false
    property int startupDuration: 750
    property string connectionStatus: "Connecting..."
    property font appFont: Qt.font({family: manrope.name, weight: 600, pixelSize: 22})
    property font appTextFont: Qt.font({family: manrope.name, weight: 500, pixelSize: 18})
    property font appSmallFont: Qt.font({family: manrope.name, weight: 500, pixelSize: 14})
    property font appTimeFont: Qt.font({family: manrope.name, weight: 500, pixelSize: 12})
    property bool notified: false

    property Gradient defaultGrad: Gradient{
        GradientStop{
            position: 0.0
            color: Qt.alpha("#2E2E2E", appWindow.opacityPanels)
        }
        GradientStop{
            position: 1.0
            color: Qt.alpha("#0C0C0C", appWindow.opacityPanels)
        }
    }
    property Gradient defaultGradInverted: Gradient{
        GradientStop{
            position: 0.0
            color: Qt.alpha("#0C0C0C", appWindow.opacityPanels)
        }
        GradientStop{
            position: 1.0
            color: Qt.alpha("#2E2E2E", appWindow.opacityPanels)
        }
    }

    function enterApp(nickname){
        entryScreen.isShowed = false
        appWindow.isAppShown = true

        chatClient.connectToServer(/*"92.114.54.182"*/ "127.0.0.1", nickname)
        messageSendArea.focusFieldChat()
    }

    onActiveChanged: {
        if (appWindow.active)
        {
            appWindow.notified = false
        }
    }

    Component.onCompleted: {
        if (settings.nickname !== ""){
            enterApp(settings.nickname)
        }

        else{
            entryScreen.isShowed = true
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
        anchors.topMargin: appWindow.marginEl
        anchors.bottom: parent.bottom
        anchors.bottomMargin: appWindow.marginEl
        anchors.left: rectLeft.right
        anchors.leftMargin: marginEl
        anchors.right: parent.right
        anchors.rightMargin: appWindow.marginEl

        panelsColor: appWindow.panelsColor
        mainColor: appWindow.mainColor
        textColor: appWindow.textColor
        borderColor: appWindow.borderColor
        myBorderColor: appWindow.myBorderColor
        otherBorderColor: appWindow.otherBorderColor
        opacityPanels: appWindow.opacityPanels
        borderIdleOpacity: appWindow.borderIdleOpacity
        opacityMenu: appWindow.opacityMenu
        appSmallFont: appWindow.appSmallFont
        appTextFont: appWindow.appTextFont
        appTimeFont: appWindow.appTimeFont
        defaultGrad: appWindow.defaultGrad
        windowsRadius: appWindow.windowsRadius
        marginChatsField: appWindow.marginChatsField
        sendAreaHeight: rectChat.y + rectChat.height - messageSendArea.y

        isAppShown: appWindow.isAppShown
        startupDuration: appWindow.startupDuration

        transform: Translate{
            x: appWindow.isAppShown ? 0 : 80

            Behavior on x{
                NumberAnimation{
                    duration: appWindow.startupDuration
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    // List of chats
    People{
        id: rectLeft

        anchors.left: parent.left
        anchors.leftMargin: appWindow.marginEl
        anchors.top: parent.top
        anchors.topMargin: appWindow.marginEl
        anchors.bottom: parent.bottom
        anchors.bottomMargin: appWindow.marginEl

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
        isAppShown: appWindow.isAppShown
        startupDuration: appWindow.startupDuration

        width: widthPanel

        transform: Translate{
            x: appWindow.isAppShown ? 0 : -(rectLeft.width + appWindow.marginEl)

            Behavior on x{
                NumberAnimation{
                    duration:  appWindow.startupDuration
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    // Area of sending messages with a button
    MessageSendArea{
        id: messageSendArea

        onSendRequested: function(message){
            rectChat.addMessage(settings.nickname, message, Date.now(), true)
            chatClient.sendMessage(message)
        }

        anchors.bottom: parent.bottom
        anchors.bottomMargin: 27
        anchors.left: rectLeft.right
        anchors.leftMargin: 27
        anchors.right: parent.right
        anchors.rightMargin: 27

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
        isAppShown: appWindow.isAppShown
        startupDuration: appWindow.startupDuration

        transform: Translate{
            y: appWindow.isAppShown ? 0 : (messageSendArea.height * 2 + appWindow.marginEl)

            Behavior on y{
                NumberAnimation{
                    duration: appWindow.startupDuration
                    easing.type: Easing.OutCubic
                }
            }
        }

        onToButton: function(){
            sendButton.startSend()
        }

        SendButton{
            id: sendButton

            onClicked: messageSendArea.send()

            anchors.bottom: messageSendArea.bottom
            anchors.bottomMargin: 6
            anchors.right: messageSendArea.right
            anchors.rightMargin: 6

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

        marginChatsField: appWindow.marginChatsField
        panelsColor: appWindow.panelsColor
        mainColor: appWindow.mainColor
        textColor: appWindow.textColor
        borderColor: appWindow.borderColor
        opacityPanels: appWindow.opacityPanels
        appTextFont: appWindow.appTextFont
        connectionStatus: appWindow.connectionStatus
        isAppShown: appWindow.isAppShown
        startupDuration: appWindow.startupDuration

        transform: Translate{
            y: appWindow.isAppShown ? 0 : -(chatInformation.height * 2 + appWindow.marginEl)

            Behavior on y{
                NumberAnimation{
                    duration: appWindow.startupDuration
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    // Entry screen
    EntryScreen{
        id: entryScreen

        anchors.fill: parent
        anchors.margins: 100

        panelsColor: appWindow.panelsColor
        mainColor: appWindow.mainColor
        textColor: appWindow.textColor
        borderColor: appWindow.borderColor
        opacityPanels: appWindow.opacityPanels
        borderIdleOpacity: appWindow.borderIdleOpacity
        opacityMenu: appWindow.opacityMenu
        appSmallFont: appWindow.appSmallFont
        appFont: appWindow.appFont
        appTextFont: appWindow.appTextFont
        defaultGrad: appWindow.defaultGrad
        windowsRadius: appWindow.windowsRadius
        marginChatsField: appWindow.marginChatsField
        startupDuration: appWindow.startupDuration

        onNicknameEntered: function(nickname){
            settings.nickname = nickname
            appWindow.enterApp(nickname)
        }
    }

    // Update screen
    UpdateScreen{
        id: updateScreen

        anchors.fill: parent
        anchors.margins: 100

        panelsColor: appWindow.panelsColor
        mainColor: appWindow.mainColor
        textColor: appWindow.textColor
        borderColor: appWindow.borderColor
        opacityPanels: appWindow.opacityPanels
        borderIdleOpacity: appWindow.borderIdleOpacity
        opacityMenu: appWindow.opacityMenu
        appSmallFont: appWindow.appSmallFont
        appFont: appWindow.appFont
        appTextFont: appWindow.appTextFont
        defaultGrad: appWindow.defaultGrad
        windowsRadius: appWindow.windowsRadius
        marginChatsField: appWindow.marginChatsField
        startupDuration: appWindow.startupDuration
    }


    ChatClient{
        id: chatClient
    }

    Connections{
        target: chatClient
        function onMessageReceived(sender, text, timestamp, isHistory) {
            rectChat.addMessage(sender, text, timestamp, settings.nickname === sender)

            if ((!appWindow.active) && appWindow.notified === false && isHistory === false)
            {
                appWindow.alert(0)

                Notification.notify(sender, text)

                appWindow.notified = true
            }
        }
        function onConnected() {
            appWindow.connectionStatus = "Connected"
        }
        function onDisconnected() {
            appWindow.connectionStatus = "Disconnected"
        }
        function onRejected(code, why){
            if (code === 0)
            {
                appWindow.isAppShown = false
                updateScreen.reason = why
                updateScreen.isShowed = true
            }
        }
    }

    Connections{
        target: Notification

        function onTrayIconClicked() {
            appWindow.show()
            appWindow.raise()
            appWindow.requestActivate()
        }
    }
}