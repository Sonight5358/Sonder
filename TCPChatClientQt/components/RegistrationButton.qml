import QtQuick 2.15
import QtQuick.Controls.Basic
import QtQuick.Effects
import QtMultimedia

Button{
    id: root

    property bool isEmpty: true
    property int actualButton: 52
    property color mainColor
    property color textColor
    property font appFont

    text: "Continue"
    enabled: !isEmpty

    width: 300
    height: actualButton
    opacity: enabled ? (root.hovered? 1 : 0.85) : 0.45

    Behavior on opacity{
        NumberAnimation{
            duration: 100
            easing.type: Easing.OutCubic
        }
    }

    contentItem: Text{
        text: root.text
        color: mainColor
        font: appFont

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle{
        id: buttonRectangleBottom

        radius: height / 2
        color: root.hovered && root.enabled ? Qt.lighter(root.textColor, 1.2) : root.textColor

        Behavior on color{
            ColorAnimation {
                duration: 100
                easing.type: Easing.OutCubic
            }
        }
    }

    function startSend(){
        soundPlayer.play()
    }

    // Send sound
    SoundEffect{
        id: soundPlayer
        volume: 0.1
        source: "qrc:/qt/qml/TCPChatClientQt/assets/SendS.wav"
    }
}