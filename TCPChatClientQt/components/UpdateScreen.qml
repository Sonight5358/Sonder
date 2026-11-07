import QtQuick 2.15
import TCPChatClientQt

OverlayScreen{
    id: root

    property string reason

    Text{
        anchors.horizontalCenter: parent.horizontalCenter

        text: reason
        font: appFont
        color: textColor

        width: 300
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
    }

    RegistrationButton{
        id: regButton

        anchors.horizontalCenter: parent.horizontalCenter

        text: "Update"
        isEmpty: false
        mainColor: root.mainColor
        textColor: root.textColor
        appFont: root.appFont

        onClicked: {
            Qt.openUrlExternally("https://github.com/Sonight5358/Sonder")
            Qt.quit()
        }

        width: 300
    }
}