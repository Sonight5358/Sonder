import QtQuick 2.15
import QtQuick.Controls.Basic
import QtMultimedia
import QtQuick.Effects

Button{
    id: button

    property bool isEmpty: true
    property int size
    property int radiusButton
    property color mainColor
    property string iconName
    property string tooltipText
    property color textColor
    property double opacityMenu
    property font appSmallFont
    property color borderColor
    property double borderIdleOpacity

    function startSend(){
        soundPlayer.play()
        shaderAnim.restart()
        scaleAnim.restart()
    }

    onClicked: {
        startSend()
    }

    width: button.size
    height: button.size

    enabled: !isEmpty

    contentItem: Item{

        Image{
            id: iconItem
            anchors.centerIn: parent
            visible: iconName !== ""
            source: iconName !== "" ? "qrc:/qt/qml/TCPChatClientQt/assets/icons/" + iconName + ".svg" : ""
            sourceSize: Qt.size(22, 22)
        }
    }

    SequentialAnimation{
        id: scaleAnim

        NumberAnimation {
            target: iconItem
            property: "scale"
            to: 1.15
            duration: 100
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: iconItem
            property: "scale"
            to: 1
            duration: 100
            easing.type: Easing.OutCubic
        }
    }

    background: Rectangle{
        id: buttonRectangleBottom

        radius: button.radiusButton
        color: button.hovered && !isEmpty ? Qt.lighter(mainColor, 1.35) : mainColor

        Behavior on color{
            ColorAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
    }

    ShaderEffect{
        id: shader

        anchors.centerIn: parent

        width: 54
        height: 54

        property real progress: 1
        fragmentShader: "qrc:/shaders/assets/ButtonShader.frag.qsb"
    }

    NumberAnimation{
        id: shaderAnim
        target: shader

        property: "progress"
        from: 0
        to: 1
        duration: 600
        easing.type: Easing.OutCubic
    }

    CustomToolTip{
        text: tooltipText
        visible: button.hovered && tooltipText !== ""

        mainColor: button.mainColor
        textColor: button.textColor
        opacityMenu: button.opacityMenu
        appSmallFont: button.appSmallFont
        borderColor: button.borderColor
        borderIdleOpacity: button.borderIdleOpacity
    }

    // Send sound
    SoundEffect{
        id: soundPlayer
        volume: 0.1
        source: "qrc:/qt/qml/TCPChatClientQt/assets/SendS.wav"
    }
}