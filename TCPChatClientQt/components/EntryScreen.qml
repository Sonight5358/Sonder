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
    property double opacityPanels
    property double borderIdleOpacity
    property font appTextFont
    property Gradient defaultGrad
    property int windowsRadius
    property int marginChatsField
    property double opacityMenu
    property font appSmallFont
    property int startupDuration

    property bool isEntryShowed: false

    signal nicknameEntered(string nickname)

    Component.onCompleted: {
        isEntryShowed = true
        registrationArea.focusField()
    }

    opacity: 0
    scale: 0.85
    visible: opacity > 0

    states: State{
        name: "open"
        when: root.isEntryShowed
        PropertyChanges{
            target: root
            opacity: 1
            scale: 1
        }
    }

    transitions: [
        Transition{
            to: "open"
            NumberAnimation{
                properties: "opacity, scale"
                duration: startupDuration
                easing.type: Easing.OutCubic
            }
        },
        Transition{
            from: "open"
            NumberAnimation{
                properties: "opacity"
                duration: startupDuration / 2
                easing.type: Easing.InCubic
            }
            NumberAnimation{
                properties: "scale"
                to: 1.3
                duration: startupDuration / 2
                easing.type: Easing.InCubic
            }
        }
    ]

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
    }

    RegistrationArea{
        id: registrationArea
        anchors.centerIn: parent

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
}