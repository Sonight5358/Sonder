import QtQuick 2.15
import TCPChatClientQt

OverlayScreen{
    id: root

    signal nicknameEntered(string nickname)

    onIsShowedChanged: {
        if (isShowed){
            registrationArea.focusField()
        }
    }

    Text{
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Glad to see you"
        font: appFont
        color: textColor
    }

    RegistrationArea{
        id: registrationArea

        anchors.horizontalCenter: parent.horizontalCenter

        width: 300

        panelsColor: root.panelsColor
        mainColor: root.mainColor
        textColor: root.textColor
        borderColor: root.borderColor
        marginChatsField: root.marginChatsField
        opacityPanels: root.opacityPanels
        appTextFont: root.appTextFont
        borderIdleOpacity: root.borderIdleOpacity
        opacityMenu: root.opacityMenu
        appSmallFont: root.appSmallFont

        onSendRequested: function(message){
            root.nicknameEntered(message)
        }
    }

    RegistrationButton{
        id: regButton

        anchors.horizontalCenter: parent.horizontalCenter

        isEmpty: registrationArea.isEmpty
        mainColor: root.mainColor
        textColor: root.textColor
        appFont: root.appFont

        onClicked: {
            registrationArea.send()
        }

        width: 300
    }
}